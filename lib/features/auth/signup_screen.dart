import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/responsive.dart';
import 'auth_controller.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _dob = TextEditingController();
  final _address = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _enableBiometric = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _dob.dispose();
    _address.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
            child: ListView(
              shrinkWrap: true,
              children: [
                Text('Create your account', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                TextField(controller: _name, decoration: const InputDecoration(hintText: 'Full name')),
                const SizedBox(height: 12),
                TextField(controller: _phone, decoration: const InputDecoration(hintText: 'Mobile number')),
                const SizedBox(height: 12),
                TextField(controller: _dob, decoration: const InputDecoration(hintText: 'Date of birth (DD/MM/YYYY)')),
                const SizedBox(height: 12),
                TextField(controller: _address, decoration: const InputDecoration(hintText: 'Address')),
                const SizedBox(height: 12),
                TextField(controller: _email, decoration: const InputDecoration(hintText: 'Email')),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  decoration: const InputDecoration(hintText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirm,
                  decoration: const InputDecoration(hintText: 'Confirm password'),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _enableBiometric,
                  onChanged: (value) => setState(() => _enableBiometric = value),
                  title: const Text('Enable Face ID / biometric login on this device'),
                ),
                if (auth.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(auth.error!, style: const TextStyle(color: Colors.red)),
                  ),
                GradientButton(
                  label: auth.isLoading ? 'Please wait...' : 'Create account',
                  onPressed: () {
                    if (_password.text != _confirm.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Passwords do not match')),
                      );
                      return;
                    }
                    ref.read(authControllerProvider.notifier).signUp(
                          email: _email.text.trim(),
                          password: _password.text,
                          name: _name.text,
                          phone: _phone.text,
                          dob: _dob.text,
                          address: _address.text,
                          enableBiometric: _enableBiometric,
                        );
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/auth/login'),
                  child: const Text('Back to login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
