import 'package:equatable/equatable.dart';
import 'package:livin_app/features/listings/domain/entities/listing_filter.dart';

abstract class ListingsEvent extends Equatable {
  const ListingsEvent();

  @override
  List<Object?> get props => [];
}

class ListingsStarted extends ListingsEvent {
  const ListingsStarted();
}

class ListingsRefreshed extends ListingsEvent {
  const ListingsRefreshed();
}

class ListingsFilterChanged extends ListingsEvent {
  final ListingFilter filter;

  const ListingsFilterChanged({required this.filter});

  @override
  List<Object?> get props => [filter];
}