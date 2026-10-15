import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livin_app/features/listings/domain/entities/listing.dart';
import 'package:livin_app/features/listings/domain/entities/listing_filter.dart';
import 'package:livin_app/features/listings/domain/repositories/listings_repository.dart';
import 'listings_event.dart';
import 'listings_state.dart';

class ListingsBloc extends Bloc<ListingsEvent, ListingsState> {
  final ListingsRepository repository;
  ListingFilter _filter = const ListingFilter();
  List<Listing> _all = [];

  ListingsBloc({required this.repository}) : super(const ListingsInitial()) {
    on<ListingsStarted>((event, emit) => _fetch(emit));
    on<ListingsRefreshed>((event, emit) => _fetch(emit));
    on<ListingsFilterChanged>(_onFilterChanged);
  }

  Future<void> _fetch(Emitter<ListingsState> emit) async {
    emit(const ListingsLoading());
    final result = await repository.getListings();
    result.fold(
      (failure) => emit(ListingsFailure(message: failure.message)),
      (listings) {
        _all = listings;
        emit(_successState());
      },
    );
  }

  void _onFilterChanged(
    ListingsFilterChanged event,
    Emitter<ListingsState> emit,
  ) {
    _filter = event.filter;
    if (state is ListingsSuccess) {
      emit(_successState());
    }
  }

  ListingsSuccess _successState() {
    return ListingsSuccess(
      listings: repository.filterListings(_all, _filter),
      filter: _filter,
    );
  }
}