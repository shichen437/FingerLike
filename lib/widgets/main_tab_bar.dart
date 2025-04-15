import 'package:flutter/material.dart';
import 'tab_button.dart';

class MainTabBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const MainTabBar({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: theme.primaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TabButton(
            icon: Icons.mouse,
            label: '点击',
            isSelected: selectedIndex == 0,
            onTap: () => onIndexChanged(0),
          ),
          TabButton(
            icon: Icons.history,
            label: '记录',
            isSelected: selectedIndex == 1,
            onTap: () => onIndexChanged(1),
          ),
          TabButton(
            icon: Icons.settings,
            label: '设置',
            isSelected: selectedIndex == 2,
            onTap: () => onIndexChanged(2),
          ),
        ],
      ),
    );
  }
}
