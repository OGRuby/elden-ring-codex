import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/boss.dart';
import '../services/api_service.dart';
import '../providers/favorites_provider.dart';

class BossDetailsScreen extends StatefulWidget {
  final Boss boss;

  const BossDetailsScreen({super.key, required this.boss});

  @override
  State<BossDetailsScreen> createState() => _BossDetailsScreenState();
}

class _BossDetailsScreenState extends State<BossDetailsScreen> {
  final ApiService _apiService = ApiService();

  late Boss _boss;
  bool _isRefreshing = true;

  @override
  void initState() {
    super.initState();
    _boss = widget.boss;
    context.read<FavoritesProvider>().loadFavorites();
    _loadFreshDetails();
  }

  Future<void> _loadFreshDetails() async {
    try {
      final fresh = await _apiService.getBossDetails(_boss.id);
      if (mounted) {
        setState(() {
          _boss = fresh;
          _isRefreshing = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFav = favoritesProvider.isFavorite(_boss.id, 'boss');

    return Scaffold(
      appBar: AppBar(
        title: Text(_boss.name),
        actions: [
          IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              favoritesProvider.toggleFavorite(
                id: _boss.id,
                type: 'boss',
                name: _boss.name,
                image: _boss.image,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_boss.image.isNotEmpty)
              CachedNetworkImage(
                imageUrl: _boss.image,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(
                  height: 250,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => const SizedBox(
                  height: 250,
                  child: Center(child: Icon(Icons.image_not_supported, size: 64)),
                ),
              ),
            if (_isRefreshing)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: LinearProgressIndicator(),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _boss.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 18),
                      const SizedBox(width: 4),
                      Text(_boss.location),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.favorite, size: 18, color: Colors.red),
                      const SizedBox(width: 4),
                      Text('HP: ${_boss.healthPoints}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Opis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _boss.description.isNotEmpty
                        ? _boss.description
                        : 'Brak opisu.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Drop',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_boss.drops.isEmpty)
                    const Text('Brak danych o drop.')
                  else
                    ..._boss.drops.map(
                          (drop) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 6),
                            const SizedBox(width: 8),
                            Text(drop),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}