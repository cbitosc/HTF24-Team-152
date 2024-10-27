import 'package:flutter/material.dart';
import '../../services/integrations/portal_manager.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/custom_button.dart';

class PortalSettingsScreen extends StatefulWidget {
  const PortalSettingsScreen({Key? key}) : super(key: key);

  @override
  State<PortalSettingsScreen> createState() => _PortalSettingsScreenState();
}

class _PortalSettingsScreenState extends State<PortalSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _linkedInApiKey;
  String? _linkedInApiSecret;
  String? _indeedApiKey;

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await PortalManager().saveApiKeys(
        linkedInApiKey: _linkedInApiKey,
        linkedInApiSecret: _linkedInApiSecret,
        indeedApiKey: _indeedApiKey,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Portal Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LinkedIn Integration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CustomInput(
                label: 'API Key',
                onSaved: (value) => _linkedInApiKey = value,
              ),
              const SizedBox(height: 12),
              CustomInput(
                label: 'API Secret',
                onSaved: (value) => _linkedInApiSecret = value,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              const Text(
                'Indeed Integration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CustomInput(
                label: 'API Key',
                onSaved: (value) => _indeedApiKey = value,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Save Settings',
                onPressed: _saveSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
