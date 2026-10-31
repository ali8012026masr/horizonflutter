import 'package:flutter/material.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/guide.dart';
import '../../../data/models/pending_registrations_response.dart';
import '../../../data/models/provider.dart';
import '../../../theme/app_colors.dart';

class AdminVerificationsTab extends StatefulWidget {
  const AdminVerificationsTab({super.key});

  @override
  State<AdminVerificationsTab> createState() => _AdminVerificationsTabState();
}

class _AdminVerificationsTabState extends State<AdminVerificationsTab> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<Guide> _pendingGuides = [];
  List<Provider> _pendingProviders = [];
  String _selectedFilter = 'ALL'; // ALL, GUIDES, PROVIDERS

  @override
  void initState() {
    super.initState();
    _loadVerifications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVerifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiService.getPendingRegistrations();
      if (mounted) {
        setState(() {
          _pendingGuides = res.pendingGuides;
          _pendingProviders = res.pendingProviders;
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

  Future<void> _approveGuide(Guide guide) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: 'Approve Guide',
        message: 'Approve ${guide.fullName ?? "this guide"} for active tour operations?',
        confirmText: 'Approve',
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await _apiService.verifyGuide(guide.id!, const VerifyRequest(approved: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tour guide approved successfully!')),
        );
        _loadVerifications();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve: $e')),
        );
      }
    }
  }

  Future<void> _rejectGuide(Guide guide) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Tour Guide'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Rejection Reason',
            hintText: 'e.g. Incomplete verification documents',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(reasonController.text.trim()),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _apiService.verifyGuide(guide.id!, VerifyRequest(approved: false, rejectionReason: reason));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guide application rejected')),
        );
        _loadVerifications();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject: $e')),
        );
      }
    }
  }

  Future<void> _approveProvider(Provider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: 'Approve Provider',
        message: 'Approve agency "${provider.businessName ?? "Provider"}" for listing service slots?',
        confirmText: 'Approve',
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await _apiService.verifyProvider(provider.id!, const VerifyRequest(approved: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service provider approved successfully!')),
        );
        _loadVerifications();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve: $e')),
        );
      }
    }
  }

  Future<void> _rejectProvider(Provider provider) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Provider Application'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Rejection Reason',
            hintText: 'e.g. Invalid trade license number',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(reasonController.text.trim()),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _apiService.verifyProvider(provider.id!, VerifyRequest(approved: false, rejectionReason: reason));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Provider application rejected')),
        );
        _loadVerifications();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Chips
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              ChoiceChip(
                label: Text('All (${_pendingGuides.length + _pendingProviders.length})'),
                selected: _selectedFilter == 'ALL',
                onSelected: (s) {
                  if (s) setState(() => _selectedFilter = 'ALL');
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text('Guides (${_pendingGuides.length})'),
                selected: _selectedFilter == 'GUIDES',
                onSelected: (s) {
                  if (s) setState(() => _selectedFilter = 'GUIDES');
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text('Providers (${_pendingProviders.length})'),
                selected: _selectedFilter == 'PROVIDERS',
                onSelected: (s) {
                  if (s) setState(() => _selectedFilter = 'PROVIDERS');
                },
              ),
            ],
          ),
        ),

        // List
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _pendingGuides.isEmpty && _pendingProviders.isEmpty) {
      return ErrorStateView(message: _errorMessage!, onRetry: _loadVerifications);
    }

    final showGuides = _selectedFilter == 'ALL' || _selectedFilter == 'GUIDES';
    final showProviders = _selectedFilter == 'ALL' || _selectedFilter == 'PROVIDERS';

    final totalCount = (showGuides ? _pendingGuides.length : 0) + (showProviders ? _pendingProviders.length : 0);

    if (totalCount == 0) {
      return RefreshIndicator(
        onRefresh: _loadVerifications,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            child: const EmptyStateView(
              icon: Icons.verified_user_outlined,
              title: 'No Pending Verifications',
              message: 'All partner registration requests have been reviewed.',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVerifications,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          if (showGuides && _pendingGuides.isNotEmpty) ...[
            const Text(
              'Pending Tour Guides',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            ..._pendingGuides.map(_buildGuideCard),
            const SizedBox(height: 16),
          ],
          if (showProviders && _pendingProviders.isNotEmpty) ...[
            const Text(
              'Pending Service Providers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            ..._pendingProviders.map(_buildProviderCard),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildGuideCard(Guide guide) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    guide.fullName ?? 'Tour Guide #${guide.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                StatusChip(
                  label: guide.verificationStatus ?? 'PENDING',
                  status: guide.verificationStatus ?? 'PENDING',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${guide.email ?? ""} • Location: ${guide.location ?? "N/A"}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            if (guide.bio != null && guide.bio!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                guide.bio!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ],
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Rate: ${Formatters.formatCurrency(guide.defaultPrice)}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () => _approveGuide(guide),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.tealSuccess),
                      child: const Text('Approve'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _rejectGuide(guide),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Reject', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard(Provider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    provider.businessName ?? 'Agency #${provider.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                StatusChip(
                  label: provider.verificationStatus ?? 'PENDING',
                  status: provider.verificationStatus ?? 'PENDING',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Contact: ${provider.fullName ?? ""} • Reg/License: ${provider.tradeLicense ?? "N/A"}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              'Category: ${provider.category ?? "General"} • Phone: ${provider.phone ?? "N/A"}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comm: ${((provider.commissionRate ?? 0.1) * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () => _approveProvider(provider),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.tealSuccess),
                      child: const Text('Approve'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _rejectProvider(provider),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Reject', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
