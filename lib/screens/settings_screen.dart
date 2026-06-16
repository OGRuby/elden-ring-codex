import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/boss_provider.dart';
import '../providers/weapon_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _clearCache(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset cache'),
        content: const Text(
          'Czy na pewno chcesz wyczyścić lokalne dane? Dane zostaną ponownie pobrane z internetu przy następnym otwarciu list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Wyczyść'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<BossProvider>().clearCache();
      await context.read<WeaponProvider>().clearCache();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache wyczyszczony.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ustawienia')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Wygląd',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          SwitchListTile(
            title: const Text('Ciemny motyw'),
            subtitle: Text(themeProvider.isDark ? 'Włączony' : 'Wyłączony'),
            secondary: Icon(
              themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
            ),
            value: themeProvider.isDark,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Dane',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Wyczyść cache'),
            subtitle: const Text('Usuwa lokalne dane bossów i broni'),
            onTap: () => _clearCache(context),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'O aplikacji',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Elden Ring Codex'),
            subtitle: Text('Wersja 1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Źródło danych'),
            subtitle: Text('eldenring.fanapis.com'),
          ),
          const ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Autor'),
            subtitle: Text('Adam Kozuń'),
          ),
        ],
      ),
    );
  }
}