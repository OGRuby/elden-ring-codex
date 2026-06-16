import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weapon_provider.dart';
import '../providers/load_status.dart';
import '../widgets/weapon_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_display_widget.dart';
import 'weapon_details_screen.dart';

class WeaponsListScreen extends StatefulWidget {
  const WeaponsListScreen({super.key});

  @override
  State<WeaponsListScreen> createState() => _WeaponsListScreenState();
}

class _WeaponsListScreenState extends State<WeaponsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeaponProvider>().fetchWeapons();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeaponProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Broń')),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(WeaponProvider provider) {
    switch (provider.status) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const LoadingWidget();
      case LoadStatus.error:
        return ErrorDisplayWidget(
          message: provider.errorMessage,
          onRetry: () => provider.fetchWeapons(forceRefresh: true),
        );
      case LoadStatus.loaded:
        return Column(
          children: [
            if (provider.isOffline)
              Container(
                width: double.infinity,
                color: Colors.orange.shade800,
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: const Text(
                  'Brak połączenia - wyświetlane dane zapisane lokalnie',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: TextField(
                controller: _searchController,
                onChanged: (value) =>
                    context.read<WeaponProvider>().setSearchQuery(value),
                decoration: InputDecoration(
                  hintText: 'Szukaj broni...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: provider.searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<WeaponProvider>().setSearchQuery('');
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.fetchWeapons(forceRefresh: true),
                child: provider.weapons.isEmpty
                    ? const Center(child: Text('Brak wyników wyszukiwania.'))
                    : ListView.builder(
                  itemCount: provider.weapons.length,
                  itemBuilder: (context, index) {
                    final weapon = provider.weapons[index];
                    return WeaponCard(
                      weapon: weapon,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                WeaponDetailsScreen(weapon: weapon),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
    }
  }
}