import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/responsive.dart';
import 'booking_controller.dart';

class SuccessScreen extends ConsumerWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withOpacity(0.1),
                ),
                child: const Icon(Icons.check_circle, size: 84, color: AppColors.success),
              ),
              const SizedBox(height: 24),
              Text('Booking Confirmed', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text("Your appointment is locked in. We can't wait to pamper you!",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.softInk)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Booking ID: LS-2026-0421', style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 240,
                child: GradientButton(
                  label: 'Back to home',
                  onPressed: () {
                    ref.read(bookingControllerProvider.notifier).reset();
                    context.go('/home');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
