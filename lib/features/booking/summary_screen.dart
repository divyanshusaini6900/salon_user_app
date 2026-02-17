import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/responsive.dart';
import 'booking_controller.dart';
import 'booking_providers.dart';
import '../auth/auth_controller.dart';
import '../../app/firebase_bootstrap.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingControllerProvider);
    final padding = Responsive.horizontalPadding(context);
    final service = booking.service;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking summary')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(padding, 16, padding, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service?.name ?? 'Service', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                if (booking.stylist != null)
                  Text('Stylist: ${booking.stylist!.name}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.softInk)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      booking.date == null ? 'Choose date' : DateFormat('EEE, d MMM').format(booking.date!),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 18),
                    const SizedBox(width: 6),
                    Text(booking.timeSlot ?? 'Select time', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Price breakdown', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          _PriceRow(label: 'Service', value: service != null ? '?${service.price.toStringAsFixed(0)}' : '?0'),
          const SizedBox(height: 8),
          const _PriceRow(label: 'Stylist fee', value: '?199'),
          const SizedBox(height: 8),
          const _PriceRow(label: 'GST', value: '?72'),
          const Divider(height: 32),
          _PriceRow(label: 'Total', value: service != null ? '?${(service.price + 271).toStringAsFixed(0)}' : '?0', isTotal: true),
          const SizedBox(height: 32),
          GradientButton(
            label: 'Confirm booking',
            isEnabled: booking.isComplete,
            onPressed: () async {
              if (!booking.isComplete) return;
              if (FirebaseBootstrap.enableFirebase) {
                final profile = ref.read(authControllerProvider).profile;
                final user = FirebaseAuth.instance.currentUser;
                final service = booking.service;
                if (service != null && booking.date != null && booking.timeSlot != null && user != null) {
                  DateTime? bookingDateTime;
                  try {
                    final parsed = DateFormat('hh:mm a').parse(booking.timeSlot!);
                    bookingDateTime = DateTime(
                      booking.date!.year,
                      booking.date!.month,
                      booking.date!.day,
                      parsed.hour,
                      parsed.minute,
                    );
                  } catch (_) {
                    bookingDateTime = booking.date;
                  }
                  await ref.read(firestoreServiceProvider).createBooking({
                    'userId': user.uid,
                    'customerName': profile?.name ?? 'Customer',
                    'customerEmail': profile?.email ?? (user.email ?? ''),
                    'customerPhone': profile?.phone ?? '',
                    'serviceId': service.id,
                    'serviceName': service.name,
                    'stylistName': booking.stylist?.name ?? '',
                    'dateTime': bookingDateTime ?? booking.date,
                    'timeSlot': booking.timeSlot,
                    'status': 'Confirmed',
                    'price': service.price,
                    'createdAt': DateTime.now(),
                  });
                }
              }
              context.go('/success');
            },
          ),
          const SizedBox(height: 12),
          Text('Free cancellation up to 6 hours before your slot.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.softInk)),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value, this.isTotal = false});

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final style = isTotal ? Theme.of(context).textTheme.titleLarge : Theme.of(context).textTheme.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style?.copyWith(color: isTotal ? AppColors.ink : AppColors.softInk)),
        Text(value, style: style?.copyWith(color: AppColors.ink)),
      ],
    );
  }
}
