import 'package:flutter/material.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/common_views.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/guide.dart';

class EditGuideProfileScreen extends StatefulWidget {
  const EditGuideProfileScreen({super.key});

  @override
  State<EditGuideProfileScreen> createState() => _EditGuideProfileScreenState();
}

class _EditGuideProfileScreenState extends State<EditGuideProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();
  final _languagesController = TextEditingController();
  final _experienceController = TextEditingController();
  final _priceController = TextEditingController();
  final _bioController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _negotiable = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    _languagesController.dispose();
    _experienceController.dispose();
    _priceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final guideId = SessionManager.instance.userId;
    if (guideId == null || guideId <= 0) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final guide = await _apiService.getGuideById(guideId);
      if (mounted) {
        setState(() {
          _nameController.text = guide.fullName ?? '';
          _phoneController.text = guide.phone ?? '';
          _addressController.text = guide.address ?? '';
          _locationController.text = guide.location ?? '';
          _languagesController.text = (guide.languages ?? []).join(', ');
          _experienceController.text = (guide.experienceYears ?? 0).toString();
          _priceController.text = (guide.defaultPrice ?? 0.0).toStringAsFixed(2);
          _negotiable = guide.negotiable;
          _bioController.text = guide.bio ?? '';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final guideId = SessionManager.instance.userId;
    if (guideId == null || guideId <= 0) return;

    setState(() => _isSaving = true);
    try {
      final langs = _languagesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final req = UpdateGuideRequest(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
        languages: langs.isNotEmpty ? langs : null,
        experienceYears: int.tryParse(_experienceController.text.trim()) ?? 0,
        defaultPrice: double.tryParse(_priceController.text.trim()) ?? 0.0,
        negotiable: _negotiable,
        bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
      );

      final updated = await _apiService.updateGuideProfile(guideId, req);
      await SessionManager.instance.updateProfile(
        userId: guideId,
        email: SessionManager.instance.email ?? '',
        role: SessionManager.instance.role ?? 'TOUR_GUIDE',
        fullName: updated.fullName ?? req.fullName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guide profile updated successfully!')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Guide Profile'),
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
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: Validators.validateRequired,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Base Location / Operating City',
                          hintText: 'e.g., Sylhet, Cox\'s Bazar',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: Validators.validateRequired,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _languagesController,
                        decoration: const InputDecoration(
                          labelText: 'Languages (comma separated)',
                          hintText: 'e.g., English, Bengali, Hindi',
                          prefixIcon: Icon(Icons.translate),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _experienceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Experience (Years)',
                                prefixIcon: Icon(Icons.work_outline),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Daily Rate (৳)',
                                prefixIcon: Icon(Icons.payments_outlined),
                              ),
                              validator: Validators.validateRequired,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Price is Negotiable'),
                        subtitle: const Text('Allow tourists to propose customized hire offers'),
                        value: _negotiable,
                        onChanged: (val) => setState(() => _negotiable = val),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          prefixIcon: Icon(Icons.home_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Guide Bio / Introduction',
                          hintText: 'Tell tourists about your background and local specialties...',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isSaving ? null : _save,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Save Profile Changes', style: TextStyle(fontSize: 16)),
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
