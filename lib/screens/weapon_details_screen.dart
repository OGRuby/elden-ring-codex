import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/weapon.dart';
import '../services/api_service.dart';
import '../providers/favorites_provider.dart';

class WeaponDetailsScreen extends StatefulWidget {
  final Weapon weapon;

  const WeaponDetailsScreen({super.key, required this.weapon});

  @override
  State<WeaponDetailsScreen> createState() => _WeaponDetailsScreenState();
}

class _WeaponDetailsScreenState extends State<WeaponDetailsScreen> {
  final ApiService _apiService = ApiService();

  late Weapon _weapon;
  bool _isRefreshing = true;

  @override
  void initState() {
    super.initState();
    _weapon = widget.weapon;
    context.read<FavoritesProvider>().loadFavorites();
    _loadFreshDetails();
  }

  Future<void> _loadFreshDetails() async {
    try {
      final fresh = await _apiService.getWeaponDetails(_weapon.id);
      if (mounted) {
        setState(() {
          _weapon = fresh;
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
    final isFav = favoritesProvider.isFavorite(_weapon.id, 'weapon');

    return Scaffold(
      appBar: AppBar(
        title: Text(_weapon.name),
        actions: [
          IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              favoritesProvider.toggleFavorite(
                id: _weapon.id,
                type: 'weapon',
                name: _weapon.name,
                image: _weapon.image,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_weapon.image.isNotEmpty)
              CachedNetworkImage(
                imageUrl: _weapon.image,
                height: 250,
                width: double.infinity,
                fit: BoxFit.contain,
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
                    _weapon.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.category, size: 18),
                      const SizedBox(width: 4),
                      Text(_weapon.category),
                      const SizedBox(width: 16),
                      const Icon(Icons.fitness_center, size: 18),
                      const SizedBox(width: 4),
                      Text('${_weapon.weight}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Opis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _weapon.description.isNotEmpty
                        ? _weapon.description
                        : 'Brak opisu.',
                  ),
                  _buildStatSection('Atak', _weapon.attack),
                  _buildStatSection('Obrona', _weapon.defence),
                  _buildStatSection(
                      'Wymagane atrybuty', _weapon.requiredAttributes),
                  _buildStatSection('Skalowanie', _weapon.scalesWith),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSection(String title, List<StatEntry> stats) {
    if (stats.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: stats.map((stat) {
              return Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${stat.name}: ${stat.value}'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}