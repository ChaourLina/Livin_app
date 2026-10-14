import 'package:flutter/material.dart';
import 'package:livin_app/core/utils/constants.dart';
import 'package:livin_app/core/utils/formatters.dart';
import 'package:livin_app/features/listings/domain/entities/listing.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;

  const ListingCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final isRent = listing.transactionType == AppConstants.rent;
    final price = '${formatPrice(listing.price)} DA${isRent ? ' / mois' : ''}';

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            width: double.infinity,
            child: listing.photos.isEmpty
                ? const ColoredBox(
                    color: Color(0xFFEEEEEE),
                    child: Center(
                      child: Icon(Icons.home_work_outlined, size: 40),
                    ),
                  )
                : Image.network(
                    listing.photos.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.broken_image_outlined)),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${capitalize(listing.type)} · ${listing.city} · ${listing.rooms} ch.',
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}