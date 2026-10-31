import 'package:flutter/material.dart';
import '../../core/storage/session_manager.dart';
import '../../core/validation/validators.dart';
import '../../core/widgets/common_views.dart';
import '../../data/api/api_service.dart';
import '../../data/models/group.dart';
import 'group_detail_screen.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = SessionManager.instance.userId;
    if (userId == null || userId <= 0) return;

    setState(() => _isLoading = true);
    try {
      final req = JoinGroupRequest(
        joinCode: _codeController.text.trim().toUpperCase(),
        touristId: userId,
      );
      final group = await _apiService.joinGroup(req);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined group!')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => GroupDetailScreen(groupId: group.id ?? 0),
          ),
        );
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
        title: const Text('Join Travel Group'),
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
                const Text(
                  'Enter the 6-character join code shared by your group organizer.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Group Join Code',
                    hintText: 'e.g., GR-4A9B',
                    prefixIcon: Icon(Icons.vpn_key_outlined),
                  ),
                  validator: Validators.validateRequired,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: const Icon(Icons.group_add),
                  label: const Text('Join Group'),
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
