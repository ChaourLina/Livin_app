import 'package:get_it/get_it.dart';
import 'package:livin_app/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:livin_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:livin_app/features/listings/data/data_sources/remote/listings_remote_data_source.dart';
import 'package:livin_app/features/listings/domain/repositories/listings_repository.dart';
import 'package:livin_app/features/listings/presentation/blocs/listings_bloc/listings_bloc.dart';

final GetIt sl = GetIt.instance;

void setupDependencies() {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(remoteDataSource: sl()),
  );
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(repository: sl()),
  );
    sl.registerLazySingleton<ListingsRemoteDataSource>(
    () => ListingsRemoteDataSource(),
  );
  sl.registerLazySingleton<ListingsRepository>(
    () => ListingsRepository(remoteDataSource: sl()),
  );
  sl.registerFactory<ListingsBloc>(
    () => ListingsBloc(repository: sl()),
  );
}