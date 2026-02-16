import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/responsive.dart';
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

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome back', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Login with password or Face ID / biometric.',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                ToggleButtons(
                  isSelected: [_useBiometric == false, _useBiometric == true],
                  onPressed: (index) {
                    setState(() => _useBiometric = index == 1);
                  },
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Password login')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Face ID / Biometric')),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(controller: _email, decoration: const InputDecoration(hintText: 'Email')),
                const SizedBox(height: 12),
                if (!_useBiometric) ...[
                  TextField(
                    controller: _password,
                    decoration: const InputDecoration(hintText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _rememberForBiometric,
                    onChanged: (value) => setState(() => _rememberForBiometric = value),
                    title: const Text('Enable biometric login on this device'),
                  ),
                ],
                if (auth.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(auth.error!, style: const TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 12),
                GradientButton(
                  label: auth.isLoading ? 'Please wait...' : (_useBiometric ? 'Continue with Face ID' : 'Login'),
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
                  child: const Text('Create new account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
