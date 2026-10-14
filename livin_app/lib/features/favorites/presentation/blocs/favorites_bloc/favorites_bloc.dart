import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livin_app/core/error/failure.dart';
import 'package:livin_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository repository;
  String _userId = '';
  List<String> _ids = [];

  FavoritesBloc({required this.repository}) : super(const FavoritesInitial()) {
    on<FavoritesStarted>((event, emit) async {
      _userId = event.userId;
      emit(const FavoritesLoading());
      await _load(emit);
    });
    on<FavoriteToggled>(_onToggled);
  }

  Future<void> _load(Emitter<FavoritesState> emit) async {
    try {
      _ids = await repository.getFavoriteIds(_userId);
      final listings = await repository.getFavoriteListings(_ids);
      emit(FavoritesSuccess(favoriteIds: _ids, listings: listings));
    } on Failure catch (failure) {
      emit(FavoritesFailure(message: failure.message));
    }
  }

  Future<void> _onToggled(
    FavoriteToggled event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await repository.toggleFavorite(
        userId: _userId,
        listingId: event.listingId,
        isFavorite: _ids.contains(event.listingId),
      );
      await _load(emit);
    } on Failure catch (failure) {
      emit(FavoritesFailure(message: failure.message));
    }
  }
}