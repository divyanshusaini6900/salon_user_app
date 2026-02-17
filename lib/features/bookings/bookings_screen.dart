import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../shared/widgets/responsive.dart';
import '../booking/booking_providers.dart';
import 'user_booking.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = Responsive.horizontalPadding(context);
    final stream = ref.watch(userBookingsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Bookings')),
      body: StreamBuilder<List<UserBooking>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load bookings'));
          }
          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings yet'));
          }
          bookings.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(padding, 16, padding, 32),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final dateLabel = DateFormat('EEE, d MMM ? hh:mm a').format(booking.dateTime);
              return _BookingCard(
                title: booking.serviceName,
                date: dateLabel,
                stylist: booking.stylistName.isEmpty ? '' : 'with ${booking.stylistName}',
                status: booking.status,
              );
            },
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.title, required this.date, required this.stylist, required this.status});

  final String title;
  final String date;
  final String stylist;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.event_available, color: AppColors.secondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(date, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.softInk)),
                if (stylist.isNotEmpty)
                  Text(stylist, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.softInk)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.success)),
          ),
        ],
      ),
    );
  }
}
