import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/commission.dart';
import '../../../data/models/payment.dart';
import '../../../features/reports/pdf_report_helper.dart';
import '../../../theme/app_colors.dart';
import '../../../util/constants.dart';

class ProviderLedgerTab extends StatefulWidget {
  const ProviderLedgerTab({super.key});

  @override
  State<ProviderLedgerTab> createState() => _ProviderLedgerTabState();
}

class _ProviderLedgerTabState extends State<ProviderLedgerTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;

  List<Commission> _allCommissions = [];
  List<Commission> _filteredCommissions = [];
  String _commissionStatusFilter = 'ALL';
  DateTimeRange? _commissionDateRange;

  List<Payment> _allPayments = [];
  List<Payment> _filteredPayments = [];
  DateTimeRange? _paymentDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLedgerData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLedgerData() async {
    final providerId = SessionManager.instance.userId;
    if (providerId == null || providerId <= 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Provider session not found';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getCommissionsForProvider(providerId).catchError((_) => <Commission>[]),
        _apiService.getPaymentsForProvider(providerId).catchError((_) => <Payment>[]),
      ]);

      if (mounted) {
        setState(() {
          _allCommissions = results[0] as List<Commission>;
          _allPayments = results[1] as List<Payment>;
          _isLoading = false;
        });
        _applyCommissionFilters();
        _applyPaymentFilters();
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

  void _applyCommissionFilters() {
    setState(() {
      _filteredCommissions = _allCommissions.where((c) {
        if (_commissionStatusFilter != 'ALL') {
          if ((c.status ?? '').toUpperCase() != _commissionStatusFilter.toUpperCase()) {
            return false;
          }
        }
        if (_commissionDateRange != null && c.createdAt != null) {
          try {
            final dt = DateTime.parse(c.createdAt!);
            if (dt.isBefore(_commissionDateRange!.start) || dt.isAfter(_commissionDateRange!.end.add(const Duration(days: 1)))) {
              return false;
            }
          } catch (_) {}
        }
        return true;
      }).toList();
    });
  }

  void _applyPaymentFilters() {
    setState(() {
      _filteredPayments = _allPayments.where((p) {
        if (_paymentDateRange != null && p.paymentDate != null) {
          try {
            final dt = DateTime.parse(p.paymentDate!);
            if (dt.isBefore(_paymentDateRange!.start) || dt.isAfter(_paymentDateRange!.end.add(const Duration(days: 1)))) {
              return false;
            }
          } catch (_) {}
        }
        return true;
      }).toList();
    });
  }

  Future<void> _pickCommissionDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: _commissionDateRange,
    );
    if (picked != null) {
      setState(() => _commissionDateRange = picked);
      _applyCommissionFilters();
    }
  }

  Future<void> _pickPaymentDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: _paymentDateRange,
    );
    if (picked != null) {
      setState(() => _paymentDateRange = picked);
      _applyPaymentFilters();
    }
  }

  Future<void> _downloadCommissionsPdf() async {
    if (_filteredCommissions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No commissions available for statement')),
      );
      return;
    }

    try {
      final headers = ['Comm ID', 'Booking ID', 'Gross Booking', 'Rate', 'Commission', 'Status'];
      double totalComm = 0.0;
      final rows = _filteredCommissions.map((c) {
        totalComm += (c.commissionAmount ?? 0.0);
        return [
          '#${c.id}',
          '#${c.bookingId}',
          Formatters.formatCurrency(c.bookingAmount),
          '${((c.commissionRate ?? 0.0) * 100).toStringAsFixed(1)}%',
          Formatters.formatCurrency(c.commissionAmount),
          c.status ?? SettlementStatus.pending,
        ];
      }).toList();

      await PdfReportHelper.generateAndDownloadReport(
        title: 'Platform Commissions Ledger',
        subtitle: 'Provider ID #${SessionManager.instance.userId} • ${SessionManager.instance.fullName ?? ""}',
        headers: headers,
        rows: rows,
        summaryText: 'Total Commission Due: ${Formatters.formatCurrency(totalComm)}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    }
  }

  Future<void> _downloadPaymentsPdf() async {
    if (_filteredPayments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No payments available for statement')),
      );
      return;
    }

    try {
      final headers = ['Pay ID', 'Booking ID', 'Amount', 'Method', 'Date', 'Status'];
      double totalPaid = 0.0;
      final rows = _filteredPayments.map((p) {
        totalPaid += (p.amount ?? 0.0);
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
        title: 'Incoming Customer Payments Statement',
        subtitle: 'Provider ID #${SessionManager.instance.userId} • ${SessionManager.instance.fullName ?? ""}',
        headers: headers,
        rows: rows,
        summaryText: 'Total Payments Received: ${Formatters.formatCurrency(totalPaid)}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
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
              Tab(icon: Icon(Icons.account_balance_wallet_outlined), text: 'Commissions'),
              Tab(icon: Icon(Icons.payments_outlined), text: 'Customer Payments'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCommissionsTab(),
              _buildPaymentsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommissionsTab() {
    return Column(
      children: [
        // Filter Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            children: [
              ActionChip(
                avatar: const Icon(Icons.date_range, size: 16),
                label: Text(
                  _commissionDateRange == null
                      ? 'Date Range'
                      : '${DateFormat('MM/dd').format(_commissionDateRange!.start)} - ${DateFormat('MM/dd').format(_commissionDateRange!.end)}',
                  style: const TextStyle(fontSize: 12),
                ),
                onPressed: _pickCommissionDateRange,
              ),
              if (_commissionDateRange != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    setState(() => _commissionDateRange = null);
                    _applyCommissionFilters();
                  },
                ),
              ],
              const Spacer(),
              IconButton.filledTonal(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                tooltip: 'Export PDF',
                onPressed: _downloadCommissionsPdf,
              ),
            ],
          ),
        ),

        // Status Chips
        SizedBox(
          height: 40,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: [
              _buildCommStatusChip('ALL', 'All'),
              const SizedBox(width: 8),
              _buildCommStatusChip(SettlementStatus.pending, 'Pending'),
              const SizedBox(width: 8),
              _buildCommStatusChip(SettlementStatus.settled, 'Settled'),
            ],
          ),
        ),
        const SizedBox(height: 6),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredCommissions.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _loadLedgerData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          alignment: Alignment.center,
                          child: const EmptyStateView(
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'No Commissions',
                            message: 'No commission records found for this period.',
                          ),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadLedgerData,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                        itemCount: _filteredCommissions.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final c = _filteredCommissions[index];
                          final status = c.status ?? SettlementStatus.pending;

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
                                        'Commission #${c.id} (Booking #${c.bookingId})',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      StatusChip(label: status, status: status),
                                    ],
                                  ),
                                  const Divider(height: 18),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Gross: ${Formatters.formatCurrency(c.bookingAmount)} (Rate: ${((c.commissionRate ?? 0) * 100).toStringAsFixed(0)}%)',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                      ),
                                      Text(
                                        Formatters.formatCurrency(c.commissionAmount),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (c.settledAt != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Settled on: ${Formatters.formatDateTime(c.settledAt)}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.tealSuccess),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildCommStatusChip(String status, String label) {
    final isSelected = _commissionStatusFilter.toUpperCase() == status.toUpperCase();
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _commissionStatusFilter = status);
          _applyCommissionFilters();
        }
      },
    );
  }

  Widget _buildPaymentsTab() {
    return Column(
      children: [
        // Filter Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            children: [
              ActionChip(
                avatar: const Icon(Icons.date_range, size: 16),
                label: Text(
                  _paymentDateRange == null
                      ? 'Date Range'
                      : '${DateFormat('MM/dd').format(_paymentDateRange!.start)} - ${DateFormat('MM/dd').format(_paymentDateRange!.end)}',
                  style: const TextStyle(fontSize: 12),
                ),
                onPressed: _pickPaymentDateRange,
              ),
              if (_paymentDateRange != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    setState(() => _paymentDateRange = null);
                    _applyPaymentFilters();
                  },
                ),
              ],
              const Spacer(),
              IconButton.filledTonal(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                tooltip: 'Export PDF',
                onPressed: _downloadPaymentsPdf,
              ),
            ],
          ),
        ),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredPayments.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _loadLedgerData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          alignment: Alignment.center,
                          child: const EmptyStateView(
                            icon: Icons.payments_outlined,
                            title: 'No Payments',
                            message: 'No payment records found for this period.',
                          ),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadLedgerData,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                        itemCount: _filteredPayments.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final p = _filteredPayments[index];

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
                                'Method: ${p.paymentMethod ?? "CARD"}\n${Formatters.formatDateTime(p.paymentDate)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              isThreeLine: true,
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    Formatters.formatCurrency(p.amount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  StatusChip(
                                    label: p.status ?? 'COMPLETED',
                                    status: p.status ?? 'COMPLETED',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
