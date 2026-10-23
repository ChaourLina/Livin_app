import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:livin_app/core/di/injection.dart';
import 'package:livin_app/core/utils/city_centers.dart';
import 'package:livin_app/features/places/domain/entities/place.dart';
import 'package:livin_app/features/places/presentation/blocs/place_search_bloc/place_search_bloc.dart';
import 'package:livin_app/features/places/presentation/blocs/place_search_bloc/place_search_event.dart';
import 'package:livin_app/features/places/presentation/blocs/place_search_bloc/place_search_state.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationPickerPage extends StatelessWidget {
  final LatLng? initial;
  final String city;

  const LocationPickerPage({super.key, this.initial, required this.city});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PlaceSearchBloc>(),
      child: _LocationPickerView(initial: initial, city: city),
    );
  }
}

class _LocationPickerView extends StatefulWidget {
  final LatLng? initial;
  final String city;

  const _LocationPickerView({required this.initial, required this.city});

  @override
  State<_LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<_LocationPickerView> {
  final _mapController = MapController();
  final _searchController = TextEditingController();
  LatLng? _point;

  @override
  void initState() {
    super.initState();
    _point = widget.initial;
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    final text = _searchController.text.trim();
    if (text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saisissez au moins 3 caractères.')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    // On ajoute la ville du formulaire pour orienter la recherche.
    final mentionsCity = text.toLowerCase().contains(widget.city.toLowerCase());
    final query = mentionsCity ? text : '$text, ${widget.city}';
    context.read<PlaceSearchBloc>().add(PlaceSearchSubmitted(query: query));
  }

  void _selectPlace(Place place) {
    final point = LatLng(place.latitude, place.longitude);
    setState(() => _point = point);
    _mapController.move(point, 17);
    context.read<PlaceSearchBloc>().add(const PlaceSearchCleared());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final point = _point;

    return Scaffold(
      appBar: AppBar(title: const Text('Position du logement')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: point ?? CityCenters.of(widget.city),
                  initialZoom: point != null ? 16 : 12,
                  onTap: (_, tapped) {
                    setState(() => _point = tapped);
                    context.read<PlaceSearchBloc>().add(const PlaceSearchCleared());
                  },
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.livin_app',
                  ),
                  if (point != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          width: 48,
                          height: 48,
                          alignment: Alignment.topCenter,
                          child: Icon(
                            Icons.location_on,
                            size: 48,
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () => launchUrl(
                          Uri.parse('https://openstreetmap.org/copyright'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Column(
                  children: [
                    Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(30),
                      child: BlocBuilder<PlaceSearchBloc, PlaceSearchState>(
                        builder: (context, state) {
                          final isLoading = state is PlaceSearchLoading;
                          return TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => isLoading ? null : _search(),
                            decoration: InputDecoration(
                              hintText: 'Rechercher une adresse ou un quartier…',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(14),
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.arrow_forward),
                                      onPressed: _search,
                                    ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    BlocBuilder<PlaceSearchBloc, PlaceSearchState>(
                      builder: (context, state) {
                        if (state is PlaceSearchFailure) {
                          return _MessageCard(text: state.message);
                        }
                        if (state is PlaceSearchSuccess) {
                          if (state.places.isEmpty) {
                            return const _MessageCard(
                              text:
                                  'Aucun résultat. Essayez un autre mot, ou touchez la carte pour placer le logement.',
                            );
                          }
                          return Card(
                            margin: const EdgeInsets.only(top: 8),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 260),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: state.places.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final place = state.places[index];
                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.place_outlined),
                                    title: Text(
                                      place.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () => _selectPlace(place),
                                  );
                                },
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (point == null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Cherchez une adresse, ou touchez la carte.',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Confirmer cette position'),
                      onPressed: point == null ? null : () => context.pop(point),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String text;

  const _MessageCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(text),
      ),
    );
  }
}