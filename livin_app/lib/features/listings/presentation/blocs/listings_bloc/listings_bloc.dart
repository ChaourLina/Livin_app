import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livin_app/core/error/failure.dart';
import 'package:livin_app/features/listings/domain/entities/listing_filter.dart';
import 'package:livin_app/features/listings/domain/repositories/listings_repository.dart';
import 'listings_event.dart';
import 'listings_state.dart';

class ListingsBloc extends Bloc<ListingsEvent, ListingsState> {
  final ListingsRepository repository;
  ListingFilter _filter = const ListingFilter();

  ListingsBloc({required this.repository}) : super(const ListingsInitial()) {
    on<ListingsStarted>((event, emit) => _load(emit));
    on<ListingsRefreshed>((event, emit) => _load(emit));
    on<ListingsFilterChanged>((event, emit) {
      _filter = event.filter;
      return _load(emit);
    });
  }

  Future<void> _load(Emitter<ListingsState> emit) async {
    emit(const ListingsLoading());
    try {
      final listings = await repository.getListings(filter: _filter);
      emit(ListingsSuccess(listings: listings, filter: _filter));
    } on Failure catch (failure) {
      emit(ListingsFailure(message: failure.message));
    }
  }
}