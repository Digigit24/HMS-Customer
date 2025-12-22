// File Path: lib/core/widgets/app_bottom_nav.dart

import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _NavItem(
                item: items[index],
                isSelected: index == currentIndex,
                onTap: () => onChanged(index),
                theme: theme,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final AppBottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: -2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected
        ? widget.theme.colorScheme.primary
        : widget.theme.colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: widget.onTap,
        splashColor: widget.theme.colorScheme.primary.withOpacity(0.1),
        highlightColor: widget.theme.colorScheme.primary.withOpacity(0.05),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with background
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? widget.theme.colorScheme.primary.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Icon(
                      widget.isSelected
                          ? (widget.item.activeIcon ?? widget.item.icon)
                          : widget.item.icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Label
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: color,
                      letterSpacing: 0.2,
                    ),
                    child: Text(widget.item.label),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
