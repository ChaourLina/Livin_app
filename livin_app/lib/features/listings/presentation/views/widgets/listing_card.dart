import 'package:flutter/material.dart';
import 'package:livin_app/core/utils/constants.dart';
import 'package:livin_app/core/utils/formatters.dart';
import 'package:livin_app/features/listings/domain/entities/listing.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isRent = listing.transactionType == AppConstants.rent;
    final price = '${formatPrice(listing.price)} DA${isRent ? ' / mois' : ''}';

    return Card(
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: listing.photos.isEmpty
                      ? const ColoredBox(
                          color: Color(0xFFEEF2F2),
                          child: Center(
                            child: Icon(Icons.home_work_outlined, size: 44),
                          ),
                        )
                      : Image.network(
                          listing.photos.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isRent ? 'Location' : 'Vente',
                      style: TextStyle(
                        color: scheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (onFavoriteTap != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.black54,
                        ),
                        onPressed: onFavoriteTap,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 16, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${listing.city} · ${capitalize(listing.type)} · ${listing.rooms} ch.',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    price,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}