import 'package:flutter/material.dart';
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
  // Map storing our 3 required photos: 'front', 'back', 'label'
  final Map<String, String> _photos = {};

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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.photo_camera, color: AppColors.primary, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tải ảnh / Chụp ảnh: $title',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: const Text('📷 Chụp ảnh trực tiếp từ Camera', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Kích hoạt Camera để chụp hình thực tế ngay tại kho'),
                onTap: () {
                  Navigator.pop(ctx);
                  _simulateCaptureWithEffect(key, title, isCamera: true);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.photo_library, color: AppColors.secondary),
                ),
                title: const Text('🖼️ Chọn ảnh từ thư viện thiết bị', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Tải lên tệp hình ảnh có sẵn (JPG, PNG, WEBP)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _simulateCaptureWithEffect(key, title, isCamera: false);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.verified, color: AppColors.success),
                ),
                title: const Text('⚡ Sử dụng ảnh mẫu xác minh GSP chuẩn', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Tự động điền hình ảnh kiểm định mẫu từ hệ thống để kiểm thử'),
                onTap: () {
                  Navigator.pop(ctx);
                  _setSamplePhoto(key);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _simulateCaptureWithEffect(String key, String title, {required bool isCamera}) {
    // Show a quick visual loading/capturing effect
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                isCamera ? '📸 Đang chụp ảnh $title...' : '🖼️ Đang tải ảnh $title lên...',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        Navigator.pop(context); // close dialog
        _setSamplePhoto(key);
      }
    });
  }

  void _setSamplePhoto(String key) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      if (key == 'front') {
        _photos['front'] = 'IMG_${timestamp}_FrontBox.jpg';
      } else if (key == 'back') {
        _photos['back'] = 'IMG_${timestamp}_BackBox_Dosage.jpg';
      } else if (key == 'label') {
        _photos['label'] = 'IMG_${timestamp}_Label_Batch_GS1.jpg';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Đã đính kèm hình ảnh cho ô ${key.toUpperCase()}!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.camera_alt, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📸 Gửi ảnh xác minh',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        widget.medicineTitle,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
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
                        TextSpan(text: 'Theo quy chuẩn GSP, vui lòng chụp/tải lên '),
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
                          content: Text('⚠️ Vui lòng chụp/tải lên đầy đủ 3 ảnh (Medicine front, back, và label photo) trước khi gửi!'),
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
    final fileName = hasPhoto ? _photos[keyName]! : null;

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
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image_rounded, color: Color(0xFF16A34A), size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName ?? 'IMG_Verification.jpg',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              const Text('Đạt chuẩn GSP • High Resolution (2.1 MB)', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
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
                        const Icon(Icons.add_a_photo_outlined, color: Color(0xFF2563EB), size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'Chụp/Tải lên $title',
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
