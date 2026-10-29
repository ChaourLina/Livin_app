import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livin_app/core/error/either.dart';
import 'package:livin_app/core/error/failure.dart';
import 'package:livin_app/features/admin/domain/repositories/admin_repository.dart';
import 'admin_listings_event.dart';
import 'admin_listings_state.dart';

class AdminListingsBloc extends Bloc<AdminListingsEvent, AdminListingsState> {
  final AdminRepository repository;

  AdminListingsBloc({required this.repository})
      : super(const AdminListingsInitial()) {
    on<AdminListingsStarted>((event, emit) => _load(emit));
    on<AdminListingHidden>(
      (event, emit) => _act(
        () => repository.hideListing(
          listingId: event.listingId,
          note: event.note,
        ),
        emit,
      ),
    );
    on<AdminListingRestored>(
      (event, emit) => _act(
        () => repository.restoreListing(event.listingId),
        emit,
      ),
    );
    on<AdminListingDeleted>(
      (event, emit) => _act(
        () => repository.deleteListing(event.listingId),
        emit,
      ),
    );
  }

  Future<void> _load(Emitter<AdminListingsState> emit) async {
    emit(const AdminListingsLoading());
    final result = await repository.getListings();
    result.fold(
      (failure) => emit(AdminListingsFailure(message: failure.message)),
      (items) => emit(AdminListingsSuccess(items: items)),
    );
  }

  // Exécute une action de modération, puis recharge la liste.
  Future<void> _act(
    Future<Either<Failure, void>> Function() action,
    Emitter<AdminListingsState> emit,
  ) async {
    emit(const AdminListingsLoading());
    final result = await action();
    if (result.isLeft) {
      emit(AdminListingsFailure(message: result.left.message));
      return;
    }
    await _load(emit);
  }
}