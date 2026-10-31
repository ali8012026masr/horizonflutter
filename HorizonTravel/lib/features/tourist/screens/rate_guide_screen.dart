import 'package:flutter/material.dart';
import '../../../core/widgets/common_views.dart';
import '../../../core/widgets/star_rating_bar.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/ratings.dart';

class RateGuideScreen extends StatefulWidget {
  final int guideBookingId;
  final String guideName;

  RateGuideScreen({
    super.key,
    int? guideBookingId,
    int? bookingId,
    int? guideId,
    required this.guideName,
  }) : guideBookingId = guideBookingId ?? bookingId ?? guideId ?? 0;

  @override
  State<RateGuideScreen> createState() => _RateGuideScreenState();
}

class _RateGuideScreenState extends State<RateGuideScreen> {
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
    setState(() => _isSubmitting = true);

    try {
      final req = GuideRatingRequest(
        guideBookingId: widget.guideBookingId,
        score: _score,
        comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
      );
      await _apiService.submitGuideRating(req);

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you! Your guide review has been submitted.')),
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
      appBar: AppBar(title: Text('Rate ${widget.guideName}')),
      body: LoadingOverlay(
        isLoading: _isSubmitting,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text(
                'How was your tour with ${widget.guideName}?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  hintText: 'Share your thoughts on the guide\'s knowledge, punctuality, and friendliness…',
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
