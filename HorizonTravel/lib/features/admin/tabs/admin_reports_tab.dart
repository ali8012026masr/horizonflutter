import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/widgets/common_views.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/admin_user.dart';
import '../../../data/models/commission.dart';
import '../../../theme/app_colors.dart';

class AdminReportsTab extends StatefulWidget {
  const AdminReportsTab({super.key});

  @override
  State<AdminReportsTab> createState() => _AdminReportsTabState();
}

class _AdminReportsTabState extends State<AdminReportsTab> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;

  RevenueSummary? _revenue;
  BookingsSummary? _bookings;
  CommissionSummary? _commissions;

  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final fromStr = _dateRange != null ? DateFormat('yyyy-MM-dd').format(_dateRange!.start) : null;
    final toStr = _dateRange != null ? DateFormat('yyyy-MM-dd').format(_dateRange!.end) : null;

    try {
      final results = await Future.wait([
        _apiService.getRevenueSummary(from: fromStr, to: toStr),
        _apiService.getBookingsSummary(from: fromStr, to: toStr),
        _apiService.getCommissionSummary(from: fromStr, to: toStr),
      ]);

      if (mounted) {
        setState(() {
          _revenue = results[0] as RevenueSummary;
          _bookings = results[1] as BookingsSummary;
          _commissions = results[2] as CommissionSummary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      _loadReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadReports,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Filter Bar
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _dateRange == null
                            ? 'All-Time Analytics'
                            : '${DateFormat('MMM dd, yyyy').format(_dateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_dateRange!.end)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    if (_dateRange != null)
                      TextButton(
                        onPressed: () {
                          setState(() => _dateRange = null);
                          _loadReports();
                        },
                        child: const Text('Reset'),
                      ),
                    IconButton(
                      icon: const Icon(Icons.date_range),
                      tooltip: 'Pick Date Range',
                      onPressed: _pickDateRange,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null && _revenue == null)
              ErrorStateView(message: _errorMessage!, onRetry: _loadReports)
            else ...[
              // Revenue Report Card
              _buildReportSection(
                title: 'Gross Platform Revenue',
                icon: Icons.monetization_on,
                iconColor: AppColors.tealSuccess,
                items: [
                  _buildReportRow('Total Platform Volume', Formatters.formatCurrency(_revenue?.totalRevenue), isBold: true),
                  _buildReportRow('Processed Transactions', '${_revenue?.totalTransactions ?? 0} orders'),
                ],
              ),
              const SizedBox(height: 16),

              // Bookings Report Card
              _buildReportSection(
                title: 'Bookings & Orders Performance',
                icon: Icons.confirmation_number,
                iconColor: AppColors.primary,
                items: [
                  _buildReportRow('Total Bookings Made', '${_bookings?.totalBookings ?? 0}', isBold: true),
                  _buildReportRow('Confirmed & Completed', '${_bookings?.confirmedBookings ?? 0}', valueColor: AppColors.success),
                  _buildReportRow('Cancelled Bookings', '${_bookings?.cancelledBookings ?? 0}', valueColor: AppColors.error),
                ],
              ),
              const SizedBox(height: 16),

              // Commission Report Card
              _buildReportSection(
                title: 'Partner Commissions Ledger',
                icon: Icons.account_balance_wallet,
                iconColor: AppColors.accent,
                items: [
                  _buildReportRow('Total Commission Accrued', Formatters.formatCurrency(_commissions?.totalCommission), isBold: true),
                  _buildReportRow('Settled (Collected)', Formatters.formatCurrency(_commissions?.settledCommission), valueColor: AppColors.tealSuccess),
                  _buildReportRow('Pending from Partners', Formatters.formatCurrency(_commissions?.pendingCommission), valueColor: AppColors.warning),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> items,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: iconColor.withValues(alpha: 0.15),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
