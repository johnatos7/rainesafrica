import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/repositories/notification_repository.dart';

class GetNotificationByIdUseCase
    implements UseCase<NotificationEntity, GetNotificationByIdParams> {
  final NotificationRepository _repository;

  GetNotificationByIdUseCase({required NotificationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, NotificationEntity>> call(
    GetNotificationByIdParams params,
  ) async {
    try {
      final result = await _repository.getNotificationById(
        params.notificationId,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

class GetNotificationByIdParams {
  final String notificationId;

  GetNotificationByIdParams({required this.notificationId});
}
