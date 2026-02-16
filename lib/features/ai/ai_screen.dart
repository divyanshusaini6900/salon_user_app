import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/theme.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/responsive.dart';
import '../booking/booking_controller.dart';
import '../booking/booking_providers.dart';
import 'ai_controller.dart';

class AiStudioScreen extends ConsumerStatefulWidget {
  const AiStudioScreen({super.key});

  @override
  ConsumerState<AiStudioScreen> createState() => _AiStudioScreenState();
}

class _AiStudioScreenState extends ConsumerState<AiStudioScreen> {
  final _picker = ImagePicker();

  Future<void> _pickAndUpload() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) return;
    await ref.read(aiControllerProvider.notifier).uploadSelfie(File(file.path));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiControllerProvider);
    final looks = ref.watch(aiLooksProvider);
    final servicesAsync = ref.watch(servicesProvider);
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Style Studio')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(padding, 16, padding, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upload your selfie', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('We analyze face shape and hair texture to recommend looks tailored to you.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.softInk)),
                const SizedBox(height: 16),
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4EEE9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Center(
                    child: state.hasPhoto
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.face_rounded, size: 48, color: AppColors.primary),
                              const SizedBox(height: 8),
                              Text(state.isAnalyzing ? 'Analyzing...' : 'Selfie uploaded',
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.primary),
                              const SizedBox(height: 8),
                              Text('Tap to upload', style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                GradientButton(
                  label: state.hasPhoto ? 'Re-analyze' : 'Upload selfie',
                  onPressed: _pickAndUpload,
                  icon: Icons.auto_awesome,
                ),
                if (state.note != null) ...[
                  const SizedBox(height: 12),
                  Text(state.note!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondary)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _VoiceBookingCard(),
          Text('AI recommendations', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          servicesAsync.when(
            data: (services) {
              if (services.isEmpty) {
                return const Text('No services available');
              }
              return Column(
                children: looks.map((look) {
                  final service = services.firstWhere(
                    (item) => item.id == look.serviceId,
                    orElse: () => services.first,
                  );
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFF3D0BE), Color(0xFFF1E5DA)]),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.auto_awesome, color: AppColors.secondary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(look.name, style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 4),
                              Text(look.tagline,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.softInk)),
                              const SizedBox(height: 8),
                              Text(look.description, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          children: [
                            Text('?${service.price.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () {
                                ref.read(bookingControllerProvider.notifier).selectService(service);
                                context.go('/service/${service.id}');
                              },
                              child: const Text('Book this look'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => const Text('Failed to load services'),
          ),
          const SizedBox(height: 12),
          _EdgeCaseCard(),
        ],
      ),
    );
  }
}

class _VoiceBookingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.mic_rounded, color: AppColors.secondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Voice booking', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text('Book hands-free using natural language.', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => context.go('/voice'),
            child: const Text('Try now'),
          ),
        ],
      ),
    );
  }
}

class _EdgeCaseCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3ED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edge cases we handle', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _EdgeCaseRow(icon: Icons.visibility_off, text: 'Low light? We prompt a better angle.'),
          const SizedBox(height: 8),
          _EdgeCaseRow(icon: Icons.face_retouching_off, text: 'No face detected? We ask for a clearer selfie.'),
          const SizedBox(height: 8),
          _EdgeCaseRow(icon: Icons.person_outline, text: 'Multiple faces? You can crop before analysis.'),
        ],
      ),
    );
  }
}

class _EdgeCaseRow extends StatelessWidget {
  const _EdgeCaseRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.secondary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}
