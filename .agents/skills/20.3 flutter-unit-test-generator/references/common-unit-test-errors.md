# Common Flutter Unit Test Mistakes & Fixes

Tài liệu tham khảo nhanh cho Coder Agent khi gặp lỗi khi viết unit test Flutter.

---

## 1. Lỗi Mock Setup

### Lỗi: `MissingStubError`
```
MissingStubError: 'fetchData'
No stub was found which matches the arguments of this method call
```

**Nguyên nhân**: Quên stub method trên mock object.

**Fix**:
```dart
// ❌ Thiếu stub
final mock = MockRepository();
sut = MyBloc(repository: mock);
sut.add(LoadEvent()); // → MissingStubError

// ✅ Thêm stub trước khi dùng
when(() => mock.fetchData()).thenAnswer((_) async => []);
```

---

### Lỗi: `type 'Null' is not a subtype of type 'Future<List<T>>'`
**Nguyên nhân**: Dùng `mockito` mà quên `@GenerateMocks` hoặc chưa build runner.

**Fix**: Chuyển sang `mocktail` (không cần code generation):
```dart
// ✅ mocktail — đơn giản hơn
class MockRepo extends Mock implements MyRepository {}
```

---

## 2. Lỗi BLoC Test

### Lỗi: `blocTest` không emit state mong đợi
```
Expected: [isA<Loading>, isA<Loaded>]
Actual:   []
```

**Nguyên nhân phổ biến**:
1. Event handler là `async` nhưng chưa `await` trong `act`
2. BLoC đã bị `close()` trước khi emit

**Fix**:
```dart
blocTest<MyBloc, MyState>(
  'fix: wait for event processing',
  build: () => MyBloc(repository: mockRepo),
  act: (bloc) async {
    bloc.add(LoadEvent());
    await Future.delayed(Duration.zero); // cho event handler chạy xong
  },
  wait: const Duration(milliseconds: 300), // hoặc dùng wait
  expect: () => [isA<Loading>(), isA<Loaded>()],
);
```

---

### Lỗi: `Bad state: Cannot add new events after calling close`
**Nguyên nhân**: `tearDown` gọi `bloc.close()` trước khi `blocTest` kết thúc.

**Fix**: Để `blocTest` tự quản lý lifecycle:
```dart
// ❌ 
late MyBloc sut;
setUp(() => sut = MyBloc());
tearDown(() => sut.close());

blocTest<MyBloc, MyState>(
  'test name',
  build: () => sut, // sut bị close bởi tearDown
);

// ✅ Tạo mới trong build
blocTest<MyBloc, MyState>(
  'test name',
  build: () => MyBloc(repository: mockRepo), // tạo mới mỗi test
);
```

---

## 3. Lỗi Async Test

### Lỗi: Test pass nhưng assertion không chạy
```dart
// ❌ Quên await
test('should fetch data', () {
  final result = sut.fetchData(); // Future chưa được await
  expect(result, isNotNull); // So sánh Future object, không phải result
});

// ✅ Await đúng
test('should fetch data', () async {
  final result = await sut.fetchData();
  expect(result, isNotNull);
});
```

---

### Lỗi: `Pending timers` / `Outstanding microtasks`
**Nguyên nhân**: Có Timer hoặc debounce trong code mà test không xử lý.

**Fix**:
```dart
test('should debounce search', () {
  fakeAsync((async) {
    sut.search('query');
    async.elapse(Duration(milliseconds: 500)); // fast-forward timer
    expect(sut.results, isNotEmpty);
  });
});
```

---

## 4. Lỗi registerFallbackValue

### Lỗi: `type 'Null' is not a subtype of type 'MyModel' in type cast`
**Nguyên nhân**: Dùng `any()` với non-nullable type mà chưa register fallback.

**Fix**:
```dart
class FakeMyModel extends Fake implements MyModel {}

setUpAll(() {
  registerFallbackValue(FakeMyModel());
});

// Giờ có thể dùng any()
when(() => mockRepo.save(any())).thenAnswer((_) async => true);
```

---

## 5. Lỗi Test Isolation

### Lỗi: Test chạy riêng pass, chạy chung fail
**Nguyên nhân**: State leak giữa các test (shared mutable variable).

**Fix**: Luôn tạo mới trong `setUp()`:
```dart
// ❌ Shared state
final sut = MyService();

// ✅ Fresh instance mỗi test
late MyService sut;
setUp(() {
  sut = MyService();
});
```

---

## 6. Lỗi Coverage

### Coverage report thiếu file
**Nguyên nhân**: File không có test nào import nó.

**Fix**: Tạo file `test/coverage_helper_test.dart`:
```dart
// Đảm bảo tất cả file được bao gồm trong coverage
import 'package:app/feature_a/service.dart';
import 'package:app/feature_b/repository.dart';
// ... import tất cả file cần cover

void main() {}
```

---

## 7. Quick Reference — Matcher phổ biến

```dart
// Equality
expect(result, equals(expected));
expect(result, isNot(equals(other)));

// Type checking
expect(result, isA<MyType>());
expect(result, isNull);
expect(result, isNotNull);

// Collections
expect(list, isEmpty);
expect(list, isNotEmpty);
expect(list, hasLength(5));
expect(list, contains(item));
expect(list, containsAll([a, b, c]));

// Exceptions
expect(() => sut.method(), throwsA(isA<NotFoundException>()));
expect(() => sut.method(), throwsArgumentError);
expect(() => sut.method(), throwsStateError);

// Async
expect(sut.asyncMethod(), completion(equals(expected)));
expect(sut.asyncMethod(), throwsA(isA<Exception>()));

// String
expect(result, startsWith('Hello'));
expect(result, endsWith('World'));
expect(result, contains('middle'));
expect(result, matches(RegExp(r'^\d+$')));

// Numeric
expect(result, greaterThan(5));
expect(result, lessThanOrEqualTo(10));
expect(result, inInclusiveRange(1, 100));
expect(result, closeTo(3.14, 0.01)); // cho double

// BLoC specific
expect(bloc.state, isA<LoadedState>());
```
