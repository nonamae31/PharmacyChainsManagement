import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class InventoryReportScreen extends StatefulWidget {
  const InventoryReportScreen({super.key});

  @override
  State<InventoryReportScreen> createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends State<InventoryReportScreen> {
  final List<Map<String, dynamic>> _categorySummary = [
    {'category': 'Antibiotics (Kháng sinh)', 'skuCount': 120, 'totalValue': '680,000,000 VNĐ', 'turnoverRate': '5.2x/year (năm)', 'status': 'Optimal (Tối ưu)'},
    {'category': 'Dietary Supplements / Vitamins (Thực phẩm chức năng)', 'skuCount': 85, 'totalValue': '410,000,000 VNĐ', 'turnoverRate': '4.1x/year (năm)', 'status': 'Optimal (Tối ưu)'},
    {'category': 'Analgesics & Antipyretics (Thuốc giảm đau & Hạ sốt)', 'skuCount': 64, 'totalValue': '290,000,000 VNĐ', 'turnoverRate': '6.8x/year (năm)', 'status': 'Optimal (Tối ưu)'},
    {'category': 'Medical Supplies & Bandages (Vật tư y tế)', 'skuCount': 42, 'totalValue': '160,000,000 VNĐ', 'turnoverRate': '3.5x/year (năm)', 'status': 'Review Needed (Cần rà soát)'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inventory Reports & Analytics (Báo cáo Thống kê & Định giá)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: AppColors.surface,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GSP Warehouse Summary Report (Báo Cáo Tổng Hợp Tình Trạng Kho Hàng GSP)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    SizedBox(height: 4),
                    Text('Reporting Period (Kỳ báo cáo): Q3/2026 (Unit: VNĐ)', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _exportToPdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                      label: const Text('Export PDF Report (Xuất báo cáo PDF)'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _exportToExcel,
                      icon: const Icon(Icons.table_chart_outlined, size: 18),
                      label: const Text('Export Excel Valuation (Xuất file Excel)'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(child: _buildMetricCard('Total Inventory Valuation (Tổng giá trị tồn kho)', '1,540,000,000 VNĐ', '+8.2% vs previous quarter (so với quý trước)', Icons.account_balance_wallet, AppColors.primary)),
                const SizedBox(width: 16),
                Expanded(child: _buildMetricCard('Inventory Turnover Rate (Vòng quay hàng tồn kho)', '4.8x / year (năm)', 'High turnover efficiency (Hiệu suất lưu thông cao)', Icons.autorenew, AppColors.success)),
                const SizedBox(width: 16),
                Expanded(child: _buildMetricCard('Average Days in Inventory (Số ngày lưu kho bình quân)', '28 days (ngày)', 'GSP compliant storage (Đạt chuẩn GSP)', Icons.calendar_today, AppColors.info)),
                const SizedBox(width: 16),
                Expanded(child: _buildMetricCard('Shrinkage / Expiry Rate (Tỷ lệ hao hụt / hết hạn)', '0.12 %', 'Below threshold (Thấp hơn mức cho phép 0.5%)', Icons.trending_down, AppColors.warning)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Category Valuation Breakdown (Phân tích Giá trị Tồn kho theo Nhóm Dược phẩm)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.md),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg), side: BorderSide(color: AppColors.border)),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 1050),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 250, child: _buildTableHeader('CATEGORY (NHÓM THUỐC)')),
                            SizedBox(width: 160, child: _buildTableHeader('SKU COUNT (SỐ LƯỢNG SKU)')),
                            SizedBox(width: 180, child: _buildTableHeader('TOTAL VALUE (TỔNG GIÁ TRỊ TỒN)')),
                            SizedBox(width: 180, child: _buildTableHeader('TURNOVER RATE (VÒNG QUAY HÀNG)')),
                            SizedBox(width: 240, child: _buildTableHeader('EVALUATION (ĐÁNH GIÁ)')),
                          ],
                        ),
                        const Divider(height: 24, color: AppColors.divider),
                        ..._categorySummary.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;
                          final isLast = idx == _categorySummary.length - 1;
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
                            child: Row(
                              children: [
                                SizedBox(width: 250, child: Text(item['category'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary))),
                                SizedBox(width: 160, child: Text('${item['skuCount']} SKUs (mã)', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))),
                                SizedBox(width: 180, child: Text(item['totalValue'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primaryDark))),
                                SizedBox(width: 180, child: Text(item['turnoverRate'], style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
                                SizedBox(
                                  width: 240,
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: item['status'].toString().contains('Optimal') ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(item['status'], style: TextStyle(color: item['status'].toString().contains('Optimal') ? AppColors.success : AppColors.warning, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg), side: BorderSide(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                Icon(icon, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5));
  }

  void _showExportDialog(BuildContext context, String title, String filePath) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text('Đã xuất $title thành công!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('File của bạn đã được lưu trực tiếp vào máy tính tại thư mục Downloads:', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFCBD5E1))),
              child: SelectableText(filePath, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontSize: 13)),
            ),
            const SizedBox(height: 16),
            const Text('Bạn có muốn mở file lên xem ngay bây giờ không?', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng (Close)', style: TextStyle(color: AppColors.textSecondary)),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              Process.run('cmd', ['/c', 'explorer', '/select,', filePath]);
            },
            icon: const Icon(Icons.folder_open, size: 18),
            label: const Text('Mở thư mục chứa (Open Folder)'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              Process.run('cmd', ['/c', 'start', '', filePath]);
            },
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Mở file ngay (Open File)'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToExcel() async {
    try {
      final buffer = StringBuffer();
      // UTF-8 BOM (\uFEFF) giúp Excel mở tiếng Việt chuẩn 100% không bị lỗi font
      buffer.write('\uFEFF');
      buffer.writeln('BÁO CÁO TỔNG HỢP & ĐỊNH GIÁ KHO HÀNG GSP - Q3/2026');
      buffer.writeln('Hệ thống: Chuỗi Nhà Thuốc Đạt Chuẩn GSP');
      buffer.writeln('Ngày xuất: ${DateTime.now().toString().substring(0, 19)}');
      buffer.writeln('Đơn vị tiền tệ: VNĐ');
      buffer.writeln();
      buffer.writeln('NHÓM THUỐC (CATEGORY),SỐ LƯỢNG SKU,TỔNG GIÁ TRỊ TỒN,VÒNG QUAY HÀNG,ĐÁNH GIÁ (STATUS)');

      for (var item in _categorySummary) {
        final cat = (item['category'] as String).replaceAll('"', '""');
        final skus = item['skuCount'];
        final val = (item['totalValue'] as String).replaceAll('"', '""');
        final turn = (item['turnoverRate'] as String).replaceAll('"', '""');
        final st = (item['status'] as String).replaceAll('"', '""');
        buffer.writeln('"$cat","$skus SKUs","$val","$turn","$st"');
      }

      if (kIsWeb) {
        final bytes = utf8.encode(buffer.toString());
        final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', 'Bao_Cao_Dinh_Gia_Kho_GSP_Q3_2026.csv')
          ..click();
        html.Url.revokeObjectUrl(url);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã tải file Excel (CSV): "Bao_Cao_Dinh_Gia_Kho_GSP_Q3_2026.csv" xuống trình duyệt thành công! Bạn có thể kiểm tra mục Downloads (Tải xuống).'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      final downloadsDir = Directory('C:\\\\Users\\\\hoang\\\\Downloads');
      if (!await downloadsDir.exists()) await downloadsDir.create(recursive: true);

      final filePath = 'C:\\\\Users\\\\hoang\\\\Downloads\\\\Bao_Cao_Dinh_Gia_Kho_GSP_Q3_2026.csv';
      final file = File(filePath);
      await file.writeAsString(buffer.toString(), flush: true);

      if (mounted) {
        _showExportDialog(context, 'file Excel (CSV)', filePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Lỗi xuất file: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _exportToPdf() async {
    try {
      final htmlContent = '''
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Báo Cáo Tổng Hợp Kho Hàng GSP - Q3/2026</title>
  <style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 40px; color: #1E293B; background: #F8FAFC; }
    .header { text-align: center; border-bottom: 3px solid #2563EB; padding-bottom: 20px; margin-bottom: 30px; }
    h1 { color: #1D4ED8; margin: 0; font-size: 26px; }
    .subtitle { color: #64748B; margin-top: 8px; font-size: 15px; }
    .metrics-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 30px; }
    .metric-card { background: white; padding: 18px; border-radius: 10px; border: 1px solid #E2E8F0; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
    .metric-title { font-size: 13px; color: #64748B; font-weight: 600; }
    .metric-value { font-size: 20px; color: #1E293B; font-weight: bold; margin: 8px 0; }
    .metric-sub { font-size: 12px; color: #10B981; }
    table { width: 100%; border-collapse: collapse; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.03); border: 1px solid #E2E8F0; }
    th { background: #2563EB; color: white; padding: 14px 16px; text-align: left; font-size: 14px; font-weight: 600; }
    td { padding: 14px 16px; border-bottom: 1px solid #F1F5F9; font-size: 14px; }
    tr:last-child td { border-bottom: none; }
    tr:nth-child(even) { background: #F8FAFC; }
    .badge { padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: bold; display: inline-block; }
    .badge-optimal { background: #D1FAE5; color: #059669; }
    .badge-review { background: #FEF3C7; color: #D97706; }
    .footer { margin-top: 40px; text-align: center; font-size: 13px; color: #94A3B8; }
    .btn-print { background: #2563EB; color: white; padding: 12px 24px; border: none; border-radius: 6px; font-size: 15px; font-weight: 600; cursor: pointer; margin-bottom: 20px; }
    @media print {
      .btn-print { display: none; }
      body { background: white; margin: 0; }
      .metric-card, table { box-shadow: none; border: 1px solid #DDD; }
    }
  </style>
</head>
<body>
  <div style="text-align: right;">
    <button class="btn-print" onclick="window.print()">🖨️ In Báo Cáo / Lưu PDF (Print to PDF)</button>
  </div>
  <div class="header">
    <h1>BÁO CÁO TỔNG HỢP TÌNH TRẠNG KHO HÀNG GSP</h1>
    <div class="subtitle">Kỳ báo cáo: Quý 3 / 2026 &nbsp;|&nbsp; Ngày lập: ${DateTime.now().toString().substring(0, 16)} &nbsp;|&nbsp; Đơn vị tính: VNĐ</div>
  </div>

  <div class="metrics-grid">
    <div class="metric-card">
      <div class="metric-title">TỔNG GIÁ TRỊ TỒN KHO</div>
      <div class="metric-value">1,540,000,000 VNĐ</div>
      <div class="metric-sub">+8.2% so với quý trước</div>
    </div>
    <div class="metric-card">
      <div class="metric-title">VÒNG QUAY HÀNG TỒN KHO</div>
      <div class="metric-value">4.8x / năm</div>
      <div class="metric-sub">Hiệu suất lưu thông cao</div>
    </div>
    <div class="metric-card">
      <div class="metric-title">SỐ NGÀY LƯU KHO BÌNH QUÂN</div>
      <div class="metric-value">28 ngày</div>
      <div class="metric-sub" style="color:#3B82F6;">Đạt chuẩn GSP</div>
    </div>
    <div class="metric-card">
      <div class="metric-title">TỶ LỆ HAO hụt / HẾT HẠN</div>
      <div class="metric-value">0.32%</div>
      <div class="metric-sub">Mức tối ưu (&lt; 0.5%)</div>
    </div>
  </div>

  <h3 style="color:#1E293B; margin-bottom: 14px;">Bảng Định Giá & Phân Tích Chi Tiết Theo Nhóm Thuốc</h3>
  <table>
    <thead>
      <tr>
        <th>NHÓM THUỐC (CATEGORY)</th>
        <th>SỐ LƯỢNG SKU</th>
        <th>TỔNG GIÁ TRỊ TỒN</th>
        <th>VÒNG QUAY HÀNG</th>
        <th>ĐÁNH GIÁ (STATUS)</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><strong>Antibiotics (Kháng sinh)</strong></td>
        <td>120 SKUs (mã)</td>
        <td><strong style="color:#1D4ED8;">680,000,000 VNĐ</strong></td>
        <td>5.2x/year (năm)</td>
        <td><span class="badge badge-optimal">Optimal (Tối ưu)</span></td>
      </tr>
      <tr>
        <td><strong>Dietary Supplements / Vitamins (Thực phẩm chức năng)</strong></td>
        <td>85 SKUs (mã)</td>
        <td><strong style="color:#1D4ED8;">410,000,000 VNĐ</strong></td>
        <td>4.1x/year (năm)</td>
        <td><span class="badge badge-optimal">Optimal (Tối ưu)</span></td>
      </tr>
      <tr>
        <td><strong>Analgesics & Antipyretics (Thuốc giảm đau & Hạ sốt)</strong></td>
        <td>64 SKUs (mã)</td>
        <td><strong style="color:#1D4ED8;">290,000,000 VNĐ</strong></td>
        <td>6.8x/year (năm)</td>
        <td><span class="badge badge-optimal">Optimal (Tối ưu)</span></td>
      </tr>
      <tr>
        <td><strong>Medical Supplies & Bandages (Vật tư y tế)</strong></td>
        <td>42 SKUs (mã)</td>
        <td><strong style="color:#1D4ED8;">160,000,000 VNĐ</strong></td>
        <td>3.5x/year (năm)</td>
        <td><span class="badge badge-review">Review Needed (Cần rà soát)</span></td>
      </tr>
    </tbody>
  </table>

  <div class="footer">
    Báo cáo được xuất tự động từ Hệ thống Quản lý Chuỗi Nhà thuốc Chuẩn GSP.<br>
    Bản quyền © 2026 Pharmacy Chains Management.
  </div>
</body>
</html>
''';

      if (kIsWeb) {
        final bytes = utf8.encode(htmlContent);
        final blob = html.Blob([bytes], 'text/html;charset=utf-8');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', 'Bao_Cao_Kho_GSP_Q3_2026_Report.html')
          ..click();
        html.Url.revokeObjectUrl(url);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã tải Báo cáo "Bao_Cao_Kho_GSP_Q3_2026_Report.html" xuống trình duyệt! Hãy mở file vừa tải và bấm "🖨️ In Báo Cáo / Lưu PDF (Print to PDF)" để lưu dưới dạng file PDF.'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      final downloadsDir = Directory('C:\\\\Users\\\\hoang\\\\Downloads');
      if (!await downloadsDir.exists()) await downloadsDir.create(recursive: true);

      final filePath = 'C:\\\\Users\\\\hoang\\\\Downloads\\\\Bao_Cao_Kho_GSP_Q3_2026_Report.html';
      final file = File(filePath);
      await file.writeAsString(htmlContent, flush: true);

      if (mounted) {
        _showExportDialog(context, 'Báo cáo PDF (Printable Report)', filePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Lỗi xuất file: $e'), backgroundColor: AppColors.error));
      }
    }
  }
}
