import 'package:flutter/material.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/star_rating_bar.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/ratings.dart';

class RateServiceScreen extends StatefulWidget {
  final int bookingId;
  final int providerId;
  final String providerName;

  const RateServiceScreen({
    super.key,
    required this.bookingId,
    required this.providerId,
    required this.providerName,
  });

  @override
  State<RateServiceScreen> createState() => _RateServiceScreenState();
}

class _RateServiceScreenState extends State<RateServiceScreen> {
  int _score = 5;
  final _commentController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    final touristId = SessionManager.instance.userId;
    if (touristId == null || touristId <= 0) return;

    setState(() => _isSubmitting = true);

    try {
      final req = ServiceRatingRequest(
        bookingId: widget.bookingId,
        touristId: touristId,
        providerId: widget.providerId,
        score: _score,
        comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
      );
      await _apiService.submitServiceRating(req);

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you! Your review has been submitted.')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit rating: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rate ${widget.providerName}')),
      body: LoadingOverlay(
        isLoading: _isSubmitting,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              const Text(
                'How was your experience?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Booking #${widget.bookingId}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              StarRatingBar(
                rating: _score.toDouble(),
                size: 40,
                onRatingChanged: (newScore) => setState(() => _score = newScore),
              ),
              const SizedBox(height: 12),
              Text(
                '$_score of 5 Stars',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Write a review (optional)',
                  hintText: 'Share details of your experience to help other travelers…',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: _isSubmitting ? null : _submitRating,
                child: const Text('Submit Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
