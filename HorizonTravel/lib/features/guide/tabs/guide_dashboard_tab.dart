import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/guide.dart';
import '../../../data/models/guide_booking.dart';
import '../../../data/models/location_model.dart';
import '../../../theme/app_colors.dart';
import '../../../util/constants.dart';

class GuideDashboardTab extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;

  const GuideDashboardTab({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<GuideDashboardTab> createState() => _GuideDashboardTabState();
}

class _GuideDashboardTabState extends State<GuideDashboardTab> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;
  Guide? _guide;
  List<GuideBooking> _upcomingBookings = [];

  bool _isBroadcastingGps = false;
  Timer? _gpsBroadcastTimer;
  String _gpsStatusText = 'GPS Broadcast Disabled';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _stopGpsBroadcast();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final guideId = SessionManager.instance.userId;
    if (guideId == null || guideId <= 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Guide session not found';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getGuideById(guideId),
        _apiService.getGuideBookings(guideId).catchError((_) => <GuideBooking>[]),
      ]);

      if (mounted) {
        final allBookings = results[1] as List<GuideBooking>;
        final upcoming = allBookings
            .where((b) => (b.status ?? '').toUpperCase() == GuideBookingStatus.accepted)
            .toList();

        setState(() {
          _guide = results[0] as Guide;
          _upcomingBookings = upcoming;
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

  Future<void> _toggleGpsBroadcast(bool enable) async {
    if (!enable) {
      _stopGpsBroadcast();
      setState(() {
        _isBroadcastingGps = false;
        _gpsStatusText = 'GPS Broadcast Disabled';
      });
      return;
    }

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is required to broadcast GPS location.')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission permanently denied. Enable in device settings.')),
        );
      }
      return;
    }

    setState(() {
      _isBroadcastingGps = true;
      _gpsStatusText = 'Broadcasting location every 30s...';
    });

    _sendLocationUpdate();
    _gpsBroadcastTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendLocationUpdate();
    });
  }

  Future<void> _sendLocationUpdate() async {
    final guideId = SessionManager.instance.userId;
    if (guideId == null || guideId <= 0 || !_isBroadcastingGps) return;

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      await _apiService.updateGuideLocation(
        guideId,
        UpdateLocationRequest(latitude: pos.latitude, longitude: pos.longitude),
      );

      if (mounted) {
        setState(() {
          _gpsStatusText = 'Live: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)} (every 30s)';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _gpsStatusText = 'GPS error: $e';
        });
      }
    }
  }

  void _stopGpsBroadcast() {
    _gpsBroadcastTimer?.cancel();
    _gpsBroadcastTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _guide == null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadDashboardData,
      );
    }

    final guide = _guide;

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(
                            (guide?.fullName ?? 'G').isNotEmpty ? (guide?.fullName ?? 'G')[0].toUpperCase() : 'G',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                guide?.fullName ?? 'Tour Guide',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                guide?.location ?? 'Operating region not set',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        StatusChip(
                          label: (guide?.available ?? false) ? 'ACTIVE' : 'OFFLINE',
                          status: (guide?.available ?? false) ? 'AVAILABLE' : 'UNAVAILABLE',
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Rating', '${(guide?.ratingAvg ?? 0.0).toStringAsFixed(1)} ★ (${guide?.ratingCount ?? 0})'),
                        _buildStat('Experience', '${guide?.experienceYears ?? 0} yrs'),
                        _buildStat('Daily Rate', Formatters.formatCurrency(guide?.defaultPrice)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Live GPS Broadcast Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_searching_rounded, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Live GPS Broadcast',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isBroadcastingGps,
                          onChanged: _toggleGpsBroadcast,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _gpsStatusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: _isBroadcastingGps ? AppColors.tealSuccess : AppColors.textSecondary,
                        fontWeight: _isBroadcastingGps ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Turn on when guiding tourists so they can track your live meetup location.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Upcoming Bookings Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Confirmed Hires',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => widget.onNavigateTab?.call(2),
                  child: const Text('View All Requests'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_upcomingBookings.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No upcoming confirmed tours. Check "Requests" for pending booking offers.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _upcomingBookings.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final b = _upcomingBookings[index];
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
                                'Hire #${b.id}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              StatusChip(label: 'ACCEPTED', status: 'ACCEPTED'),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Scheduled for: ${Formatters.formatDate(b.scheduleDate)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Agreed Fee: ${Formatters.formatCurrency(b.agreedPrice)}',
                                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                              ),
                              StatusChip(
                                label: b.paymentReceived ? 'PAID' : 'PAYMENT PENDING',
                                status: b.paymentReceived ? 'CONFIRMED' : 'PENDING',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
