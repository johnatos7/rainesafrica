import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/features/legal/domain/entities/legal_document_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/legal/domain/repositories/legal_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/legal/data/datasources/legal_remote_datasource.dart';

class LegalRepositoryImpl implements LegalRepository {
  final LegalRemoteDataSource remoteDataSource;

  LegalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, LegalDocumentsResponseEntity>> getLegalDocuments({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await remoteDataSource.getLegalDocuments(
        page: page,
        perPage: perPage,
      );
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}
