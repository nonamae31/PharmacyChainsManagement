import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:pharmacy_chains_management_fe/core/error/failures.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/data/models/business_admin_request_model.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/domain/repositories/business_admin_repository.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/domain/usecases/update_business_admin_usecase.dart';

class MockBusinessAdminRepository extends Mock implements BusinessAdminRepository {}
class FakeBusinessAdminRequestModel extends Fake implements BusinessAdminRequestModel {}

void main() {
  late MockBusinessAdminRepository mockRepository;
  late UpdateBusinessAdminUseCase sut;

  setUpAll(() {
    registerFallbackValue(FakeBusinessAdminRequestModel());
  });

  setUp(() {
    mockRepository = MockBusinessAdminRepository();
    sut = UpdateBusinessAdminUseCase(mockRepository);
  });

  const tId = '123';
  const tName = 'John Doe';
  const tPhone = '0123456789';
  const tEmail = 'john@example.com';
  
  const tParams = UpdateBusinessAdminParams(id: tId, name: tName, phone: tPhone, email: tEmail);
  
  const tRequestModel = BusinessAdminRequestModel(
    fullName: tName,
    email: tEmail,
    phone: tPhone,
  );

  group('UpdateBusinessAdminUseCase', () {
    // ═══════════════════════════════════════════════════
    // HAPPY PATH & USE CASE
    // ═══════════════════════════════════════════════════
    test('HP-01: should call updateBusinessAdmin on the repository with correct data', () async {
      // Arrange
      when(() => mockRepository.updateBusinessAdmin(any(), any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await sut(tParams);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.updateBusinessAdmin(tId, tRequestModel)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    // ═══════════════════════════════════════════════════
    // EQUIVALENCE PARTITIONING & BOUNDARY
    // ═══════════════════════════════════════════════════
    test('EP/BVA: should handle null email in params and convert to empty string', () async {
      // Arrange
      const tParamsWithoutEmail = UpdateBusinessAdminParams(id: tId, name: tName, phone: tPhone, email: null);
      const tRequestModelEmptyEmail = BusinessAdminRequestModel(
        fullName: tName,
        email: '',
        phone: tPhone,
      );
      
      when(() => mockRepository.updateBusinessAdmin(any(), any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await sut(tParamsWithoutEmail);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.updateBusinessAdmin(tId, tRequestModelEmptyEmail)).called(1);
    });

    // ═══════════════════════════════════════════════════
    // SAD PATH
    // ═══════════════════════════════════════════════════
    test('SP-01: should return Failure when repository fails', () async {
      // Arrange
      when(() => mockRepository.updateBusinessAdmin(any(), any()))
          .thenAnswer((_) async => const Left(ServerFailure('Server Error')));

      // Act
      final result = await sut(tParams);

      // Assert
      expect(result, const Left(ServerFailure('Server Error')));
      verify(() => mockRepository.updateBusinessAdmin(tId, tRequestModel)).called(1);
    });
  });
}
