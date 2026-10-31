import 'package:equatable/equatable.dart';

class AdminStats extends Equatable {
  final int totalUsers;
  final int blockedUsers;
  final int adminUsers;
  final int totalListings;
  final int onlineListings;
  final int hiddenListings;
  final int closedListings;
  final int onlineRent;
  final int onlineSale;
  final int newListingsLastWeek;

  const AdminStats({
    required this.totalUsers,
    required this.blockedUsers,
    required this.adminUsers,
    required this.totalListings,
    required this.onlineListings,
    required this.hiddenListings,
    required this.closedListings,
    required this.onlineRent,
    required this.onlineSale,
    required this.newListingsLastWeek,
  });

  @override
  List<Object?> get props => [
        totalUsers,
        blockedUsers,
        adminUsers,
        totalListings,
        onlineListings,
        hiddenListings,
        closedListings,
        onlineRent,
        onlineSale,
        newListingsLastWeek,
      ];
}