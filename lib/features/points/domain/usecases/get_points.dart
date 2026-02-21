import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/domain/entities/points_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/domain/repositories/points_repository.dart';

class GetPoints {
  final PointsRepository repository;

  GetPoints({required this.repository});

  Future<({Failure? failure, PointsEntity? data})> call() async {
    return await repository.getPoints();
  }
}
