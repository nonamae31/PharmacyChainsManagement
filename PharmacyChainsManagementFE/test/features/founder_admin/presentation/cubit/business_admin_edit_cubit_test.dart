import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:pharmacy_chains_management_fe/core/error/failures.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/domain/usecases/update_business_admin_usecase.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/presentation/cubit/business_admin_edit_cubit.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/presentation/cubit/business_admin_edit_state.dart';

class MockUpdateBusinessAdminUseCase extends Mock implements UpdateBusinessAdminUseCase {}
class FakeUpdateBusinessAdminParams extends Fake implements UpdateBusinessAdminParams {}

void main() {
  late MockUpdateBusinessAdminUseCase mockUseCase;
  late BusinessAdminEditCubit sut;

  const tId = '123';
  const tName = 'John Doe';
  const tPhone = '0123456789';
  const tEmail = 'john@example.com';
  const tParams = UpdateBusinessAdminParams(id: tId, name: tName, phone: tPhone, email: tEmail);

  setUpAll(() {
    registerFallbackValue(FakeUpdateBusinessAdminParams());
  });

  setUp(() {
    mockUseCase = MockUpdateBusinessAdminUseCase();
    sut = BusinessAdminEditCubit(updateBusinessAdminUseCase: mockUseCase);
  });

  tearDown(() {
    sut.close();
  });

  group('State Transitions - updateBusinessAdmin', () {
    test('initial state should be BusinessAdminEditInitial', () {
      expect(sut.state, isA<BusinessAdminEditInitial>());
    });

    blocTest<BusinessAdminEditCubit, BusinessAdminEditState>(
      'ST-V1: should emit [Loading, Success] when update is successful',
      build: () {
        when(() => mockUseCase(any())).thenAnswer((_) async => const Right(null));
        return BusinessAdminEditCubit(updateBusinessAdminUseCase: mockUseCase);
      },
      act: (cubit) => cubit.updateBusinessAdmin(id: tId, name: tName, phone: tPhone, email: tEmail),
      expect: () => [
        isA<BusinessAdminEditLoading>(),
        const BusinessAdminEditSuccess(message: 'Cập nhật tài khoản thành công.'),
      ],
      verify: (_) {
        verify(() => mockUseCase(tParams)).called(1);
      },
    );

    blocTest<BusinessAdminEditCubit, BusinessAdminEditState>(
      'ST-V2: should emit [Loading, Error] when update fails with Failure',
      build: () {
        when(() => mockUseCase(any())).thenAnswer((_) async => const Left(ServerFailure('Server error')));
        return BusinessAdminEditCubit(updateBusinessAdminUseCase: mockUseCase);
      },
      act: (cubit) => cubit.updateBusinessAdmin(id: tId, name: tName, phone: tPhone, email: tEmail),
      expect: () => [
        isA<BusinessAdminEditLoading>(),
        const BusinessAdminEditError(message: 'Server error'),
      ],
      verify: (_) {
        verify(() => mockUseCase(tParams)).called(1);
      },
    );

    blocTest<BusinessAdminEditCubit, BusinessAdminEditState>(
      'ST-V3: should emit [Loading, Error] when use case throws exception',
      build: () {
        when(() => mockUseCase(any())).thenThrow(Exception('Unknown Error'));
        return BusinessAdminEditCubit(updateBusinessAdminUseCase: mockUseCase);
      },
      act: (cubit) => cubit.updateBusinessAdmin(id: tId, name: tName, phone: tPhone, email: tEmail),
      expect: () => [
        isA<BusinessAdminEditLoading>(),
        const BusinessAdminEditError(message: 'Đã có lỗi xảy ra: Exception: Unknown Error'),
      ],
    );

    blocTest<BusinessAdminEditCubit, BusinessAdminEditState>(
      'ST-I1: should not emit new states if already in Loading state',
      build: () {
        when(() => mockUseCase(any())).thenAnswer((_) async => const Right(null));
        return BusinessAdminEditCubit(updateBusinessAdminUseCase: mockUseCase);
      },
      seed: () => BusinessAdminEditLoading(),
      act: (cubit) => cubit.updateBusinessAdmin(id: tId, name: tName, phone: tPhone, email: tEmail),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockUseCase(any()));
      },
    );
  });

  group('Equivalence Partitioning & Input Formatting', () {
    blocTest<BusinessAdminEditCubit, BusinessAdminEditState>(
      'EP/BVA: should trim whitespace from all string inputs before passing to usecase',
      build: () {
        when(() => mockUseCase(any())).thenAnswer((_) async => const Right(null));
        return BusinessAdminEditCubit(updateBusinessAdminUseCase: mockUseCase);
      },
      act: (cubit) => cubit.updateBusinessAdmin(
        id: tId,
        name: '  John Doe  ',
        phone: ' 0123456789 ',
        email: '\tjohn@example.com\n',
      ),
      expect: () => [
        isA<BusinessAdminEditLoading>(),
        isA<BusinessAdminEditSuccess>(),
      ],
      verify: (_) {
        verify(() => mockUseCase(
          const UpdateBusinessAdminParams(
            id: tId,
            name: 'John Doe',
            phone: '0123456789',
            email: 'john@example.com',
          ),
        )).called(1);
      },
    );
  });
}
