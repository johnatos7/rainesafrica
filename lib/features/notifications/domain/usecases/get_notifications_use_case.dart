import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase
    implements UseCase<NotificationListResponse, GetNotificationsParams> {
  final NotificationRepository _repository;

  GetNotificationsUseCase({required NotificationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, NotificationListResponse>> call(
    GetNotificationsParams params,
  ) async {
    try {
      final result = await _repository.getNotifications(page: params.page);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

class GetNotificationsParams {
  final int page;

  GetNotificationsParams({required this.page});
}
