import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livin_app/core/utils/constants.dart';
import 'package:livin_app/core/utils/formatters.dart';
import 'package:livin_app/features/listings/domain/entities/listing.dart';

class ListingDetailsPage extends StatelessWidget {
  final Listing listing;

  const ListingDetailsPage({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final isRent = listing.transactionType == AppConstants.rent;
    final price = '${formatPrice(listing.price)} DA${isRent ? ' / mois' : ''}';

    return Scaffold(
      appBar: AppBar(title: const Text('Détail de l\'annonce')),
      body: ListView(
        children: [
          SizedBox(
            height: 240,
            child: listing.photos.isEmpty
                ? const ColoredBox(
                    color: Color(0xFFEEEEEE),
                    child: Center(
                      child: Icon(Icons.home_work_outlined, size: 56),
                    ),
                  )
                : PageView(
                    children: listing.photos
                        .map((url) => Image.network(url, fit: BoxFit.cover))
                        .toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text(isRent ? 'Location' : 'Vente')),
                    Chip(label: Text(capitalize(listing.type))),
                    Chip(label: Text(listing.city)),
                    Chip(label: Text('${listing.rooms} chambres')),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(listing.description),
                                const SizedBox(height: 24),
                Text(
                  'Contact',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (listing.contact.isEmpty)
                  const Text('Aucun contact renseigné')
                else
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          listing.contact,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.copy),
                        label: const Text('Copier'),
                        onPressed: () {
                          Clipboard.setData(
                          ClipboardData(text: listing.contact));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Numéro copié')),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}