import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/boss_provider.dart';
import '../providers/load_status.dart';
import '../widgets/boss_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_display_widget.dart';
import 'boss_details_screen.dart';

class BossesListScreen extends StatefulWidget {
  const BossesListScreen({super.key});

  @override
  State<BossesListScreen> createState() => _BossesListScreenState();
}

class _BossesListScreenState extends State<BossesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BossProvider>().fetchBosses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BossProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Bossowie')),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(BossProvider provider) {
    switch (provider.status) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const LoadingWidget();
      case LoadStatus.error:
        return ErrorDisplayWidget(
          message: provider.errorMessage,
          onRetry: () => provider.fetchBosses(forceRefresh: true),
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
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.fetchBosses(forceRefresh: true),
                child: ListView.builder(
                  itemCount: provider.bosses.length,
                  itemBuilder: (context, index) {
                    final boss = provider.bosses[index];
                    return BossCard(
                      boss: boss,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BossDetailsScreen(boss: boss),
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