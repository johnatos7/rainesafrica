import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/network_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/legal/data/datasources/legal_remote_datasource.dart';
import 'package:flutter_riverpod_clean_architecture/features/legal/data/repositories/legal_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/legal/domain/repositories/legal_repository.dart';

final legalRemoteDataSourceProvider = Provider<LegalRemoteDataSource>((ref) {
  return LegalRemoteDataSourceImpl(
    client: ref.read(apiClientProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

final legalRepositoryProvider = Provider<LegalRepository>((ref) {
  return LegalRepositoryImpl(
    remoteDataSource: ref.read(legalRemoteDataSourceProvider),
  );
});
