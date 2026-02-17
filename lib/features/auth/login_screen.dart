import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/responsive.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/language_provider.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _useBiometric = false;
  bool _rememberForBiometric = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('English'),
                onTap: () {
                  ref.read(languageProvider.notifier).state = const Locale('en');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('?????'),
                onTap: () {
                  ref.read(languageProvider.notifier).state = const Locale('hi');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguagePicker,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(context.l10n.t('login_title'), style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(context.l10n.t('login_subtitle'),
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                ToggleButtons(
                  isSelected: [_useBiometric == false, _useBiometric == true],
                  onPressed: (index) {
                    setState(() => _useBiometric = index == 1);
                  },
                  children: [
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(context.l10n.t('password_login'))),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(context.l10n.t('biometric_login'))),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(controller: _email, decoration: InputDecoration(hintText: context.l10n.t('email'))),
                const SizedBox(height: 12),
                if (!_useBiometric) ...[
                  TextField(
                    controller: _password,
                    decoration: InputDecoration(hintText: context.l10n.t('password')),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _rememberForBiometric,
                    onChanged: (value) => setState(() => _rememberForBiometric = value),
                    title: Text(context.l10n.t('enable_biometric')),
                  ),
                ],
                if (auth.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(auth.error!, style: const TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 12),
                GradientButton(
                  label: auth.isLoading ? 'Please wait...' : (_useBiometric ? context.l10n.t('continue_face') : context.l10n.t('login')),
                  onPressed: () {
                    if (_useBiometric) {
                      ref.read(authControllerProvider.notifier).loginWithBiometric(email: _email.text.trim());
                    } else {
                      ref.read(authControllerProvider.notifier).loginWithPassword(
                            email: _email.text.trim(),
                            password: _password.text,
                            rememberForBiometric: _rememberForBiometric,
                          );
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/auth/signup'),
                  child: Text(context.l10n.t('create_account')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
