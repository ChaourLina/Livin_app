import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livin_app/core/error/either.dart';
import 'package:livin_app/core/error/failure.dart';
import 'package:livin_app/features/admin/domain/repositories/admin_repository.dart';
import 'admin_users_event.dart';
import 'admin_users_state.dart';

class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState> {
  final AdminRepository repository;

  AdminUsersBloc({required this.repository})
      : super(const AdminUsersInitial()) {
    on<AdminUsersStarted>((event, emit) => _load(emit));
    on<AdminUserBlocked>(
      (event, emit) => _act(
        () => repository.blockUser(
          uid: event.uid,
          hideListings: event.hideListings,
        ),
        emit,
      ),
    );
    on<AdminUserUnblocked>(
      (event, emit) => _act(() => repository.unblockUser(event.uid), emit),
    );
  }

  Future<void> _load(Emitter<AdminUsersState> emit) async {
    emit(const AdminUsersLoading());
    final result = await repository.getUsers();
    result.fold(
      (failure) => emit(AdminUsersFailure(message: failure.message)),
      (users) => emit(AdminUsersSuccess(users: users)),
    );
  }

  // Exécute une action, puis recharge la liste.
  Future<void> _act(
    Future<Either<Failure, void>> Function() action,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(const AdminUsersLoading());
    final result = await action();
    if (result.isLeft) {
      emit(AdminUsersFailure(message: result.left.message));
      return;
    }
    await _load(emit);
  }
}