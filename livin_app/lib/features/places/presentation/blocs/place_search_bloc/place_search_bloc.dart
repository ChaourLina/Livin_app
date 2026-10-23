import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livin_app/features/places/domain/repositories/places_repository.dart';
import 'place_search_event.dart';
import 'place_search_state.dart';

class PlaceSearchBloc extends Bloc<PlaceSearchEvent, PlaceSearchState> {
  final PlacesRepository repository;

  PlaceSearchBloc({required this.repository})
      : super(const PlaceSearchInitial()) {
    on<PlaceSearchSubmitted>(_onSubmitted);
    on<PlaceSearchCleared>((event, emit) => emit(const PlaceSearchInitial()));
  }

  Future<void> _onSubmitted(
    PlaceSearchSubmitted event,
    Emitter<PlaceSearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.length < 3) {
      emit(const PlaceSearchInitial());
      return;
    }
    emit(const PlaceSearchLoading());
    final result = await repository.searchPlaces(query);
    result.fold(
      (failure) => emit(PlaceSearchFailure(message: failure.message)),
      (places) => emit(PlaceSearchSuccess(places: places)),
    );
  }
}