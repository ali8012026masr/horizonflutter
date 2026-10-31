import 'package:flutter/material.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/provider.dart';
import '../../../data/models/service_slot.dart';
import '../../../theme/app_colors.dart';
import '../screens/create_slot_screen.dart';

class ProviderDashboardTab extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;

  const ProviderDashboardTab({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<ProviderDashboardTab> createState() => _ProviderDashboardTabState();
}

class _ProviderDashboardTabState extends State<ProviderDashboardTab> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;
  Provider? _provider;
  int _totalSlots = 0;
  int _openSlots = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
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
        _apiService.getProviderById(providerId),
        _apiService.getSlotsForProvider(providerId).catchError((_) => <ServiceSlot>[]),
      ]);

      if (mounted) {
        final slots = results[1] as List<ServiceSlot>;
        final openCount = slots.where((s) => (s.status ?? '').toUpperCase() == 'OPEN').length;

        setState(() {
          _provider = results[0] as Provider;
          _totalSlots = slots.length;
          _openSlots = openCount;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _provider == null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadDashboardData,
      );
    }

    final p = _provider;

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primaryContainer,
                          child: const Icon(Icons.storefront, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p?.businessName ?? 'Business Agency',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Category: ${p?.category ?? "General"}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  StatusChip(
                                    label: p?.verificationStatus ?? 'APPROVED',
                                    status: p?.verificationStatus ?? 'APPROVED',
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Fee: ${((p?.commissionRate ?? 0.10) * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      'Contact: ${p?.fullName ?? "Provider"} • Phone: ${p?.phone ?? "N/A"}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Metrics Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Active Slots',
                    value: '$_openSlots',
                    icon: Icons.check_circle_outline,
                    color: AppColors.tealSuccess,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Slots',
                    value: '$_totalSlots',
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Actions Section
            const Text(
              'Provider Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            FilledButton.icon(
              onPressed: () async {
                final res = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const CreateSlotScreen()),
                );
                if (res == true) _loadDashboardData();
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New Service Slot'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () => widget.onNavigateTab?.call(1),
              icon: const Icon(Icons.list_alt),
              label: const Text('Manage All Service Slots'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () => widget.onNavigateTab?.call(2),
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: const Text('Financial Ledger & Statements'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
