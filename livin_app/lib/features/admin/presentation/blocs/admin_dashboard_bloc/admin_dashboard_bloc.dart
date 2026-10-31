import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livin_app/features/admin/domain/repositories/admin_repository.dart';
import 'admin_dashboard_event.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardBloc
    extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final AdminRepository repository;

  AdminDashboardBloc({required this.repository})
      : super(const AdminDashboardInitial()) {
    on<AdminDashboardStarted>((event, emit) => _load(emit));
    on<AdminDashboardRefreshed>((event, emit) => _load(emit));
  }

  Future<void> _load(Emitter<AdminDashboardState> emit) async {
    emit(const AdminDashboardLoading());
    final result = await repository.getStats();
    result.fold(
      (failure) => emit(AdminDashboardFailure(message: failure.message)),
      (stats) => emit(AdminDashboardSuccess(stats: stats)),
    );
  }
}