import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/legal/domain/entities/legal_document_entity.dart';

abstract class LegalRepository {
  Future<Either<Failure, LegalDocumentsResponseEntity>> getLegalDocuments({
    int page = 1,
    int perPage = 10,
  });
}
