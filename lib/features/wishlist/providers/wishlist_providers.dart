import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/data/datasources/wishlist_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/data/datasources/wishlist_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/usecases/get_wishlists_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/usecases/create_wishlist_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/usecases/add_to_wishlist_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/usecases/remove_from_wishlist_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/usecases/rename_wishlist_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/usecases/delete_wishlist_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/usecases/move_to_wishlist_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';

// Data Sources
final wishlistLocalDataSourceProvider = Provider<WishlistLocalDataSource>((
  ref,
) {
  return WishlistLocalDataSourceImpl();
});

final wishlistRemoteDataSourceProvider = Provider<WishlistRemoteDataSource>((
  ref,
) {
  return WishlistRemoteDataSourceImpl();
});

// Repository
final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final localDataSource = ref.watch(wishlistLocalDataSourceProvider);
  final remoteDataSource = ref.watch(wishlistRemoteDataSourceProvider);
  return WishlistRepositoryImpl(localDataSource, remoteDataSource);
});

// Use Cases
final getWishlistsUseCaseProvider = Provider<GetWishlistsUseCase>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return GetWishlistsUseCase(repository);
});

final createWishlistUseCaseProvider = Provider<CreateWishlistUseCase>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return CreateWishlistUseCase(repository);
});

final addToWishlistUseCaseProvider = Provider<AddToWishlistUseCase>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return AddToWishlistUseCase(repository);
});

final removeFromWishlistUseCaseProvider = Provider<RemoveFromWishlistUseCase>((
  ref,
) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return RemoveFromWishlistUseCase(repository);
});

final renameWishlistUseCaseProvider = Provider<RenameWishlistUseCase>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return RenameWishlistUseCase(repository);
});

final deleteWishlistUseCaseProvider = Provider<DeleteWishlistUseCase>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return DeleteWishlistUseCase(repository);
});

final moveToWishlistUseCaseProvider = Provider<MoveToWishlistUseCase>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return MoveToWishlistUseCase(repository);
});

// State Providers
final wishlistsProvider = FutureProvider<List<WishlistEntity>>((ref) async {
  final useCase = ref.watch(getWishlistsUseCaseProvider);
  return await useCase();
});

final wishlistByIdProvider = FutureProvider.family<WishlistEntity, String>((
  ref,
  id,
) async {
  final repository = ref.watch(wishlistRepositoryProvider);
  return await repository.getWishlistById(id);
});

final isProductInWishlistProvider = FutureProvider.family<bool, String>((
  ref,
  productId,
) async {
  final repository = ref.watch(wishlistRepositoryProvider);
  return await repository.isProductInWishlist(productId);
});

final isProductInSpecificWishlistProvider =
    FutureProvider.family<bool, ({String productId, String wishlistId})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(wishlistRepositoryProvider);
      return await repository.isProductInWishlist(
        params.productId,
        wishlistId: params.wishlistId,
      );
    });

// Action Providers
final createWishlistProvider =
    FutureProvider.family<WishlistEntity, ({String name, String? description})>(
      (ref, params) async {
        final useCase = ref.watch(createWishlistUseCaseProvider);
        return await useCase(params.name, description: params.description);
      },
    );

final addToWishlistProvider = FutureProvider.family<
  WishlistEntity,
  ({String wishlistId, ProductEntity product, String? notes})
>((ref, params) async {
  final useCase = ref.watch(addToWishlistUseCaseProvider);
  return await useCase(params.wishlistId, params.product, notes: params.notes);
});

final removeFromWishlistProvider = FutureProvider.family<
  WishlistEntity,
  ({String wishlistId, String productId})
>((ref, params) async {
  final useCase = ref.watch(removeFromWishlistUseCaseProvider);
  return await useCase(params.wishlistId, params.productId);
});

final renameWishlistProvider =
    FutureProvider.family<void, ({String id, String newName})>((
      ref,
      params,
    ) async {
      final useCase = ref.watch(renameWishlistUseCaseProvider);
      return await useCase(params.id, params.newName);
    });

final deleteWishlistProvider = FutureProvider.family<void, String>((
  ref,
  id,
) async {
  final useCase = ref.watch(deleteWishlistUseCaseProvider);
  return await useCase(id);
});

final moveToWishlistProvider = FutureProvider.family<
  WishlistEntity,
  ({String productId, String fromWishlistId, String toWishlistId})
>((ref, params) async {
  final useCase = ref.watch(moveToWishlistUseCaseProvider);
  return await useCase(
    params.productId,
    params.fromWishlistId,
    params.toWishlistId,
  );
});

// Default wishlist provider
final defaultWishlistProvider = FutureProvider<WishlistEntity>((ref) async {
  final repository = ref.watch(wishlistRepositoryProvider);
  return await repository.getDefaultWishlist();
});
