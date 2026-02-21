import 'package:flutter_riverpod_clean_architecture/features/repayment/domain/entities/repayment_request_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/repayment/domain/entities/repayment_response_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/repayment/domain/repositories/repayment_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/repayment/data/datasources/repayment_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/repayment/data/models/repayment_request_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/repayment/data/models/repayment_response_model.dart';

class RepaymentRepositoryImpl implements RepaymentRepository {
  final RepaymentRemoteDataSource _remoteDataSource;

  RepaymentRepositoryImpl({required RepaymentRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<RepaymentResponseEntity> processRepayment(
    RepaymentRequestEntity request,
  ) async {
    try {
      print('📦 REPAYMENT REPO: Starting repayment processing');

      final requestModel = RepaymentRequestModel.fromEntity(request);
      print('📦 REPAYMENT REPO: Request model created');

      final response = await _remoteDataSource.processRepayment(requestModel);
      print('📦 REPAYMENT REPO: Response received from remote data source');
      print('📦 REPAYMENT REPO: Response type: ${response.runtimeType}');

      print('📦 REPAYMENT REPO: Converting to model...');
      final model = RepaymentResponseModel.fromJson(response);
      print('📦 REPAYMENT REPO: Model created successfully');

      print('📦 REPAYMENT REPO: Converting to entity...');
      final entity = model.toEntity();
      print('✅ REPAYMENT REPO: Entity created successfully');

      return entity;
    } catch (e, stackTrace) {
      print('❌ REPAYMENT REPO: Error processing repayment: $e');
      print('❌ REPAYMENT REPO: Stack trace: $stackTrace');
      throw Exception('Failed to process repayment: $e');
    }
  }
}
