import 'package:flutter/material.dart';
import '../../../core/storage/session_manager.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/common_views.dart';
import '../../../data/api/api_service.dart';
import '../../../data/models/provider.dart';
import '../../../util/constants.dart';

class EditProviderProfileScreen extends StatefulWidget {
  const EditProviderProfileScreen({super.key});

  @override
  State<EditProviderProfileScreen> createState() => _EditProviderProfileScreenState();
}

class _EditProviderProfileScreenState extends State<EditProviderProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _tradeLicenseController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isSaving = false;
  String _selectedCategory = 'HOTEL';
  double? _commissionRate;

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
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _tradeLicenseController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final providerId = SessionManager.instance.userId;
    if (providerId == null || providerId <= 0) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final p = await _apiService.getProviderById(providerId);
      if (mounted) {
        setState(() {
          _nameController.text = p.fullName ?? '';
          _businessNameController.text = p.businessName ?? '';
          _tradeLicenseController.text = p.tradeLicense ?? '';
          _phoneController.text = p.phone ?? '';
          _addressController.text = p.address ?? '';
          if (p.category != null && _categories.contains(p.category)) {
            _selectedCategory = p.category!;
          }
          _commissionRate = p.commissionRate;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final providerId = SessionManager.instance.userId;
    if (providerId == null || providerId <= 0) return;

    setState(() => _isSaving = true);
    try {
      final req = UpdateProviderRequest(
        fullName: _nameController.text.trim(),
        businessName: _businessNameController.text.trim(),
        tradeLicense: _tradeLicenseController.text.trim(),
        category: _selectedCategory,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      );

      final updated = await _apiService.updateProviderProfile(providerId, req);
      await SessionManager.instance.updateProfile(
        userId: providerId,
        email: SessionManager.instance.email ?? '',
        role: SessionManager.instance.role ?? 'SERVICE_PROVIDER',
        fullName: updated.fullName ?? req.fullName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Provider profile updated successfully!')),
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
        title: const Text('Edit Provider Profile'),
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
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Person Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: Validators.validateRequired,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _businessNameController,
                        decoration: const InputDecoration(
                          labelText: 'Business / Agency Name',
                          prefixIcon: Icon(Icons.storefront_outlined),
                        ),
                        validator: Validators.validateRequired,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tradeLicenseController,
                        decoration: const InputDecoration(
                          labelText: 'Trade License / Reg Number',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: Validators.validateRequired,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Primary Business Category',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
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
                        controller: _addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Business Address',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                      if (_commissionRate != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Platform Commission Rate:'),
                              Text(
                                '${(_commissionRate! * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: _isSaving ? null : _save,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
