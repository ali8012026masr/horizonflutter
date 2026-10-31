import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/widgets/common_views.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/guide.dart';
import '../../../data/models/guide_booking.dart';
import '../../../theme/app_colors.dart';

class RequestGuideScreen extends StatefulWidget {
  final Guide guide;
  final int? availabilityId;

  RequestGuideScreen({
    super.key,
    Guide? guide,
    int? guideId,
    String? guideName,
    double? defaultPrice,
    bool? negotiable,
    this.availabilityId,
  }) : guide = guide ??
            Guide(
              id: guideId,
              fullName: guideName,
              defaultPrice: defaultPrice,
              negotiable: negotiable ?? false,
            );

  @override
  State<RequestGuideScreen> createState() => _RequestGuideScreenState();
}

class _RequestGuideScreenState extends State<RequestGuideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  DateTime? _selectedDate;
  bool _isNegotiated = false;
  bool _isSubmitting = false;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    if (widget.guide.defaultPrice != null) {
      _priceController.text = widget.guide.defaultPrice!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitRequest() async {
    final touristId = SessionManager.instance.userId;
    if (touristId == null || touristId <= 0) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a schedule date')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    setState(() => _isSubmitting = true);

    try {
      final req = GuideBookingRequest(
        touristId: touristId,
        tourGuideId: widget.guide.id!,
        guideAvailabilityId: widget.availabilityId,
        scheduleDate: dateStr,
        agreedPrice: price,
        isNegotiated: _isNegotiated,
      );
      await _apiService.createGuideBooking(req);

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guide request submitted! Awaiting guide confirmation.')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to request guide: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hire ${widget.guide.fullName ?? "Guide"}')),
      body: LoadingOverlay(
        isLoading: _isSubmitting,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.secondaryContainer,
                          child: const Icon(Icons.person, size: 32, color: AppColors.tealSecondary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.guide.fullName ?? 'Tour Guide',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              if (widget.guide.location != null)
                                Text(
                                  widget.guide.location!,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                              Text(
                                'Rate: ${Formatters.formatCurrency(widget.guide.defaultPrice ?? 0)}',
                                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Tour Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                  title: const Text('Schedule Date'),
                  subtitle: Text(
                    _selectedDate != null
                        ? DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate!)
                        : 'Select date for your tour',
                    style: TextStyle(
                      fontWeight: _selectedDate != null ? FontWeight.bold : FontWeight.normal,
                      color: _selectedDate != null ? AppColors.onSurface : AppColors.textSecondary,
                    ),
                  ),
                  trailing: OutlinedButton(
                    onPressed: _pickDate,
                    child: const Text('Pick Date'),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Agreed Price (\$)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter the offered price';
                    final num = double.tryParse(v);
                    if (num == null || num <= 0) return 'Please enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Price Negotiated'),
                  subtitle: const Text('Indicate if you have discussed or altered this rate'),
                  value: _isNegotiated,
                  onChanged: (val) => setState(() => _isNegotiated = val),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: _isSubmitting ? null : _submitRequest,
                  child: const Text('Submit Request to Guide'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
