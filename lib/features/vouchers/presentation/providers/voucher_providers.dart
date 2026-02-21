import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/network_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/vouchers/data/datasources/voucher_remote_datasource.dart';
import 'package:flutter_riverpod_clean_architecture/features/vouchers/data/repositories/voucher_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/vouchers/domain/entities/voucher_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/vouchers/domain/repositories/voucher_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/datasources/authenticated_api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';

final _authenticatedApiClientProvider = Provider<AuthenticatedApiClient>((ref) {
  return AuthenticatedApiClient(secureStorage: ref.read(secureStorageProvider));
});

final voucherRemoteDataSourceProvider = Provider<VoucherRemoteDataSource>((
  ref,
) {
  return VoucherRemoteDataSourceImpl(
    client: ref.read(_authenticatedApiClientProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

final voucherRepositoryProvider = Provider<VoucherRepository>((ref) {
  return VoucherRepositoryImpl(
    remoteDataSource: ref.read(voucherRemoteDataSourceProvider),
  );
});

/// Fetches "My Vouchers" (purchased by the user).
/// Invalidate to re-fetch after a redeem.
final myVouchersProvider = FutureProvider.autoDispose<List<VoucherEntity>>((
  ref,
) async {
  final repo = ref.read(voucherRepositoryProvider);
  final result = await repo.getMyVouchers();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (vouchers) => vouchers,
  );
});

/// Fetches vouchers redeemed by the user.
final redeemedVouchersProvider =
    FutureProvider.autoDispose<List<VoucherEntity>>((ref) async {
      final repo = ref.read(voucherRepositoryProvider);
      final result = await repo.getRedeemedVouchers();
      return result.fold(
        (failure) => throw Exception(failure.message),
        (vouchers) => vouchers,
      );
    });
