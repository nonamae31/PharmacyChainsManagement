import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_chains_management_fe/features/founder_admin/domain/entities/business_admin_entity.dart';

void main() {
  group('👑 Founder Admin Unit Test - BusinessAdminEntity', () {
    test('copyWith() tạo ra một bản sao mới với các thuộc tính được cập nhật mà không thay đổi đối tượng gốc', () {
      const originalAdmin = BusinessAdminEntity(
        id: 'ADMIN-001',
        name: 'Nguyễn Văn Hùng',
        email: 'hung.nv@pharmacy.vn',
        status: 'Active',
        phone: '0901234567',
      );

      final updatedAdmin = originalAdmin.copyWith(
        status: 'Inactive',
        phone: '0988888888',
      );

      // Đối tượng mới đã thay đổi trạng thái và số điện thoại
      expect(updatedAdmin.status, equals('Inactive'));
      expect(updatedAdmin.phone, equals('0988888888'));
      // Các thuộc tính khác vẫn giữ nguyên
      expect(updatedAdmin.id, equals(originalAdmin.id));
      expect(updatedAdmin.name, equals(originalAdmin.name));
      expect(updatedAdmin.email, equals(originalAdmin.email));
      // Đối tượng cũ không bị ảnh hưởng (bất biến - immutable)
      expect(originalAdmin.status, equals('Active'));
    });
  });
}
