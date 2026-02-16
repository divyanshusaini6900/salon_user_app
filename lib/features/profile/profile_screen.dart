import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/responsive.dart';
import '../auth/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = Responsive.horizontalPadding(context);
    final profile = ref.watch(authControllerProvider).profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(padding, 16, padding, 32),
        children: [
          const CircleAvatar(radius: 42, backgroundColor: Color(0xFFEAD6C5), child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 12),
          Text(profile?.name ?? 'Guest', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(profile?.email ?? '', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          _ProfileTile(title: 'Mobile', icon: Icons.phone, subtitle: profile?.phone ?? '-'),
          const SizedBox(height: 12),
          _ProfileTile(title: 'Date of birth', icon: Icons.cake_outlined, subtitle: profile?.dob ?? '-'),
          const SizedBox(height: 12),
          _ProfileTile(title: 'Address', icon: Icons.location_on_outlined, subtitle: profile?.address ?? '-'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.title, required this.icon, required this.subtitle});

  final String title;
  final IconData icon;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: const Color(0xFFF2E7DD), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: Colors.black87),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _BiometricSection extends ConsumerStatefulWidget {
  const _BiometricSection({required this.email});

  final String email;

  @override
  ConsumerState<_BiometricSection> createState() => _BiometricSectionState();
}

class _BiometricSectionState extends ConsumerState<_BiometricSection> {
  bool _enabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.email.isEmpty) return;
    final enabled = await ref.read(authControllerProvider.notifier).isBiometricEnabledForEmail(widget.email);
    if (mounted) {
      setState(() {
        _enabled = enabled;
        _loading = false;
      });
    }
  }

  Future<void> _toggle(bool value) async {
    if (widget.email.isEmpty) return;
    if (value) {
      final password = await _askPassword(context);
      if (password == null || password.isEmpty) return;
      await ref.read(authControllerProvider.notifier).setBiometricEnabled(
            email: widget.email,
            enabled: true,
            password: password,
          );
    } else {
      await ref.read(authControllerProvider.notifier).setBiometricEnabled(
            email: widget.email,
            enabled: false,
          );
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(),
      );
    }
    return SwitchListTile(
      value: _enabled,
      onChanged: _toggle,
      title: const Text('Biometric login'),
      subtitle: const Text('Enable or disable Face ID / fingerprint for this account on this device.'),
    );
  }
}

Future<String?> _askPassword(BuildContext context) async {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm password'),
      content: TextField(
        controller: controller,
        obscureText: true,
        decoration: const InputDecoration(hintText: 'Enter your password'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Confirm')),
      ],
    ),
  );
}
