import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/bottom_nav.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _indexFromLocation(GoRouterState.of(context).uri.toString()),
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }

  int _indexFromLocation(String location) {
    if (location.startsWith('/bookings')) return 1;
    if (location.startsWith('/ai')) return 2;
    if (location.startsWith('/chat')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 1:
        context.go('/bookings');
        return;
      case 2:
        context.go('/ai');
        return;
      case 3:
        context.go('/chat');
        return;
      case 4:
        context.go('/profile');
        return;
      default:
        context.go('/home');
        return;
    }
  }
}
