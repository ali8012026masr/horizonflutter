import 'package:flutter/material.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/guide_booking.dart';
import '../../../features/reports/pdf_report_helper.dart';
import '../../../theme/app_colors.dart';
import '../screens/booking_detail_screen.dart';
import '../screens/guide_booking_detail_screen.dart';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;

  List<Booking> _serviceBookings = [];
  List<Booking> _filteredServiceBookings = [];

  List<GuideBooking> _guideBookings = [];
  List<GuideBooking> _filteredGuideBookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _applySearch(_searchController.text);
      }
    });
    _loadAllBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllBookings() async {
    final userId = SessionManager.instance.userId;
    if (userId == null || userId <= 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Tourist session not found';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getTouristBookings(userId).catchError((_) => <Booking>[]),
        _apiService.getTouristGuideBookings(userId).catchError((_) => <GuideBooking>[]),
      ]);

      if (mounted) {
        setState(() {
          _serviceBookings = results[0] as List<Booking>;
          _guideBookings = results[1] as List<GuideBooking>;
          _isLoading = false;
        });
        _applySearch(_searchController.text);
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

  void _applySearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredServiceBookings = List.from(_serviceBookings);
        _filteredGuideBookings = List.from(_guideBookings);
      } else {
        _filteredServiceBookings = _serviceBookings.where((b) {
          final id = '#${b.id}'.toLowerCase();
          final status = (b.status ?? '').toLowerCase();
          final pay = (b.paymentStatus ?? '').toLowerCase();
          return id.contains(q) || status.contains(q) || pay.contains(q);
        }).toList();

        _filteredGuideBookings = _guideBookings.where((b) {
          final id = '#${b.id}'.toLowerCase();
          final status = (b.status ?? '').toLowerCase();
          return id.contains(q) || status.contains(q);
        }).toList();
      }
    });
  }

  Future<void> _exportPdfReport() async {
    final isServices = _tabController.index == 0;
    if (isServices && _filteredServiceBookings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No service bookings available for report')),
      );
      return;
    }
    if (!isServices && _filteredGuideBookings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No guide bookings available for report')),
      );
      return;
    }

    try {
      if (isServices) {
        final headers = ['Booking ID', 'Service Slot', 'Date', 'Status', 'Payment'];
        final rows = _filteredServiceBookings
            .map((b) => [
                  '#${b.id}',
                  'Slot #${b.serviceSlotId}',
                  Formatters.formatDateTime(b.bookingDate),
                  b.status ?? 'CONFIRMED',
                  b.paymentStatus ?? 'PENDING',
                ])
            .toList();

        await PdfReportHelper.generateAndDownloadReport(
          title: 'My Service Bookings Statement',
          subtitle: 'Generated for Tourist: ${SessionManager.instance.fullName ?? "Guest"}',
          headers: headers,
          rows: rows,
          summaryText: 'Total Bookings: ${_filteredServiceBookings.length}',
        );
      } else {
        final headers = ['Hire ID', 'Guide ID', 'Scheduled Date', 'Status', 'Agreed Price'];
        double totalPaid = 0.0;
        final rows = _filteredGuideBookings.map((b) {
          final price = b.agreedPrice ?? 0.0;
          if (b.paymentReceived) totalPaid += price;
          return [
            '#${b.id}',
            'Guide #${b.tourGuideId}',
            Formatters.formatDate(b.scheduleDate),
            b.status ?? 'REQUESTED',
            Formatters.formatCurrency(b.agreedPrice),
          ];
        }).toList();

        await PdfReportHelper.generateAndDownloadReport(
          title: 'My Tour Guide Bookings Statement',
          subtitle: 'Generated for Tourist: ${SessionManager.instance.fullName ?? "Guest"}',
          headers: headers,
          rows: rows,
          summaryText: 'Total Hires: ${_filteredGuideBookings.length} • Total Paid: ${Formatters.formatCurrency(totalPaid)}',
        );
      }
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
        // Tabs
        Container(
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.confirmation_number_outlined), text: 'Services'),
              Tab(icon: Icon(Icons.person_pin_outlined), text: 'Tour Guides'),
            ],
          ),
        ),

        // Search and PDF Download Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search bookings by ID or status...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _applySearch('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onChanged: _applySearch,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                tooltip: 'Export Statement (PDF)',
                onPressed: _exportPdfReport,
              ),
            ],
          ),
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildServiceBookingsList(),
              _buildGuideBookingsList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceBookingsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _serviceBookings.isEmpty) {
      return ErrorStateView(message: _errorMessage!, onRetry: _loadAllBookings);
    }

    if (_filteredServiceBookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAllBookings,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            child: const EmptyStateView(
              icon: Icons.confirmation_number_outlined,
              title: 'No Service Bookings',
              message: 'You have not booked any services or attractions yet.',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllBookings,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _filteredServiceBookings.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final b = _filteredServiceBookings[index];
          final status = b.status ?? 'CONFIRMED';
          final payStatus = b.paymentStatus ?? 'PENDING';

          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (b.id != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookingDetailScreen(bookingId: b.id!),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Booking #${b.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        StatusChip(label: status, status: status),
                      ],
                    ),
                    const Divider(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Service #${b.serviceSlotId}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        Text(
                          Formatters.formatDateTime(b.bookingDate),
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Payment: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            StatusChip(label: payStatus, status: payStatus),
                          ],
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGuideBookingsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _guideBookings.isEmpty) {
      return ErrorStateView(message: _errorMessage!, onRetry: _loadAllBookings);
    }

    if (_filteredGuideBookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAllBookings,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            child: const EmptyStateView(
              icon: Icons.person_pin_circle_outlined,
              title: 'No Tour Guide Hires',
              message: 'You have not sent any hire requests to tour guides yet.',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllBookings,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _filteredGuideBookings.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final b = _filteredGuideBookings[index];
          final status = b.status ?? 'REQUESTED';

          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (b.id != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GuideBookingDetailScreen(guideBookingId: b.id!),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hire Request #${b.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        StatusChip(label: status, status: status),
                      ],
                    ),
                    const Divider(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Guide #${b.tourGuideId}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        Text(
                          'Date: ${Formatters.formatDate(b.scheduleDate)}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Formatters.formatCurrency(b.agreedPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.primary,
                          ),
                        ),
                        StatusChip(
                          label: b.paymentReceived ? 'PAID' : 'UNPAID',
                          status: b.paymentReceived ? 'CONFIRMED' : 'PENDING',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
