import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/commission.dart';
import '../../../data/models/payment.dart';
import '../../../features/reports/pdf_report_helper.dart';
import '../../../theme/app_colors.dart';
import '../../../util/constants.dart';

class AdminFinanceTab extends StatefulWidget {
  const AdminFinanceTab({super.key});

  @override
  State<AdminFinanceTab> createState() => _AdminFinanceTabState();
}

class _AdminFinanceTabState extends State<AdminFinanceTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;

  List<Payment> _allPayments = [];
  List<Commission> _allCommissions = [];

  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFinanceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFinanceData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final fromStr = _dateRange != null ? DateFormat('yyyy-MM-dd').format(_dateRange!.start) : null;
    final toStr = _dateRange != null ? DateFormat('yyyy-MM-dd').format(_dateRange!.end) : null;

    try {
      final results = await Future.wait([
        _apiService.getAllPayments(from: fromStr, to: toStr).catchError((_) => <Payment>[]),
        _apiService.getAllCommissions(from: fromStr, to: toStr).catchError((_) => <Commission>[]),
      ]);

      if (mounted) {
        setState(() {
          _allPayments = results[0] as List<Payment>;
          _allCommissions = results[1] as List<Commission>;
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
      _loadFinanceData();
    }
  }

  Future<void> _settleCommission(Commission comm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: 'Settle Commission',
        message: 'Mark commission #${comm.id} of ${Formatters.formatCurrency(comm.commissionAmount)} from provider #${comm.providerId} as SETTLED?',
        confirmText: 'Settle Commission',
      ),
    );

    if (confirmed != true || comm.id == null) return;

    setState(() => _isLoading = true);
    try {
      await _apiService.settleCommission(comm.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commission successfully marked as SETTLED!')),
        );
        _loadFinanceData();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to settle commission: $e')),
        );
      }
    }
  }

  Future<void> _downloadPdfReport() async {
    final isPayments = _tabController.index == 0;
    try {
      if (isPayments) {
        if (_allPayments.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No payments to export')));
          return;
        }
        final headers = ['Pay ID', 'Booking ID', 'Amount', 'Method', 'Date', 'Status'];
        double total = 0.0;
        final rows = _allPayments.map((p) {
          total += (p.amount ?? 0.0);
          return [
            '#${p.id}',
            '#${p.bookingId}',
            Formatters.formatCurrency(p.amount),
            p.paymentMethod ?? 'CARD',
            Formatters.formatDateTime(p.paymentDate),
            p.status ?? 'COMPLETED',
          ];
        }).toList();

        await PdfReportHelper.generateAndDownloadReport(
          title: 'Horizon Travel - Platform Payments Report',
          subtitle: 'System-wide Transactions Summary',
          headers: headers,
          rows: rows,
          summaryText: 'Total Payments Volume: ${Formatters.formatCurrency(total)}',
        );
      } else {
        if (_allCommissions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No commissions to export')));
          return;
        }
        final headers = ['Comm ID', 'Provider', 'Booking', 'Gross', 'Rate', 'Commission', 'Status'];
        double totalComm = 0.0;
        final rows = _allCommissions.map((c) {
          totalComm += (c.commissionAmount ?? 0.0);
          return [
            '#${c.id}',
            '#${c.providerId}',
            '#${c.bookingId}',
            Formatters.formatCurrency(c.bookingAmount),
            '${((c.commissionRate ?? 0.0) * 100).toStringAsFixed(1)}%',
            Formatters.formatCurrency(c.commissionAmount),
            c.status ?? SettlementStatus.pending,
          ];
        }).toList();

        await PdfReportHelper.generateAndDownloadReport(
          title: 'Horizon Travel - Platform Commissions Report',
          subtitle: 'System-wide Partner Commission Ledger',
          headers: headers,
          rows: rows,
          summaryText: 'Total Commission Revenue: ${Formatters.formatCurrency(totalComm)}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.payments_outlined), text: 'Payments'),
              Tab(icon: Icon(Icons.account_balance_wallet_outlined), text: 'Commissions'),
            ],
          ),
        ),

        // Date Picker Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            children: [
              ActionChip(
                avatar: const Icon(Icons.date_range, size: 16),
                label: Text(
                  _dateRange == null
                      ? 'Filter Date Range'
                      : '${DateFormat('MM/dd').format(_dateRange!.start)} - ${DateFormat('MM/dd').format(_dateRange!.end)}',
                  style: const TextStyle(fontSize: 12),
                ),
                onPressed: _pickDateRange,
              ),
              if (_dateRange != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    setState(() => _dateRange = null);
                    _loadFinanceData();
                  },
                ),
              ],
              const Spacer(),
              IconButton.filledTonal(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                tooltip: 'Export Statement (PDF)',
                onPressed: _downloadPdfReport,
              ),
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPaymentsTab(),
              _buildCommissionsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _allPayments.isEmpty) {
      return ErrorStateView(message: _errorMessage!, onRetry: _loadFinanceData);
    }

    if (_allPayments.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadFinanceData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            child: const EmptyStateView(
              icon: Icons.payments_outlined,
              title: 'No Payments Found',
              message: 'No payment transactions recorded for this period.',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFinanceData,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: _allPayments.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final p = _allPayments[index];

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                child: Icon(Icons.payment, color: AppColors.primary),
              ),
              title: Text(
                'Payment #${p.id} • Booking #${p.bookingId}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                'Method: ${p.paymentMethod ?? "CARD"} • ${Formatters.formatDateTime(p.paymentDate)}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatCurrency(p.amount),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                  ),
                  const SizedBox(height: 2),
                  StatusChip(label: p.status ?? 'COMPLETED', status: p.status ?? 'COMPLETED'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommissionsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _allCommissions.isEmpty) {
      return ErrorStateView(message: _errorMessage!, onRetry: _loadFinanceData);
    }

    if (_allCommissions.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadFinanceData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            child: const EmptyStateView(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No Commissions Found',
              message: 'No partner commissions recorded for this period.',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFinanceData,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: _allCommissions.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final c = _allCommissions[index];
          final isPending = (c.status ?? SettlementStatus.pending).toUpperCase() == SettlementStatus.pending;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Commission #${c.id} (Provider #${c.providerId})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      StatusChip(label: c.status ?? SettlementStatus.pending, status: c.status ?? SettlementStatus.pending),
                    ],
                  ),
                  const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Booking #${c.bookingId} • Gross: ${Formatters.formatCurrency(c.bookingAmount)}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      Text(
                        Formatters.formatCurrency(c.commissionAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                      ),
                    ],
                  ),
                  if (isPending) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.tonalIcon(
                        onPressed: () => _settleCommission(c),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Mark Settled'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
