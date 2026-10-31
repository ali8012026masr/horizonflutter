import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/common_views.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/guide_availability.dart';
import '../../../theme/app_colors.dart';

class EditAvailabilityScreen extends StatefulWidget {
  final int availabilityId;

  const EditAvailabilityScreen({
    super.key,
    required this.availabilityId,
  });

  @override
  State<EditAvailabilityScreen> createState() => _EditAvailabilityScreenState();
}

class _EditAvailabilityScreenState extends State<EditAvailabilityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isSaving = false;
  String _status = 'OPEN';

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailability() async {
    final guideId = SessionManager.instance.userId;
    if (guideId == null || guideId <= 0) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final list = await _apiService.getGuideAvailability(guideId);
      final item = list.firstWhere(
        (a) => a.id == widget.availabilityId,
        orElse: () => throw Exception('Availability slot not found'),
      );

      if (mounted) {
        setState(() {
          _dateController.text = item.date ?? '';
          _startTimeController.text = item.startTime ?? '';
          _endTimeController.text = item.endTime ?? '';
          _locationController.text = item.location ?? '';
          _notesController.text = item.notes ?? '';
          _status = item.status ?? 'OPEN';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load slot: $e')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 30)),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final guideId = SessionManager.instance.userId;
    if (guideId == null || guideId <= 0) return;

    setState(() => _isSaving = true);
    try {
      final req = UpdateGuideAvailabilityRequest(
        date: _dateController.text.trim(),
        startTime: _startTimeController.text.trim(),
        endTime: _endTimeController.text.trim(),
        status: _status,
        location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      await _apiService.updateGuideAvailability(widget.availabilityId, req);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Availability updated successfully!')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => const ConfirmDialog(
        title: 'Delete Availability',
        message: 'Are you sure you want to delete this availability slot?',
        confirmText: 'Delete',
        isDestructive: true,
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);
    try {
      await _apiService.deleteGuideAvailability(widget.availabilityId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Availability slot deleted')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete slot: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Availability Slot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Delete Slot',
            onPressed: _isSaving ? null : _delete,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LoadingOverlay(
              isLoading: _isSaving,
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
                                prefixIcon: Icon(Icons.access_time_filled),
                              ),
                              validator: Validators.validateRequired,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Status Dropdown
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'Slot Status',
                          prefixIcon: Icon(Icons.info_outline),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'OPEN', child: Text('OPEN')),
                          DropdownMenuItem(value: 'BOOKED', child: Text('BOOKED')),
                          DropdownMenuItem(value: 'CANCELLED', child: Text('CANCELLED')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _status = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Location
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location / Area',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notes / Details',
                          prefixIcon: Icon(Icons.note_alt_outlined),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _save,
                        icon: const Icon(Icons.save),
                        label: const Text('Update Slot', style: TextStyle(fontSize: 16)),
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
