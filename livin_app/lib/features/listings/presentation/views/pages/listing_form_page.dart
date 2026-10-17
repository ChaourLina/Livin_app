import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livin_app/core/utils/constants.dart';
import 'package:livin_app/core/utils/formatters.dart';
import 'package:livin_app/features/listings/domain/entities/listing.dart';
import 'package:livin_app/features/listings/presentation/blocs/my_listings_bloc/my_listings_bloc.dart';
import 'package:livin_app/features/listings/presentation/blocs/my_listings_bloc/my_listings_event.dart';
import 'package:livin_app/features/listings/presentation/blocs/my_listings_bloc/my_listings_state.dart';

class ListingFormPage extends StatefulWidget {
  final String ownerId;
  final Listing? listing;

  const ListingFormPage({super.key, required this.ownerId, this.listing});

  @override
  State<ListingFormPage> createState() => _ListingFormPageState();
}

class _ListingFormPageState extends State<ListingFormPage> {
  static const int _maxPhotos = 5;

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _roomsController;
  late final TextEditingController _contactController;
  late String _city;
  late String _type;
  late String _transaction;
  late List<String> _existingPhotos;
  final List<String> _newImagePaths = [];

  bool get _isEditing => widget.listing != null;

  @override
  void initState() {
    super.initState();
    final listing = widget.listing;
    _titleController = TextEditingController(text: listing?.title ?? '');
    _descriptionController =
        TextEditingController(text: listing?.description ?? '');
    _priceController =
        TextEditingController(text: listing?.price.toString() ?? '');
    _roomsController =
        TextEditingController(text: listing?.rooms.toString() ?? '');
    _contactController = TextEditingController(text: listing?.contact ?? '');
    _city = listing?.city ?? AppConstants.cities.first;
    _type = listing?.type ?? AppConstants.propertyTypes.first;
    _transaction = listing?.transactionType ?? AppConstants.rent;
    _existingPhotos = List<String>.from(listing?.photos ?? const []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _roomsController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final remaining = _maxPhotos - _existingPhotos.length - _newImagePaths.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('5 photos maximum par annonce')),
      );
      return;
    }
    final files = await _picker.pickMultiImage(
      imageQuality: 70,
      maxWidth: 1280,
    );
    if (files.isEmpty) return;
    setState(() {
      _newImagePaths.addAll(files.take(remaining).map((file) => file.path));
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.listing;
    final listing = Listing(
      id: existing?.id ?? '',
      ownerId: widget.ownerId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _type,
      transactionType: _transaction,
      price: int.parse(_priceController.text.trim()),
      rooms: int.parse(_roomsController.text.trim()),
      city: _city,
      contact: _contactController.text.trim(),
      isAvailable: existing?.isAvailable ?? true,
      photos: _existingPhotos,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    final bloc = context.read<MyListingsBloc>();
    if (existing == null) {
      bloc.add(MyListingCreated(listing: listing, imagePaths: _newImagePaths));
    } else {
      bloc.add(MyListingUpdated(listing: listing, imagePaths: _newImagePaths));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MyListingsBloc, MyListingsState>(
      listener: (context, state) {
        if (state is MyListingsSuccess) {
          context.pop();
        } else if (state is MyListingsFailure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Modifier l\'annonce' : 'Nouvelle annonce'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(
                            value: AppConstants.rent, label: Text('Location')),
                        ButtonSegment<String>(
                            value: AppConstants.sale, label: Text('Vente')),
                      ],
                      selected: {_transaction},
                      onSelectionChanged: (selection) =>
                          setState(() => _transaction = selection.first),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Titre'),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Titre obligatoire'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Description obligatoire'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Prix (DA)'),
                          validator: (value) {
                            final price = int.tryParse(value?.trim() ?? '');
                            return (price == null || price <= 0)
                                ? 'Prix invalide'
                                : null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _roomsController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Chambres'),
                          validator: (value) {
                            final rooms = int.tryParse(value?.trim() ?? '');
                            return (rooms == null || rooms < 0)
                                ? 'Nombre invalide'
                                : null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contactController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: 'Téléphone de contact'),
                    validator: (value) =>
                        (value == null || value.trim().length < 8)
                            ? 'Numéro invalide'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _city,
                    decoration: const InputDecoration(labelText: 'Ville'),
                    items: AppConstants.cities
                        .map((city) =>
                            DropdownMenuItem(value: city, child: Text(city)))
                        .toList(),
                    onChanged: (value) => setState(() => _city = value!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: AppConstants.propertyTypes
                        .map((type) => DropdownMenuItem(
                            value: type, child: Text(capitalize(type))))
                        .toList(),
                    onChanged: (value) => setState(() => _type = value!),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Photos',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_existingPhotos.isNotEmpty || _newImagePaths.isNotEmpty)
                    SizedBox(
                      height: 90,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (var i = 0; i < _existingPhotos.length; i++)
                            _PhotoThumb(
                              image: NetworkImage(_existingPhotos[i]),
                              onRemove: () =>
                                  setState(() => _existingPhotos.removeAt(i)),
                            ),
                          for (var i = 0; i < _newImagePaths.length; i++)
                            _PhotoThumb(
                              image: FileImage(File(_newImagePaths[i])),
                              onRemove: () =>
                                  setState(() => _newImagePaths.removeAt(i)),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('Ajouter des photos'),
                      onPressed: _pickImages,
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<MyListingsBloc, MyListingsState>(
                    builder: (context, state) {
                      final isLoading = state is MyListingsLoading;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                           child: isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _isEditing
                                          ? 'Enregistrement…'
                                          : 'Publication en cours…',
                                    ),
                                  ],
                                )
                              : Text(_isEditing ? 'Enregistrer' : 'Publier'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final ImageProvider image;
  final VoidCallback onRemove;

  const _PhotoThumb({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image(
              image: image,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}