import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/favorites_provider.dart';
import '../services/database_service.dart';
import 'boss_details_screen.dart';
import 'weapon_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().loadFavorites();
    });
  }

  Future<void> _openItem(BuildContext context, Map<String, dynamic> item) async {
    final db = DatabaseService.instance;

    if (item['type'] == 'boss') {
      final boss = await db.getCachedBoss(item['id'] as String);
      if (boss != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BossDetailsScreen(boss: boss)),
        );
      } else if (mounted) {
        _showUnavailableMessage();
      }
    } else {
      final weapon = await db.getCachedWeapon(item['id'] as String);
      if (weapon != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WeaponDetailsScreen(weapon: weapon)),
        );
      } else if (mounted) {
        _showUnavailableMessage();
      }
    }
  }

  void _showUnavailableMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Brak danych w pamięci lokalnej. Otwórz listę bossów/broni, aby je zsynchronizować.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FavoritesProvider>();
    final favorites = provider.favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Ulubione')),
      body: favorites.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Brak ulubionych elementów.\nDodaj bossów lub broń, klikając ikonę serca na ekranie szczegółów.',
            textAlign: TextAlign.center,
          ),
        ),
      )
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final item = favorites[index];
          final isBoss = item['type'] == 'boss';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: SizedBox(
                width: 56,
                height: 56,
                child: (item['image'] as String).isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: item['image'] as String,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.image_not_supported),
                )
                    : const Icon(Icons.image_not_supported),
              ),
              title: Text(item['name'] as String),
              subtitle: Text(isBoss ? 'Boss' : 'Broń'),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  context.read<FavoritesProvider>().toggleFavorite(
                    id: item['id'] as String,
                    type: item['type'] as String,
                    name: item['name'] as String,
                    image: item['image'] as String,
                  );
                },
              ),
              onTap: () => _openItem(context, item),
            ),
          );
        },
      ),
    );
  }
}