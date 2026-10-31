import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/common_views.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/guide_availability.dart';

class CreateAvailabilityScreen extends StatefulWidget {
  const CreateAvailabilityScreen({super.key});

  @override
  State<CreateAvailabilityScreen> createState() => _CreateAvailabilityScreenState();
}

class _CreateAvailabilityScreenState extends State<CreateAvailabilityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final min = picked.minute.toString().padLeft(2, '0');
      controller.text = '$hour:$min';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final guideId = SessionManager.instance.userId;
    if (guideId == null || guideId <= 0) return;

    setState(() => _isLoading = true);
    try {
      final req = CreateGuideAvailabilityRequest(
        tourGuideId: guideId,
        date: _dateController.text.trim(),
        startTime: _startTimeController.text.trim(),
        endTime: _endTimeController.text.trim(),
        location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      await _apiService.createGuideAvailability(req);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Availability slot added successfully!')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Availability Slot'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Date
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    hintText: 'Select availability date',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  validator: Validators.validateRequired,
                ),
                const SizedBox(height: 16),

                // Start & End Time
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startTimeController,
                        readOnly: true,
                        onTap: () => _pickTime(_startTimeController),
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          hintText: '09:00',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        validator: Validators.validateRequired,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _endTimeController,
                        readOnly: true,
                        onTap: () => _pickTime(_endTimeController),
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          hintText: '17:00',
                          prefixIcon: Icon(Icons.access_time_filled),
                        ),
                        validator: Validators.validateRequired,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Location
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location / Area (Optional)',
                    hintText: 'e.g., Old Dhaka, Cox\'s Bazar beach',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes / Details (Optional)',
                    hintText: 'e.g., Morning city walking tour only',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                FilledButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: const Icon(Icons.check),
                  label: const Text('Save Availability Slot', style: TextStyle(fontSize: 16)),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
