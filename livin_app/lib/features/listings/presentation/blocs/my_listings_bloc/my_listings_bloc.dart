import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livin_app/core/error/failure.dart';
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
    on<MyListingCreated>((event, emit) async {
      emit(const MyListingsLoading());
      try {
        await repository.createListing(event.listing);
        await _load(emit);
      } on Failure catch (failure) {
        emit(MyListingsFailure(message: failure.message));
      }
    });
    on<MyListingUpdated>((event, emit) async {
      emit(const MyListingsLoading());
      try {
        await repository.updateListing(event.listing);
        await _load(emit);
      } on Failure catch (failure) {
        emit(MyListingsFailure(message: failure.message));
      }
    });
    on<MyListingDeleted>((event, emit) async {
      emit(const MyListingsLoading());
      try {
        await repository.deleteListing(event.listingId);
        await _load(emit);
      } on Failure catch (failure) {
        emit(MyListingsFailure(message: failure.message));
      }
    });
  }

  Future<void> _load(Emitter<MyListingsState> emit) async {
    emit(const MyListingsLoading());
    try {
      final listings = await repository.getMyListings(_ownerId);
      emit(MyListingsSuccess(listings: listings));
    } on Failure catch (failure) {
      emit(MyListingsFailure(message: failure.message));
    }
  }
}