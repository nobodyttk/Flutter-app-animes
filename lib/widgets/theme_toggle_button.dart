import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        IconData icon;
        String tooltip;
        
        // Define o ícone baseado no tema atual
        switch (themeProvider.themeMode) {
          case ThemeMode.light:
            icon = Icons.light_mode;
            tooltip = 'Modo Claro';
            break;
          case ThemeMode.dark:
            icon = Icons.dark_mode;
            tooltip = 'Modo Escuro';
            break;
          case ThemeMode.system:
            icon = Icons.brightness_auto;
            tooltip = 'Automático';
            break;
        }
        
        return IconButton(
          icon: Icon(icon, size: 28),
          tooltip: tooltip,
          onPressed: () {
            // Mostra um menu para escolher o tema
            _showThemeDialog(context, themeProvider);
          },
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Escolher Tema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text('Claro'),
                trailing: themeProvider.themeMode == ThemeMode.light
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Escuro'),
                trailing: themeProvider.themeMode == ThemeMode.dark
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_auto),
                title: const Text('Automático'),
                subtitle: const Text('Segue o sistema'),
                trailing: themeProvider.themeMode == ThemeMode.system
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
