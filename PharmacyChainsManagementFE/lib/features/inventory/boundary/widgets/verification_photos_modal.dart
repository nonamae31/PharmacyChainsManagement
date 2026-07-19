import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class VerificationPhotosModal extends StatefulWidget {
  final String medicineTitle;
  final Map<String, dynamic>? initialPhotos;
  final Function(Map<String, String> photos) onSubmitted;

  const VerificationPhotosModal({
    super.key,
    required this.medicineTitle,
    this.initialPhotos,
    required this.onSubmitted,
  });

  @override
  State<VerificationPhotosModal> createState() => _VerificationPhotosModalState();
}

class _VerificationPhotosModalState extends State<VerificationPhotosModal> {
  // Map storing path or file name: 'front', 'back', 'label'
  final Map<String, String> _photos = {};
  // Map storing binary data for immediate high-res preview
  final Map<String, Uint8List> _photoBytes = {};

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.initialPhotos != null) {
      if (widget.initialPhotos!['front'] != null) _photos['front'] = widget.initialPhotos!['front'].toString();
      if (widget.initialPhotos!['back'] != null) _photos['back'] = widget.initialPhotos!['back'].toString();
      if (widget.initialPhotos!['label'] != null) _photos['label'] = widget.initialPhotos!['label'].toString();
    }
  }

  void _captureOrSelectPhoto(String key, String title) {
    _pickFromGallery(key, title);
  }

  Future<void> _pickFromGallery(String key, String title) async {
    try {
      // First try file_picker for robust multi-platform PC / Mobile image picking
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        Uint8List? bytes = file.bytes;
        if (bytes == null && file.path != null && !kIsWeb) {
          bytes = await File(file.path!).readAsBytes();
        }

        setState(() {
          _photos[key] = file.path ?? file.name;
          if (bytes != null) {
            _photoBytes[key] = bytes;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🖼️ Đã chọn ảnh "${file.name}" cho ô ${key.toUpperCase()}!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('MissingPluginException')) {
        _showMissingPluginWarning();
        return;
      }

      // If file_picker fails for other reasons, fallback to image_picker gallery
      try {
        final XFile? photo = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 88,
        );
        if (photo != null) {
          final bytes = await photo.readAsBytes();
          setState(() {
            _photos[key] = photo.path.isNotEmpty ? photo.path : photo.name;
            _photoBytes[key] = bytes;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🖼️ Đã chọn ảnh cho ô ${key.toUpperCase()} thành công!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (err) {
        final errStr = err.toString();
        if (errStr.contains('MissingPluginException')) {
          _showMissingPluginWarning();
          return;
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ Lỗi chọn ảnh: $errStr'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showMissingPluginWarning() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.system_update_alt, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Yêu cầu Khởi động lại App', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Do hệ thống vừa cài đặt thêm thư viện gốc (C++/Native plugin) để truy cập Thư viện ảnh / File Explorer máy tính:\n\n'
          '👉 Hot Reload (r) hay Hot Restart (R) sẽ không tải được plugin gốc và báo lỗi MissingPluginException.\n\n'
          '⚠️ Vui lòng dừng hẳn ứng dụng (tắt terminal) và chạy lại lệnh:\n'
          'flutter run -d windows\n(hoặc flutter run trên thiết bị của bạn) để chọn ảnh thật từ máy nhé!',
          style: TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.textPrimary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Đã hiểu, tôi sẽ chạy lại flutter run'),
          ),
        ],
      ),
    );
  }

  bool get _isComplete => _photos.length == 3 && _photos.containsKey('front') && _photos.containsKey('back') && _photos.containsKey('label');

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.photo_library, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🖼️ Tải ảnh xác minh từ thiết bị',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text(
                            widget.medicineTitle,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF1E293B), height: 1.4),
                      children: [
                        TextSpan(text: 'Theo quy chuẩn GSP, vui lòng tải lên '),
                        TextSpan(text: 'đầy đủ 3 ảnh bắt buộc', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                        TextSpan(text: ' bên dưới để Business Admin kiểm duyệt lô hàng.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3 Boxes Scrollable Area
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildPhotoBox(
                    keyName: 'front',
                    title: 'Medicine front photo',
                    explanation: 'ảnh mặt trước hộp/vỉ thuốc',
                    icon: Icons.fullscreen_exit,
                  ),
                  const SizedBox(height: 14),
                  _buildPhotoBox(
                    keyName: 'back',
                    title: 'Medicine back photo',
                    explanation: 'ảnh mặt sau hộp/vỉ thuốc',
                    icon: Icons.flip_camera_android,
                  ),
                  const SizedBox(height: 14),
                  _buildPhotoBox(
                    keyName: 'label',
                    title: 'Medicine label photo',
                    explanation: 'ảnh tem/nhãn thuốc, tên thuốc, hạn dùng nếu có',
                    icon: Icons.qr_code_scanner,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          // Progress & Submit Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _isComplete ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _isComplete ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _isComplete ? Icons.check_circle : Icons.pending_actions,
                      color: _isComplete ? AppColors.success : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tiến độ: ${_photos.length}/3 ảnh bắt buộc',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _isComplete ? AppColors.success : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (!_isComplete)
                  const Text(
                    '⚠️ Cần đủ 3 ảnh',
                    style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isComplete
                  ? () {
                      widget.onSubmitted(_photos);
                      Navigator.pop(context);
                    }
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⚠️ Vui lòng tải lên đầy đủ 3 ảnh (Medicine front, back, và label photo) trước khi gửi!'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text(
                'Xác nhận & Gửi 3 ảnh xác minh',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isComplete ? AppColors.success : AppColors.divider,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoBox({
    required String keyName,
    required String title,
    required String explanation,
    required IconData icon,
  }) {
    final hasPhoto = _photos.containsKey(keyName) && _photos[keyName]!.isNotEmpty;
    final fileName = hasPhoto ? _photos[keyName]!.split(Platform.pathSeparator).last : null;
    final bytes = _photoBytes[keyName];

    return Container(
      decoration: BoxDecoration(
        color: hasPhoto ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasPhoto ? const Color(0xFF22C55E) : const Color(0xFFCBD5E1),
          width: hasPhoto ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: hasPhoto ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, size: 15, color: hasPhoto ? const Color(0xFF16A34A) : const Color(0xFF475569)),
                        const SizedBox(width: 6),
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: hasPhoto ? const Color(0xFF15803D) : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (hasPhoto)
                Row(
                  children: [
                    const Icon(Icons.verified, color: Color(0xFF16A34A), size: 18),
                    const SizedBox(width: 4),
                    const Text('Đã tải lên', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _photos.remove(keyName);
                          _photoBytes.remove(keyName);
                        });
                      },
                      child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Ý nghĩa (explanation)
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Row(
              children: [
                const Icon(Icons.arrow_right, size: 16, color: Color(0xFF64748B)),
                Expanded(
                  child: Text(
                    explanation,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF475569), fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Upload/Capture Box Content
          InkWell(
            onTap: () => _captureOrSelectPhoto(keyName, title),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: hasPhoto ? Colors.white : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasPhoto ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
                  style: BorderStyle.solid,
                ),
              ),
              child: hasPhoto
                  ? Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: bytes != null
                              ? Image.memory(bytes, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.image_rounded, color: Color(0xFF16A34A), size: 26))
                              : (!kIsWeb && _photos[keyName] != null && File(_photos[keyName]!).existsSync())
                                  ? Image.file(File(_photos[keyName]!), fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.image_rounded, color: Color(0xFF16A34A), size: 26))
                                  : const Icon(Icons.image_rounded, color: Color(0xFF16A34A), size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName ?? _photos[keyName] ?? 'IMG_Verification.jpg',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              const Text('Đã chọn hình ảnh thực tế từ thiết bị', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.cached, size: 14, color: Color(0xFF2563EB)),
                              SizedBox(width: 4),
                              Text('Đổi ảnh', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF2563EB), size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'Chọn ảnh từ thư viện: $title',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: Color(0xFF2563EB)),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
