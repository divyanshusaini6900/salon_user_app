import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../shared/widgets/responsive.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Bookings')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(padding, 16, padding, 32),
        children: [
          _BookingCard(
            title: 'Signature Haircut',
            date: 'Sat, 22 Feb ? 5:00 PM',
            stylist: 'with Yoyo',
            status: 'Confirmed',
          ),
          const SizedBox(height: 16),
          _BookingCard(
            title: 'Scalp Renewal Spa',
            date: 'Sun, 2 Mar ? 11:30 AM',
            stylist: 'with Maya',
            status: 'Upcoming',
          ),
        ],
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
