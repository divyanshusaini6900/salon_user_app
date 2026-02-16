import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/responsive.dart';
import 'booking_controller.dart';
import 'booking_providers.dart';

class DateTimeScreen extends ConsumerWidget {
  const DateTimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingControllerProvider);
    final timeSlots = ref.watch(timeSlotsProvider);
    final padding = Responsive.horizontalPadding(context);
    final dates = List.generate(7, (index) => DateTime.now().add(Duration(days: index)));

    return Scaffold(
      appBar: AppBar(title: const Text('Select date & time')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(padding, 16, padding, 32),
        children: [
          Text('Pick a date', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final date = dates[index];
                final isSelected = booking.date != null && DateUtils.isSameDay(booking.date, date);
                return InkWell(
                  onTap: () => ref.read(bookingControllerProvider.notifier).selectDate(date),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 78,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('EEE').format(date),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: isSelected ? Colors.white70 : AppColors.softInk)),
                        const SizedBox(height: 6),
                        Text(DateFormat('dd').format(date),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(color: isSelected ? Colors.white : AppColors.ink)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text('Available slots', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: timeSlots.map((slot) {
              final isSelected = booking.timeSlot == slot;
              final isDisabled = slot.startsWith('12') || slot.startsWith('09:00');
              return ChoiceChip(
                label: Text(slot),
                selected: isSelected,
                onSelected: isDisabled ? null : (_) => ref.read(bookingControllerProvider.notifier).selectTime(slot),
                disabledColor: Colors.grey.shade200,
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          GradientButton(
            label: 'Continue to summary',
            isEnabled: booking.date != null && booking.timeSlot != null,
            onPressed: () => context.go('/summary'),
          ),
        ],
      ),
    );
  }
}
