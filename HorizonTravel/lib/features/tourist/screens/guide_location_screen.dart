import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/widgets/common_views.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/location_model.dart';
import '../../../theme/app_colors.dart';

class GuideLocationScreen extends StatefulWidget {
  final int guideId;
  final String guideName;

  const GuideLocationScreen({
    super.key,
    required this.guideId,
    required this.guideName,
  });

  @override
  State<GuideLocationScreen> createState() => _GuideLocationScreenState();
}

class _GuideLocationScreenState extends State<GuideLocationScreen> {
  final ApiService _apiService = ApiService();
  LocationModel? _location;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchLocation());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    try {
      final loc = await _apiService.getGuideLocation(widget.guideId);
      if (mounted) {
        setState(() {
          _location = loc;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Location is currently unavailable from guide.';
        });
      }
    }
  }

  Future<void> _openInMaps() async {
    if (_location?.latitude == null || _location?.longitude == null) return;
    final lat = _location!.latitude!;
    final lng = _location!.longitude!;

    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(widget.guideName)})');
    final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    try {
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open maps: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.guideName} Live Location'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLocation,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _location == null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _fetchLocation,
      );
    }

    final loc = _location;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                size: 72,
                color: AppColors.tealSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.guideName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.statusActive,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Auto-refreshing every 15s',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Latitude:', style: TextStyle(color: AppColors.textSecondary)),
                        Text(
                          loc?.latitude?.toStringAsFixed(6) ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Longitude:', style: TextStyle(color: AppColors.textSecondary)),
                        Text(
                          loc?.longitude?.toStringAsFixed(6) ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Last Updated:', style: TextStyle(color: AppColors.textSecondary)),
                        Text(
                          Formatters.formatDateTime(loc?.updatedAt),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: loc != null ? _openInMaps : null,
              icon: const Icon(Icons.map_outlined),
              label: const Text('Open in Google Maps'),
            ),
          ],
        ),
      ),
    );
  }
}
