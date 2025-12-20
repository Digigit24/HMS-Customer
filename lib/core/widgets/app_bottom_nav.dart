import 'package:flutter/material.dart';

class AppBottomNavItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;

  const AppBottomNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
  });
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<AppBottomNavItem> items;
  final ValueChanged<int> onChanged;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onChanged,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: scheme.primary,
      unselectedItemColor: scheme.onSurfaceVariant,
      showUnselectedLabels: true,
      items: items
          .map(
            (i) => BottomNavigationBarItem(
              icon: Icon(i.icon),
              activeIcon: Icon(i.activeIcon ?? i.icon),
              label: i.label,
            ),
          )
          .toList(),
    );
  }
}
