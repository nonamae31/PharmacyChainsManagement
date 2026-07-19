import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:pharmacy_chains_management_fe/core/error/failures.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/domain/entities/business_admin_entity.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/domain/repositories/business_admin_repository.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/presentation/cubit/business_admin_cubit.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/presentation/cubit/business_admin_state.dart';

class MockBusinessAdminRepository extends Mock implements BusinessAdminRepository {}

void main() {
  late MockBusinessAdminRepository mockRepository;
  late BusinessAdminCubit sut;

  final tActiveAdmin = const BusinessAdminEntity(
    id: '1',
    name: 'Active Admin',
    email: 'active@test.com',
    status: 'Active',
    phone: '0123456789',
  );

  final tDeactivatedAdmin = const BusinessAdminEntity(
    id: '2',
    name: 'Deact Admin',
    email: 'deact@test.com',
    status: 'Deactivated',
    phone: '0987654321',
  );

  final List<BusinessAdminEntity> tAdmins = [tActiveAdmin, tDeactivatedAdmin];

  setUp(() {
    mockRepository = MockBusinessAdminRepository();
    sut = BusinessAdminCubit(repository: mockRepository);
  });

  tearDown(() {
    sut.close();
  });

  group('State Transitions - fetchBusinessAdmins', () {
    test('initial state should be BusinessAdminInitial', () {
      expect(sut.state, isA<BusinessAdminInitial>());
    });

    blocTest<BusinessAdminCubit, BusinessAdminState>(
      'ST-V1: should emit [Loading, Loaded] when fetch succeeds',
      build: () {
        when(() => mockRepository.getBusinessAdmins(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => tAdmins);
        return BusinessAdminCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.fetchBusinessAdmins(),
      expect: () => [
        isA<BusinessAdminLoading>(),
        BusinessAdminLoaded(allAdmins: tAdmins),
      ],
      verify: (_) {
        verify(() => mockRepository.getBusinessAdmins(forceRefresh: false)).called(1);
      },
    );

    blocTest<BusinessAdminCubit, BusinessAdminState>(
      'ST-V2: should emit [Loading, Error] when fetch fails',
      build: () {
        when(() => mockRepository.getBusinessAdmins(forceRefresh: any(named: 'forceRefresh')))
            .thenThrow(Exception('Server error'));
        return BusinessAdminCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.fetchBusinessAdmins(forceRefresh: true),
      expect: () => [
        isA<BusinessAdminLoading>(),
        const BusinessAdminError(message: 'Exception: Server error'),
      ],
      verify: (_) {
        verify(() => mockRepository.getBusinessAdmins(forceRefresh: true)).called(1);
      },
    );
  });

  group('Decision Table - Admin Filter & Sorting', () {
    blocTest<BusinessAdminCubit, BusinessAdminState>(
      'DT-01: should filter active admins correctly',
      build: () {
        when(() => mockRepository.getBusinessAdmins(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => tAdmins);
        return BusinessAdminCubit(repository: mockRepository);
      },
      seed: () => BusinessAdminLoaded(allAdmins: tAdmins),
      act: (cubit) => cubit.setFilter(AdminFilter.active),
      expect: () => [
        BusinessAdminLoaded(allAdmins: tAdmins, filter: AdminFilter.active),
      ],
      verify: (cubit) {
        expect((cubit.state as BusinessAdminLoaded).admins, [tActiveAdmin]);
      },
    );

    blocTest<BusinessAdminCubit, BusinessAdminState>(
      'DT-02: should filter deactivated admins correctly',
      build: () {
        when(() => mockRepository.getBusinessAdmins(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => tAdmins);
        return BusinessAdminCubit(repository: mockRepository);
      },
      seed: () => BusinessAdminLoaded(allAdmins: tAdmins),
      act: (cubit) => cubit.setFilter(AdminFilter.deactivated),
      expect: () => [
        BusinessAdminLoaded(allAdmins: tAdmins, filter: AdminFilter.deactivated),
      ],
      verify: (cubit) {
        expect((cubit.state as BusinessAdminLoaded).admins, [tDeactivatedAdmin]);
      },
    );

    blocTest<BusinessAdminCubit, BusinessAdminState>(
      'DT-03: should filter all admins correctly',
      build: () {
        when(() => mockRepository.getBusinessAdmins(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => tAdmins);
        return BusinessAdminCubit(repository: mockRepository);
      },
      seed: () => BusinessAdminLoaded(allAdmins: tAdmins, filter: AdminFilter.active),
      act: (cubit) => cubit.setFilter(AdminFilter.all),
      expect: () => [
        BusinessAdminLoaded(allAdmins: tAdmins, filter: AdminFilter.all),
      ],
      verify: (cubit) {
        expect((cubit.state as BusinessAdminLoaded).admins, tAdmins);
      },
    );
    
    blocTest<BusinessAdminCubit, BusinessAdminState>(
      'ST-I1: should not change state if setFilter is called but state is not Loaded',
      build: () => BusinessAdminCubit(repository: mockRepository),
      seed: () => BusinessAdminLoading(),
      act: (cubit) => cubit.setFilter(AdminFilter.active),
      expect: () => [],
    );
  });

  group('State Transitions & Optimistic UI - softDeleteBusinessAdmin', () {
    blocTest<BusinessAdminCubit, BusinessAdminState>(
      'HP-01: should optimistic update and not emit further if repository succeeds',
      build: () {
        when(() => mockRepository.softDeleteBusinessAdmin(any()))
            .thenAnswer((_) async => const Right(null));
        return BusinessAdminCubit(repository: mockRepository);
      },
      seed: () => BusinessAdminLoaded(allAdmins: tAdmins),
      act: (cubit) => cubit.softDeleteBusinessAdmin('1'),
      expect: () => [
        // Optimistic update removes '1'
        BusinessAdminLoaded(allAdmins: [tDeactivatedAdmin]),
      ],
      verify: (_) {
        verify(() => mockRepository.softDeleteBusinessAdmin('1')).called(1);
      },
    );

    blocTest<BusinessAdminCubit, BusinessAdminState>(
      'SP-01: should optimistic update then rollback if repository fails',
      build: () {
        when(() => mockRepository.softDeleteBusinessAdmin(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Lỗi server')));
        return BusinessAdminCubit(repository: mockRepository);
      },
      seed: () => BusinessAdminLoaded(allAdmins: tAdmins),
      act: (cubit) => cubit.softDeleteBusinessAdmin('1'),
      expect: () => [
        // Optimistic update removes '1'
        BusinessAdminLoaded(allAdmins: [tDeactivatedAdmin]),
        // Rollback restores original state
        BusinessAdminLoaded(allAdmins: tAdmins),
      ],
      verify: (_) {
        verify(() => mockRepository.softDeleteBusinessAdmin('1')).called(1);
      },
    );

    blocTest<BusinessAdminCubit, BusinessAdminState>(
      'ST-I2: should not execute if state is not BusinessAdminLoaded',
      build: () => BusinessAdminCubit(repository: mockRepository),
      seed: () => BusinessAdminInitial(),
      act: (cubit) => cubit.softDeleteBusinessAdmin('1'),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockRepository.softDeleteBusinessAdmin(any()));
      },
    );
  });
}
