import 'package:get_it/get_it.dart';
import 'package:livin_app/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:livin_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:livin_app/features/favorites/data/data_sources/remote/favorites_remote_data_source.dart';
import 'package:livin_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:livin_app/features/favorites/presentation/blocs/favorites_bloc/favorites_bloc.dart';
import 'package:livin_app/features/listings/data/data_sources/remote/images_remote_data_source.dart';
import 'package:livin_app/features/listings/data/data_sources/remote/listings_remote_data_source.dart';
import 'package:livin_app/features/listings/domain/repositories/listings_repository.dart';
import 'package:livin_app/features/listings/presentation/blocs/listings_bloc/listings_bloc.dart';
import 'package:livin_app/features/listings/presentation/blocs/my_listings_bloc/my_listings_bloc.dart';

final GetIt sl = GetIt.instance;

void setupDependencies() {
  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource());
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(remoteDataSource: sl(), imagesDataSource: sl()),
  );
  sl.registerFactory<AuthBloc>(() => AuthBloc(repository: sl()));

  // Listings
  sl.registerLazySingleton<ImagesRemoteDataSource>(
    () => ImagesRemoteDataSource(),
  );
  sl.registerLazySingleton<ListingsRemoteDataSource>(
    () => ListingsRemoteDataSource(),
  );
  sl.registerLazySingleton<ListingsRepository>(
    () => ListingsRepository(remoteDataSource: sl(), imagesDataSource: sl()),
  );
  sl.registerFactory<ListingsBloc>(() => ListingsBloc(repository: sl()));
  sl.registerFactory<MyListingsBloc>(() => MyListingsBloc(repository: sl()));

  // Favorites
  sl.registerLazySingleton<FavoritesRemoteDataSource>(
    () => FavoritesRemoteDataSource(),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepository(
      favoritesDataSource: sl(),
      listingsDataSource: sl(),
    ),
  );
  sl.registerFactory<FavoritesBloc>(() => FavoritesBloc(repository: sl()));
}