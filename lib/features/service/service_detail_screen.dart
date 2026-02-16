import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/responsive.dart';
import '../booking/booking_controller.dart';
import '../booking/booking_providers.dart';

class ServiceDetailScreen extends ConsumerWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);
    final stylistsAsync = ref.watch(stylistsProvider);
    final padding = Responsive.horizontalPadding(context);
    final isWide = Responsive.isTablet(context) || Responsive.isDesktop(context);

    return servicesAsync.when(
      data: (services) {
        final service = services.firstWhere((s) => s.id == serviceId);
        return Scaffold(
          appBar: AppBar(title: const Text('Service Detail')),
          body: ListView(
        padding: EdgeInsets.fromLTRB(padding, 12, padding, 32),
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFFFCE3D0), Color(0xFFF6C8AA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(Icons.spa_rounded, size: 64, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(service.name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 18),
              const SizedBox(width: 6),
              Text('${service.duration.inMinutes} min', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(width: 16),
              const Icon(Icons.star_rounded, size: 18, color: AppColors.warning),
              const SizedBox(width: 6),
              Text('${service.rating} rating', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 16),
          Text(service.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.softInk)),
          const SizedBox(height: 24),
          Text('Choose a stylist (optional)', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          stylistsAsync.when(
            data: (stylists) => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: stylists.map((stylist) {
                final isSelected = ref.watch(bookingControllerProvider).stylist == stylist;
                return ChoiceChip(
                  label: Text('${stylist.name} ? ${stylist.level}'),
                  selected: isSelected,
                  onSelected: (_) => ref.read(bookingControllerProvider.notifier).selectStylist(stylist),
                );
              }).toList(),
            ),
            loading: () => const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),
            error: (err, stack) => const Text('Failed to load stylists'),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Starting at', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text('?${service.price.toStringAsFixed(0)}', style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                ),
                SizedBox(
                  width: isWide ? 260 : 160,
                  child: GradientButton(
                    label: 'Book now',
                    onPressed: () {
                      ref.read(bookingControllerProvider.notifier).selectService(service);
                      context.go('/schedule');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => const Scaffold(body: Center(child: Text('Failed to load service'))),
    );
  }
}
