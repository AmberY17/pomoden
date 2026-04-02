import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/claude_provider.dart';
import '../theme/app_theme.dart';
import '../shared/session_label.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _keyController = TextEditingController();
  bool _obscure = true;
  bool _saved = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingKey();
  }

  Future<void> _loadExistingKey() async {
    final settings = ref.read(settingsServiceProvider);
    final key = await settings.getClaudeApiKey();
    if (key != null && key.isNotEmpty) {
      _keyController.text = key;
    }
    setState(() => _loading = false);
  }

  Future<void> _saveKey() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) return;

    final settings = ref.read(settingsServiceProvider);
    await settings.saveClaudeApiKey(key);

    // Invalidate provider so it reloads with new key
    ref.invalidate(claudeServiceProvider);

    setState(() => _saved = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saved = false);
  }

  Future<void> _deleteKey() async {
    final settings = ref.read(settingsServiceProvider);
    await settings.deleteClaudeApiKey();
    ref.invalidate(claudeServiceProvider);
    _keyController.clear();
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SizedBox(
                width: 480,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Keys',
                      style: tt.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your keys are stored securely in the macOS keychain '
                      'and never leave your device.',
                      style: tt.bodyMedium?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Claude API key
                    const SessionLabel('Claude API key'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _keyController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: 'sk-ant-...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.borderLight,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.borderLight,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Get your key at console.anthropic.com',
                      style: tt.bodySmall?.copyWith(
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save + delete buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _saveKey,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _saved
                                    ? AppColors.teal
                                    : AppColors.accent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                _saved ? 'Saved!' : 'Save key',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _deleteKey,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.coral,
                              side: const BorderSide(color: AppColors.coral),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Remove'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
