import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/presentation/cubit/create_admin_cubit.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/domain/repositories/business_admin_repository.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/data/models/business_admin_request_model.dart';

// ===== MOCKS =====
class MockBusinessAdminRepository extends Mock implements BusinessAdminRepository {}

// ===== FAKES =====
class FakeBusinessAdminRequestModel extends Fake implements BusinessAdminRequestModel {}

void main() {
  late MockBusinessAdminRepository mockRepository;
  late CreateAdminCubit sut;

  const tFullName = 'John Doe';
  const tEmail = 'john@example.com';
  const tPhone = '0123456789';

  final tRequest = const BusinessAdminRequestModel(
    fullName: tFullName,
    email: tEmail,
    phone: tPhone,
  );

  setUpAll(() {
    registerFallbackValue(FakeBusinessAdminRequestModel());
  });

  setUp(() {
    mockRepository = MockBusinessAdminRepository();
    sut = CreateAdminCubit(repository: mockRepository);
  });

  tearDown(() {
    sut.close();
  });

  // ═══════════════════════════════════════════════════
  // STATE TRANSITION TESTING
  // ═══════════════════════════════════════════════════
  group('State Transitions - createAdmin', () {
    test('initial state should be CreateAdminInitial', () {
      expect(sut.state, isA<CreateAdminInitial>());
    });

    blocTest<CreateAdminCubit, CreateAdminState>(
      'ST-V1: should emit [Loading, Success] when createAdmin succeeds',
      build: () {
        when(() => mockRepository.createBusinessAdmin(any()))
            .thenAnswer((_) async => Future.value());
        return CreateAdminCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.createAdmin(tFullName, tEmail, tPhone),
      expect: () => [
        isA<CreateAdminLoading>(),
        const CreateAdminSuccess(message: 'Tạo tài khoản Business Admin thành công.'),
      ],
      verify: (_) {
        verify(() => mockRepository.createBusinessAdmin(tRequest)).called(1);
      },
    );

    blocTest<CreateAdminCubit, CreateAdminState>(
      'ST-V2: should emit [Loading, Failure] when createAdmin throws Exception',
      build: () {
        when(() => mockRepository.createBusinessAdmin(any()))
            .thenThrow(Exception('Email already exists'));
        return CreateAdminCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.createAdmin(tFullName, tEmail, tPhone),
      expect: () => [
        isA<CreateAdminLoading>(),
        const CreateAdminFailure(error: 'Email already exists'),
      ],
      verify: (_) {
        verify(() => mockRepository.createBusinessAdmin(tRequest)).called(1);
      },
    );

    blocTest<CreateAdminCubit, CreateAdminState>(
      'ST-I1: should not emit new states if already in Loading state (Concurrency Guard)',
      build: () {
        when(() => mockRepository.createBusinessAdmin(any()))
            .thenAnswer((_) async => Future.value());
        return CreateAdminCubit(repository: mockRepository);
      },
      seed: () => CreateAdminLoading(),
      act: (cubit) => cubit.createAdmin(tFullName, tEmail, tPhone),
      expect: () => [], // Should not emit anything
      verify: (_) {
        verifyNever(() => mockRepository.createBusinessAdmin(any()));
      },
    );
  });

  // ═══════════════════════════════════════════════════
  // EQUIVALENCE PARTITIONING & BOUNDARY (Whitespace Handling)
  // ═══════════════════════════════════════════════════
  group('Equivalence Partitioning & Input Formatting', () {
    blocTest<CreateAdminCubit, CreateAdminState>(
      'EP/BVA: should trim whitespace from all inputs before passing to repository',
      build: () {
        when(() => mockRepository.createBusinessAdmin(any()))
            .thenAnswer((_) async => Future.value());
        return CreateAdminCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.createAdmin(
        '  John Doe  ',
        '\tjohn@example.com\n',
        ' 0123456789 ',
      ),
      expect: () => [
        isA<CreateAdminLoading>(),
        isA<CreateAdminSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepository.createBusinessAdmin(
          const BusinessAdminRequestModel(
            fullName: 'John Doe',
            email: 'john@example.com',
            phone: '0123456789',
          ),
        )).called(1);
      },
    );
  });

  // ═══════════════════════════════════════════════════
  // ERROR GUESSING
  // ═══════════════════════════════════════════════════
  group('Error Guessing', () {
    blocTest<CreateAdminCubit, CreateAdminState>(
      'EG-01: should handle empty string inputs gracefully and pass trimmed empty strings to repository',
      build: () {
        when(() => mockRepository.createBusinessAdmin(any()))
            .thenAnswer((_) async => Future.value());
        return CreateAdminCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.createAdmin('', '', ''),
      expect: () => [
        isA<CreateAdminLoading>(),
        isA<CreateAdminSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepository.createBusinessAdmin(
          const BusinessAdminRequestModel(
            fullName: '',
            email: '',
            phone: '',
          ),
        )).called(1);
      },
    );
  });
}
