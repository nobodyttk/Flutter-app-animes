// lib/widgets/modern_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/search_screen.dart';
import '../screens/downloads_screen.dart';
import '../screens/profile_screen.dart'; 
import 'theme_toggle_button.dart';

class ModernHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSearchPressed;
  final VoidCallback? onArchivePressed;
  final VoidCallback? onProfilePressed;

  const ModernHeader({
    Key? key,
    this.onSearchPressed,
    this.onArchivePressed,
    this.onProfilePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).appBarTheme.foregroundColor;
    final borderColor = Colors.grey.shade700;

    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      titleSpacing: NavigationToolbar.kMiddleSpacing,
      title: SvgPicture.asset(
        'assets/logos/logo.svg',
        height: 30,
        colorFilter: ColorFilter.mode(
          iconColor ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
          BlendMode.srcIn,
        ),
      ),
      centerTitle: false,
      actions: [
        const ThemeToggleButton(),
        _buildActionIcon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          },
          icon: Icons.search,
          iconColor: iconColor,
          borderColor: borderColor,
        ),
        _buildActionIcon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DownloadsScreen()),
            );
          },
          icon: Icons.archive_outlined,
          iconColor: iconColor,
          borderColor: borderColor,
        ),
        _buildActionIcon(
        
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          icon: Icons.person_outline,
          iconColor: iconColor,
          borderColor: borderColor,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildActionIcon({
    required VoidCallback onPressed,
    required IconData icon,
    required Color? iconColor,
    required Color borderColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor.withOpacity(0.8),
              width: 1.5,
            ),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}