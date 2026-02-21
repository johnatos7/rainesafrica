import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/repositories/notification_repository.dart';

class MarkNotificationAsReadUseCase
    implements UseCase<void, MarkNotificationAsReadParams> {
  final NotificationRepository _repository;

  MarkNotificationAsReadUseCase({required NotificationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, void>> call(
    MarkNotificationAsReadParams params,
  ) async {
    try {
      await _repository.markNotificationAsRead(params.notificationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

class MarkNotificationAsReadParams {
  final String notificationId;

  MarkNotificationAsReadParams({required this.notificationId});
}
