import 'package:flutter/material.dart';
import 'package:trixx/ui/chat/chat_placeholder_screen.dart';
import 'package:trixx/ui/planning/planning_screen.dart';
import 'package:trixx/ui/theme/app_colors.dart';
import 'package:trixx/ui/today/today_screen.dart';

/// Root 3-tab navigation (Aujourd'hui / Chat / Planning), per section 4.3
/// of the cahier des charges.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  static AppShellState? of(BuildContext context) {
    return context.findAncestorStateOfType<AppShellState>();
  }

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  int _index = 0;

  static const _screens = [
    TodayScreen(),
    ChatPlaceholderScreen(),
    PlanningScreen(),
  ];

  void goToTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 76,
          decoration: const BoxDecoration(
            color: AppColors.surfaceLight,
            border: Border(top: BorderSide(color: AppColors.borderLight)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.wb_sunny_outlined,
                label: "Aujourd'hui",
                selected: _index == 0,
                onTap: () => goToTab(0),
              ),
              _NavItem(
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                selected: _index == 1,
                onTap: () => goToTab(1),
              ),
              _NavItem(
                icon: Icons.calendar_today_outlined,
                label: 'Planning',
                selected: _index == 2,
                onTap: () => goToTab(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondaryLight;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
