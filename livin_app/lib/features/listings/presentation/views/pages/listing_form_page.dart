import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _roomsController;
  late final TextEditingController _contactController;
  late String _city;
  late String _type;
  late String _transaction;

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
      photos: existing?.photos ?? const [],
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    final bloc = context.read<MyListingsBloc>();
    if (existing == null) {
      bloc.add(MyListingCreated(listing: listing));
    } else {
      bloc.add(MyListingUpdated(listing: listing));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MyListingsBloc, MyListingsState>(
      listener: (context, state) {
        if (state is MyListingsSuccess) {
          Navigator.of(context).pop();
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
                  BlocBuilder<MyListingsBloc, MyListingsState>(
                    builder: (context, state) {
                      final isLoading = state is MyListingsLoading;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
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