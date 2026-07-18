import 'package:flutter/material.dart';
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GSP Warehouse Summary Report (Báo Cáo Tổng Hợp Tình Trạng Kho Hàng GSP)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    SizedBox(height: 4),
                    Text('Reporting Period (Kỳ báo cáo): Q3/2026 (Unit: VNĐ)', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📄 Exported Inventory PDF Report successfully (Đã xuất file PDF Báo cáo)!')));
                      },
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                      label: const Text('Export PDF Report (Xuất báo cáo PDF)'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📊 Exported Excel Valuation Matrix successfully (Đã xuất file Excel)!')));
                      },
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
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(flex: 3, child: _buildTableHeader('CATEGORY (NHÓM THUỐC)')),
                        Expanded(flex: 2, child: _buildTableHeader('SKU COUNT (SỐ LƯỢNG SKU)')),
                        Expanded(flex: 2, child: _buildTableHeader('TOTAL VALUE (TỔNG GIÁ TRỊ TỒN)')),
                        Expanded(flex: 2, child: _buildTableHeader('TURNOVER RATE (VÒNG QUAY HÀNG)')),
                        Expanded(flex: 2, child: _buildTableHeader('EVALUATION (ĐÁNH GIÁ)')),
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
                            Expanded(flex: 3, child: Text(item['category'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary))),
                            Expanded(flex: 2, child: Text('${item['skuCount']} SKUs (mã)', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))),
                            Expanded(flex: 2, child: Text(item['totalValue'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primaryDark))),
                            Expanded(flex: 2, child: Text(item['turnoverRate'], style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: item['status'].toString().contains('Optimal') ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(item['status'], style: TextStyle(color: item['status'].toString().contains('Optimal') ? AppColors.success : AppColors.warning, fontWeight: FontWeight.bold, fontSize: 12)),
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
}
