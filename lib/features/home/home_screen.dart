import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/responsive.dart';
import '../../shared/widgets/section_header.dart';
import '../../l10n/app_localizations.dart';
import '../booking/booking_controller.dart';
import '../booking/booking_providers.dart';
import '../booking/models.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesStream = ref.watch(servicesStreamProvider);
    final padding = Responsive.horizontalPadding(context);
    final isWide = Responsive.isTablet(context) || Responsive.isDesktop(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFDF1E8), Color(0xFFF8E7E1)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(padding, 80, padding, 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(context.l10n.t('app_name'), style: Theme.of(context).textTheme.displayMedium),
                            const SizedBox(height: 12),
                            Text(
                              context.l10n.t('home_tagline'),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.softInk),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _InfoPill(label: '4.9 ${context.l10n.t('rating')}', icon: Icons.star_rounded),
                                const _InfoPill(label: '9 AM - 8 PM', icon: Icons.schedule_rounded),
                                const _InfoPill(label: 'Bandra - Mumbai', icon: Icons.place_rounded),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isWide)
                        Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: SizedBox(
                            width: 220,
                            child: GradientButton(
                              label: context.l10n.t('book_ai'),
                              onPressed: () => context.go('/ai'),
                              icon: Icons.auto_awesome,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(padding, 24, padding, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: context.l10n.t('home_top'),
                    subtitle: context.l10n.t('home_sub'),
                    trailing: TextButton(
                      onPressed: () {},
                      child: Text(context.l10n.t('view_all')),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _SearchBar(),
                ],
              ),
            ),
          ),
          StreamBuilder<List<Service>>(
            stream: servicesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Failed to load services'),
                  ),
                );
              }
              final services = snapshot.data ?? [];
              if (services.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No services available'),
                  ),
                );
              }
              return SliverPadding(
                padding: EdgeInsets.fromLTRB(padding, 0, padding, 32),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 2 : 1,
                    childAspectRatio: isWide ? 2.6 : 2.2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final service = services[index];
                      return _ServiceCard(
                        service: service,
                        onTap: () {
                          ref.read(bookingControllerProvider.notifier).selectService(service);
                          context.go('/service/${service.id}');
                        },
                      );
                    },
                    childCount: services.length,
                  ),
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(padding, 0, padding, 32),
              child: const _PromoBanner(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.onTap});

  final Service service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF5DCC9), Color(0xFFEEC2A3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.spa_outlined, color: AppColors.primary, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(service.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text('${service.duration.inMinutes} min ? ?${service.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.softInk)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                      const SizedBox(width: 4),
                      Text(service.rating.toString(), style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: context.l10n.t('search_hint'),
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(icon: const Icon(Icons.tune_rounded), onPressed: () {}),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF2F1D1B), Color(0xFF6D3B34)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.t('promo_title'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                Text(context.l10n.t('promo_desc'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white70)),
            child: Text(context.l10n.t('explore')),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
