import 'package:equatable/equatable.dart';
import 'package:livin_app/features/admin/domain/entities/admin_stats.dart';

abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

class AdminDashboardInitial extends AdminDashboardState {
  const AdminDashboardInitial();
}

class AdminDashboardLoading extends AdminDashboardState {
  const AdminDashboardLoading();
}

class AdminDashboardSuccess extends AdminDashboardState {
  final AdminStats stats;

  const AdminDashboardSuccess({required this.stats});

  @override
  List<Object?> get props => [stats];
}

class AdminDashboardFailure extends AdminDashboardState {
  final String message;

  const AdminDashboardFailure({required this.message});

  @override
  List<Object?> get props => [message];
}