import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:livin_app/core/router/app_routes.dart';
import 'package:livin_app/core/utils/city_centers.dart';
import 'package:livin_app/features/listings/domain/entities/listing.dart';
import 'package:livin_app/features/listings/presentation/views/widgets/listing_card.dart';
import 'package:url_launcher/url_launcher.dart';

class ListingsMapView extends StatelessWidget {
  final List<Listing> listings;

  const ListingsMapView({super.key, required this.listings});

  String _shortPrice(int price) {
    if (price >= 1000000) {
      final millions = price / 1000000;
      final text = price % 1000000 == 0
          ? millions.toStringAsFixed(0)
          : millions.toStringAsFixed(1);
      return '$text M';
    }
    if (price >= 1000) return '${(price / 1000).round()} k';
    return '$price';
  }

  void _showListing(BuildContext context, Listing listing) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: ListingCard(
          listing: listing,
          onTap: () {
            Navigator.of(sheetContext).pop();
            context.push(AppRoutes.listing, extra: listing);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final located = listings.where((listing) => listing.hasLocation).toList();
    final missing = listings.length - located.length;
    final points = [
      for (final listing in located)
        LatLng(listing.latitude!, listing.longitude!),
    ];

    final summary = located.isEmpty
        ? 'Aucune annonce positionnée'
        : '${located.length} sur la carte'
            '${missing > 0 ? ' · $missing sans position' : ''}';

    return Stack(
      children: [
        FlutterMap(
          // La clé relance la carte quand la liste filtrée change,
          // ce qui recadre automatiquement la vue sur les annonces.
          key: ValueKey(located.map((listing) => listing.id).join(',')),
          options: MapOptions(
            initialCenter: CityCenters.algeria,
            initialZoom: 5.5,
            initialCameraFit: points.isEmpty
                ? null
                : CameraFit.coordinates(
                    coordinates: points,
                    padding: const EdgeInsets.all(56),
                    maxZoom: 15,
                  ),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.livin_app',
            ),
            MarkerLayer(
              markers: [
                for (final listing in located)
                  Marker(
                    point: LatLng(listing.latitude!, listing.longitude!),
                    width: 88,
                    height: 34,
                    child: GestureDetector(
                      onTap: () => _showListing(context, listing),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          _shortPrice(listing.price),
                          style: TextStyle(
                            color: scheme.onPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Text(
              summary,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}