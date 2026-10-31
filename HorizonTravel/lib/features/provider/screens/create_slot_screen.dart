import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/common_views.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/service_slot.dart';
import '../../../util/constants.dart';

class CreateSlotScreen extends StatefulWidget {
  const CreateSlotScreen({super.key});

  @override
  State<CreateSlotScreen> createState() => _CreateSlotScreenState();
}

class _CreateSlotScreenState extends State<CreateSlotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _startDateTimeController = TextEditingController();
  final _endDateTimeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _cancellationController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _selectedCategory = 'HOTEL';

  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  final List<String> _categories = [
    'HOTEL',
    'RESORT',
    'BUS',
    'MICROBUS',
    'LAUNCH',
    'TRAIN',
    'AIRPLANE',
    'SHIP',
    'CONVENTION_CENTER',
    'BUFFET',
    ServiceCategory.amusementPark,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _startDateTimeController.dispose();
    _endDateTimeController.dispose();
    _capacityController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _cancellationController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(bool isStart) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: isStart ? 9 : 17, minute: 0),
    );
    if (pickedTime == null || !mounted) return;

    final dt = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final formatted = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dt);

    setState(() {
      if (isStart) {
        _startDate = pickedDate;
        _startTime = pickedTime;
        _startDateTimeController.text = formatted;
      } else {
        _endDate = pickedDate;
        _endTime = pickedTime;
        _endDateTimeController.text = formatted;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final providerId = SessionManager.instance.userId;
    if (providerId == null || providerId <= 0) return;

    setState(() => _isLoading = true);
    try {
      final req = CreateServiceSlotRequest(
        serviceProviderId: providerId,
        category: _selectedCategory,
        title: _titleController.text.trim(),
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        startDateTime: _startDateTimeController.text.trim(),
        endDateTime: _endDateTimeController.text.trim(),
        capacity: int.tryParse(_capacityController.text.trim()) ?? 1,
        durationMinutes: int.tryParse(_durationController.text.trim()) ?? 60,
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
        cancellationPolicy: _cancellationController.text.trim().isNotEmpty ? _cancellationController.text.trim() : null,
      );

      await _apiService.createSlot(req);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service slot created successfully!')),
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
        title: const Text('Create Service Slot'),
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
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Service Category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _categories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 16),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Slot Title',
                    hintText: 'e.g., Deluxe Sea View Room / AC Bus Seat',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: Validators.validateRequired,
                ),
                const SizedBox(height: 16),

                // Start & End DateTime
                TextFormField(
                  controller: _startDateTimeController,
                  readOnly: true,
                  onTap: () => _pickDateTime(true),
                  decoration: const InputDecoration(
                    labelText: 'Start Date & Time',
                    hintText: 'Tap to pick start time',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: Validators.validateRequired,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _endDateTimeController,
                  readOnly: true,
                  onTap: () => _pickDateTime(false),
                  decoration: const InputDecoration(
                    labelText: 'End Date & Time',
                    hintText: 'Tap to pick end time',
                    prefixIcon: Icon(Icons.event_available),
                  ),
                  validator: Validators.validateRequired,
                ),
                const SizedBox(height: 16),

                // Price & Capacity
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Price (৳)',
                          prefixIcon: Icon(Icons.payments_outlined),
                        ),
                        validator: Validators.validateRequired,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _capacityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Capacity / Seats',
                          prefixIcon: Icon(Icons.people_outline),
                        ),
                        validator: Validators.validateRequired,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Duration in Minutes
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (Minutes)',
                    hintText: 'e.g., 60, 120, 1440',
                    prefixIcon: Icon(Icons.timer_outlined),
                  ),
                  validator: Validators.validateRequired,
                ),
                const SizedBox(height: 16),

                // Location
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location / Venue Address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Cancellation Policy
                TextFormField(
                  controller: _cancellationController,
                  decoration: const InputDecoration(
                    labelText: 'Cancellation Policy',
                    hintText: 'e.g., Free cancellation up to 24h before',
                    prefixIcon: Icon(Icons.policy_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Service Description',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                FilledButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Slot', style: TextStyle(fontSize: 16)),
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
