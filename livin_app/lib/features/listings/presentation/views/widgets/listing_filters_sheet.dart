import 'package:flutter/material.dart';
import 'package:livin_app/core/shared/app_input.dart';
import 'package:livin_app/core/utils/amenities.dart';
import 'package:livin_app/features/listings/domain/entities/listing_filter.dart';

class ListingFiltersSheet extends StatefulWidget {
  final ListingFilter initial;

  const ListingFiltersSheet({super.key, required this.initial});

  @override
  State<ListingFiltersSheet> createState() => _ListingFiltersSheetState();
}

class _ListingFiltersSheetState extends State<ListingFiltersSheet> {
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  late final TextEditingController _minSurfaceController;
  int? _minRooms;
  late final Set<String> _amenities;
  String? _error;

  @override
  void initState() {
    super.initState();
    final filter = widget.initial;
    _minPriceController =
        TextEditingController(text: filter.minPrice?.toString() ?? '');
    _maxPriceController =
        TextEditingController(text: filter.maxPrice?.toString() ?? '');
    _minSurfaceController =
        TextEditingController(text: filter.minSurface?.toString() ?? '');
    _minRooms = filter.minRooms;
    _amenities = Set<String>.from(filter.amenities);
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minSurfaceController.dispose();
    super.dispose();
  }

  int? _parse(TextEditingController controller) {
    return int.tryParse(controller.text.trim());
  }

  void _reset() {
    _minPriceController.clear();
    _maxPriceController.clear();
    _minSurfaceController.clear();
    setState(() {
      _minRooms = null;
      _amenities.clear();
      _error = null;
    });
  }

  void _apply() {
    final minPrice = _parse(_minPriceController);
    final maxPrice = _parse(_maxPriceController);
    if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
      setState(() => _error = 'Le prix minimum dépasse le prix maximum.');
      return;
    }
    Navigator.of(context).pop(
      ListingFilter(
        minPrice: minPrice,
        maxPrice: maxPrice,
        minSurface: _parse(_minSurfaceController),
        minRooms: _minRooms,
        amenities: Amenities.all.where(_amenities.contains).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final titleStyle = Theme.of(context).textTheme.titleSmall;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filtres avancés',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            Text('Prix (DA)', style: titleStyle),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: appInputDecoration(context, 'Minimum'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: appInputDecoration(context, 'Maximum'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Surface minimale (m²)', style: titleStyle),
            const SizedBox(height: 8),
            TextField(
              controller: _minSurfaceController,
              keyboardType: TextInputType.number,
              decoration: appInputDecoration(context, 'Ex : 80'),
            ),
            const SizedBox(height: 20),
            Text('Chambres minimum', style: titleStyle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final count in [1, 2, 3, 4])
                  ChoiceChip(
                    label: Text('$count+'),
                    selected: _minRooms == count,
                    onSelected: (selected) =>
                        setState(() => _minRooms = selected ? count : null),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Équipements', style: titleStyle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final amenity in Amenities.all)
                  FilterChip(
                    label: Text(amenity),
                    selected: _amenities.contains(amenity),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _amenities.add(amenity);
                      } else {
                        _amenities.remove(amenity);
                      }
                    }),
                  ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    child: const Text('Réinitialiser'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _apply,
                    child: const Text('Appliquer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}