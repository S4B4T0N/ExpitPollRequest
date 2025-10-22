// lib/screens/grafy.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:exit_poll_request/data/app_db.dart';
import 'package:exit_poll_request/widgets/glass_card.dart';
import 'package:exit_poll_request/widgets/scope_toggle.dart';
import 'package:exit_poll_request/data/people_store.dart';
import 'package:exit_poll_request/data/world_repository.dart';

class GrafyScreen extends StatefulWidget {
  const GrafyScreen({super.key});

  @override
  State<GrafyScreen> createState() => _GrafyScreenState();
}

class _GrafyScreenState extends State<GrafyScreen> {
  ScopeSide _side = ScopeSide.left; // left=Lokálne, right=World
  Future<List<Person>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  bool get _isLocal => _side == ScopeSide.left;

  Future<List<Person>> _load() async {
    if (_isLocal) return AppDb.i.getAllPersons();
    return WorldRepository.i.fetchPeople();
  }

  void _reload() => setState(() => _future = _load());

  Map<String, double> _byParty(List<Person> xs) {
    final m = <String, double>{};
    for (final p in xs) {
      final k = p.party.trim().isEmpty ? 'Nezadané' : p.party;
      m.update(k, (v) => v + 1, ifAbsent: () => 1);
    }
    return m;
  }

  Map<String, double> _byKraj(List<Person> xs) {
    final m = <String, double>{};
    for (final p in xs) {
      final k = p.kraj.trim().isEmpty ? 'Nezadané' : p.kraj;
      m.update(k, (v) => v + 1, ifAbsent: () => 1);
    }
    return m;
  }

  Map<String, double> _byAgeBand(List<Person> xs) {
    int band(int a) {
      if (a < 0) return -1;
      if (a < 18) return 0;
      if (a < 26) return 1;
      if (a < 36) return 2;
      if (a < 46) return 3;
      if (a < 56) return 4;
      if (a < 66) return 5;
      return 6;
    }

    String label(int b) => switch (b) {
          -1 => 'Nezadané',
          0 => '<18',
          1 => '18–25',
          2 => '26–35',
          3 => '36–45',
          4 => '46–55',
          5 => '56–65',
          _ => '66+',
        };

    final m = <String, double>{};
    for (final p in xs) {
      final k = label(band(p.age));
      m.update(k, (v) => v + 1, ifAbsent: () => 1);
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final bg = Image.asset(
      'assets/pozadie/pozadie.jpg',
      fit: BoxFit.cover,
      alignment: Alignment.center,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grafy'),
        actions: [
          IconButton(
            onPressed: _reload,
            tooltip: 'Obnoviť',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: bg),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Zdroj dát:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: ScopeToggle(
                                value: _side,
                                leftLabel: 'Lokálne',
                                rightLabel: 'World',
                                onChanged: (v) {
                                  setState(() {
                                    _side = v;
                                    _future = _load();
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _isLocal ? 'Lokálne' : 'World (Cloud)',
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: FutureBuilder<List<Person>>(
                      future: _future,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snap.hasError) {
                          return GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text('Chyba: ${snap.error}'),
                            ),
                          );
                        }
                        final data = snap.data ?? const <Person>[];
                        if (data.isEmpty) {
                          return const GlassCard(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: Text('Žiadne dáta')),
                            ),
                          );
                        }
                        return _charts(data);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _charts(List<Person> items) {
    final byParty = _byParty(items);
    final byKraj = _byKraj(items);
    final byAge = _byAgeBand(items);

    return ListView(
      children: [
        _pieSection(title: 'Podiel podľa strany', data: byParty),
        const SizedBox(height: 16),
        _pieSection(title: 'Podiel podľa kraja', data: byKraj),
        const SizedBox(height: 16),
        _pieSection(title: 'Podiel podľa vekových pásiem', data: byAge),
      ],
    );
  }

  Widget _pieSection({
    required String title,
    required Map<String, double> data,
  }) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.5,
              child: PieChart(
                dataMap: data,
                chartType: ChartType.disc,
                legendOptions: const LegendOptions(
                  showLegends: true,
                  legendPosition: LegendPosition.right,
                  legendShape: BoxShape.circle,
                ),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValues: true,
                  showChartValuesInPercentage: true,
                  decimalPlaces: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
