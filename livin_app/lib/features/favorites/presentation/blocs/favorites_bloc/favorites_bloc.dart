import 'package:flutter_bloc/flutter_bloc.dart';
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
    final idsResult = await repository.getFavoriteIds(_userId);
    if (idsResult.isLeft) {
      emit(FavoritesFailure(message: idsResult.left.message));
      return;
    }
    _ids = idsResult.right;
    final listingsResult = await repository.getFavoriteListings(_ids);
    listingsResult.fold(
      (failure) => emit(FavoritesFailure(message: failure.message)),
      (listings) => emit(
        FavoritesSuccess(favoriteIds: _ids, listings: listings),
      ),
    );
  }

  Future<void> _onToggled(
    FavoriteToggled event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await repository.toggleFavorite(
      userId: _userId,
      listingId: event.listingId,
      isFavorite: _ids.contains(event.listingId),
    );
    if (result.isLeft) {
      emit(FavoritesFailure(message: result.left.message));
      return;
    }
    await _load(emit);
  }
}