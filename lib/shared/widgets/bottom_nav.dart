import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.softInk.withOpacity(0.6),
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_rounded), label: context.l10n.t('home_top')),
          BottomNavigationBarItem(icon: const Icon(Icons.calendar_month_rounded), label: context.l10n.t('your_bookings')),
          const BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_rounded), label: 'AI'),
          BottomNavigationBarItem(icon: const Icon(Icons.chat_bubble_outline), label: context.l10n.t('ai_concierge')),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: context.l10n.t('profile')),
        ],
      ),
    );
  }
}
