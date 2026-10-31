import 'package:flutter/material.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/common_views.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/service_slot.dart';

class EditSlotScreen extends StatefulWidget {
  final int slotId;

  const EditSlotScreen({
    super.key,
    required this.slotId,
  });

  @override
  State<EditSlotScreen> createState() => _EditSlotScreenState();
}

class _EditSlotScreenState extends State<EditSlotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _capacityController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _cancellationController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isSaving = false;
  String _status = 'OPEN';

  @override
  void initState() {
    super.initState();
    _loadSlot();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _capacityController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _cancellationController.dispose();
    super.dispose();
  }

  Future<void> _loadSlot() async {
    try {
      final slot = await _apiService.getSlotById(widget.slotId);
      if (mounted) {
        setState(() {
          _titleController.text = slot.title ?? '';
          _descController.text = slot.description ?? '';
          _capacityController.text = (slot.capacity ?? 1).toString();
          _durationController.text = (slot.durationMinutes ?? 60).toString();
          _priceController.text = (slot.price ?? 0.0).toStringAsFixed(2);
          _locationController.text = slot.location ?? '';
          _cancellationController.text = slot.cancellationPolicy ?? '';
          _status = slot.status ?? 'OPEN';
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final req = UpdateServiceSlotRequest(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        capacity: int.tryParse(_capacityController.text.trim()) ?? 1,
        durationMinutes: int.tryParse(_durationController.text.trim()) ?? 60,
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        status: _status,
        location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
        cancellationPolicy: _cancellationController.text.trim().isNotEmpty ? _cancellationController.text.trim() : null,
      );

      await _apiService.updateSlot(widget.slotId, req);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service slot updated successfully!')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update slot: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Slot #${widget.slotId}'),
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
                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Slot Title',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: Validators.validateRequired,
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
                                labelText: 'Capacity',
                                prefixIcon: Icon(Icons.people_outline),
                              ),
                              validator: Validators.validateRequired,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Duration
                      TextFormField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Duration (Minutes)',
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
                          prefixIcon: Icon(Icons.policy_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _save,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Changes', style: TextStyle(fontSize: 16)),
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
