import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/repositories/notification_repository.dart';

class MarkAllNotificationsAsReadUseCase implements UseCase<void, NoParams> {
  final NotificationRepository _repository;

  MarkAllNotificationsAsReadUseCase({
    required NotificationRepository repository,
  }) : _repository = repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      await _repository.markAllNotificationsAsRead();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
