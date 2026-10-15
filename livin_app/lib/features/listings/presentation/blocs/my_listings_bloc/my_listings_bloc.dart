import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livin_app/features/listings/domain/entities/listing.dart';
import 'package:livin_app/features/listings/domain/repositories/listings_repository.dart';
import 'my_listings_event.dart';
import 'my_listings_state.dart';

class MyListingsBloc extends Bloc<MyListingsEvent, MyListingsState> {
  final ListingsRepository repository;
  String _ownerId = '';

  MyListingsBloc({required this.repository})
      : super(const MyListingsInitial()) {
    on<MyListingsStarted>((event, emit) {
      _ownerId = event.ownerId;
      return _load(emit);
    });
    on<MyListingCreated>(
      (event, emit) => _save(event.listing, event.imagePaths, true, emit),
    );
    on<MyListingUpdated>(
      (event, emit) => _save(event.listing, event.imagePaths, false, emit),
    );
    on<MyListingDeleted>(_onDeleted);
  }

  Future<void> _save(
    Listing listing,
    List<String> imagePaths,
    bool isNew,
    Emitter<MyListingsState> emit,
  ) async {
    emit(const MyListingsLoading());
    final uploaded = await repository.uploadImages(imagePaths);
    if (uploaded.isLeft) {
      emit(MyListingsFailure(message: uploaded.left.message));
      return;
    }
    final withPhotos = listing.copyWith(
      photos: [...listing.photos, ...uploaded.right],
    );
    final saved = isNew
        ? await repository.createListing(withPhotos)
        : await repository.updateListing(withPhotos);
    if (saved.isLeft) {
      emit(MyListingsFailure(message: saved.left.message));
      return;
    }
    await _load(emit);
  }

  Future<void> _onDeleted(
    MyListingDeleted event,
    Emitter<MyListingsState> emit,
  ) async {
    emit(const MyListingsLoading());
    final result = await repository.deleteListing(event.listingId);
    if (result.isLeft) {
      emit(MyListingsFailure(message: result.left.message));
      return;
    }
    await _load(emit);
  }

  Future<void> _load(Emitter<MyListingsState> emit) async {
    emit(const MyListingsLoading());
    final result = await repository.getMyListings(_ownerId);
    result.fold(
      (failure) => emit(MyListingsFailure(message: failure.message)),
      (listings) => emit(MyListingsSuccess(listings: listings)),
    );
  }
}