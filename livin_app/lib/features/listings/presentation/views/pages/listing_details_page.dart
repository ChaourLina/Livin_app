import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livin_app/core/router/app_routes.dart';
import 'package:livin_app/core/utils/constants.dart';
import 'package:livin_app/core/utils/formatters.dart';
import 'package:livin_app/core/utils/phone_utils.dart';
import 'package:livin_app/features/listings/domain/entities/listing.dart';
import 'package:url_launcher/url_launcher.dart';

class ListingDetailsPage extends StatefulWidget {
  final Listing listing;

  const ListingDetailsPage({super.key, required this.listing});

  @override
  State<ListingDetailsPage> createState() => _ListingDetailsPageState();
}

class _ListingDetailsPageState extends State<ListingDetailsPage> {
  int _photoIndex = 0;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _launch(Uri uri, String errorMessage) async {
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) _showMessage(errorMessage);
    } catch (_) {
      if (mounted) _showMessage(errorMessage);
    }
  }

    void _openViewer(int index) {
    context.push(
      AppRoutes.photos,
      extra: (photos: widget.listing.photos, index: index),
    );
  }

  void _openWhatsApp() {
    final number = toInternationalNumber(widget.listing.contact);
    if (number == null) {
      _showMessage('Numéro invalide');
      return;
    }
    final text = Uri.encodeComponent(
      'Bonjour, je suis intéressé(e) par votre annonce « ${widget.listing.title} » sur Livin.',
    );
    _launch(
      Uri.parse('https://wa.me/$number?text=$text'),
      'Impossible d\'ouvrir WhatsApp.',
    );
  }

  void _call() {
    final phone = widget.listing.contact.replaceAll(' ', '');
    _launch(Uri(scheme: 'tel', path: phone), 'Impossible de lancer l\'appel.');
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final scheme = Theme.of(context).colorScheme;
    final isRent = listing.transactionType == AppConstants.rent;
    final price = '${formatPrice(listing.price)} DA${isRent ? ' / mois' : ''}';

    return Scaffold(
      appBar: AppBar(title: const Text('Détail de l\'annonce')),
      body: ListView(
        children: [
          SizedBox(
            height: 260,
            child: listing.photos.isEmpty
                ? const ColoredBox(
                    color: Color(0xFFEEF2F2),
                    child: Center(
                      child: Icon(Icons.home_work_outlined, size: 56),
                    ),
                  )
                : Stack(
                    children: [
                      PageView.builder(
                        itemCount: listing.photos.length,
                        onPageChanged: (i) => setState(() => _photoIndex = i),
                        itemBuilder: (context, i) => GestureDetector(
                          onTap: () => _openViewer(i),
                          child: Image.network(
                            listing.photos[i],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _openViewer(_photoIndex),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.zoom_out_map,
                                    size: 16, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  '${_photoIndex + 1} / ${listing.photos.length}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
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
                  'Contacter le vendeur',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (listing.contact.isEmpty)
                  const Text('Aucun contact renseigné')
                else ...[
                  SelectableText(
                    listing.contact,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.chat),
                        label: const Text('WhatsApp'),
                        onPressed: _openWhatsApp,
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.call),
                        label: const Text('Appeler'),
                        onPressed: _call,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}