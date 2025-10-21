// lib/screens/grafy.dart
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:exit_poll_request/data/people_store.dart';
import 'package:exit_poll_request/widgets/glass_card.dart';
import 'package:exit_poll_request/widgets/scope_toggle.dart';
import 'package:exit_poll_request/data/world_repository.dart';

enum DataScope { local, world }

class GrafyScreen extends StatefulWidget {
  const GrafyScreen({super.key});

  @override
  State<GrafyScreen> createState() => _GrafyScreenState();
}

class _GrafyScreenState extends State<GrafyScreen> {
  DataScope _scope = DataScope.local;
  Future<List<Person>>? _worldFuture;

  @override
  void initState() {
    super.initState();
    _worldFuture = WorldRepository.i.fetchPeople(); // prednačítanie
  }

  @override
  Widget build(BuildContext context) {
    final isWorld = _scope == DataScope.world;

    return Scaffold(
      appBar: AppBar(title: const Text('Grafy')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/pozadie/pozadie.jpg', fit: BoxFit.cover),
          Container(color: const Color.fromRGBO(0, 0, 0, 0.10)),
          Column(
            children: [
              // prepínač World | Local
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: ScopeToggle(
                  leftLabel: 'World',
                  rightLabel: 'Local',
                  value: isWorld ? ScopeSide.left : ScopeSide.right,
                  onChanged: (v) {
                    setState(() {
                      _scope = v == ScopeSide.left
                          ? DataScope.world
                          : DataScope.local;
                    });
                  },
                ),
              ),

              // nadpis + počet respondentov
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: _HeaderLine(scope: _scope, worldFuture: _worldFuture),
              ),

              // obsah
              Expanded(
                child: isWorld
                    ? FutureBuilder<List<Person>>(
                        future: _worldFuture,
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snap.hasError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Nepodarilo sa načítať dáta z DB: ${snap.error}',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                          final people = snap.data ?? const <Person>[];
                          return _ChartsCard(people: people);
                        },
                      )
                    : _ChartsCard(people: PeopleStore.i.people),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// riadok: "Local data" / "Global data" + počet respondentov
class _HeaderLine extends StatelessWidget {
  const _HeaderLine({required this.scope, required this.worldFuture});

  final DataScope scope;
  final Future<List<Person>>? worldFuture;

  @override
  Widget build(BuildContext context) {
    final isWorld = scope == DataScope.world;

    if (!isWorld) {
      final n = PeopleStore.i.people.length;
      return _line('Local data', n);
    }

    return FutureBuilder<List<Person>>(
      future: worldFuture,
      builder: (context, snap) {
        final n = (snap.hasData ? (snap.data?.length ?? 0) : 0);
        return _line('Global data', n);
      },
    );
  }

  Widget _line(String title, int count) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text('Respondenti: $count'),
      ],
    );
  }
}

class _ChartsCard extends StatelessWidget {
  const _ChartsCard({required this.people});
  final List<Person> people;

  @override
  Widget build(BuildContext context) {
    // 1) Strana
    final Map<String, int> partyCounts = {};
    for (final p in people) {
      final key = (p.party.isEmpty) ? 'Nezadané' : p.party;
      partyCounts.update(key, (v) => v + 1, ifAbsent: () => 1);
    }

    // 2) Kraj
    final Map<String, int> krajCounts = {};
    for (final p in people) {
      final key = (p.kraj.isEmpty) ? 'Nezadané' : p.kraj;
      krajCounts.update(key, (v) => v + 1, ifAbsent: () => 1);
    }

    // 3) Vek
    final Map<String, int> vekCounts = _ageBuckets(people);

    return LayoutBuilder(
      builder: (context, cs) {
        const hGap = 12.0;
        final tileW = (cs.maxWidth - hGap) / 2; // 2 stĺpce

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                child: Wrap(
                  spacing: hGap,
                  runSpacing: hGap,
                  children: [
                    _chartTile(
                        width: tileW,
                        title: 'Rozdelenie podľa strany',
                        data: partyCounts),
                    _chartTile(
                        width: tileW,
                        title: 'Rozdelenie podľa kraja',
                        data: krajCounts),
                    _chartTile(
                        width: tileW,
                        title: 'Rozdelenie podľa veku',
                        data: vekCounts),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Map<String, int> _ageBuckets(List<Person> people) {
    final Map<String, int> m = {
      '18–24': 0,
      '25–34': 0,
      '35–44': 0,
      '45–54': 0,
      '55–64': 0,
      '65+': 0,
    };
    for (final p in people) {
      final a = p.age;
      if (a >= 18 && a <= 24)
        m['18–24'] = (m['18–24'] ?? 0) + 1;
      else if (a <= 34)
        m['25–34'] = (m['25–34'] ?? 0) + 1;
      else if (a <= 44)
        m['35–44'] = (m['35–44'] ?? 0) + 1;
      else if (a <= 54)
        m['45–54'] = (m['45–54'] ?? 0) + 1;
      else if (a <= 64)
        m['55–64'] = (m['55–64'] ?? 0) + 1;
      else
        m['65+'] = (m['65+'] ?? 0) + 1;
    }
    return m;
  }

  Widget _chartTile({
    required double width,
    required String title,
    required Map<String, int> data,
  }) {
    final total = data.values.fold<int>(0, (a, b) => a + b);
    final Map<String, double> chartData = {
      for (final e in data.entries) e.key: e.value.toDouble()
    };

    // menší priemer, aby sa zmestili 2 vedľa seba
    final radius = (width * 0.75).clamp(120.0, 160.0);

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (chartData.isEmpty)
            const Text('Žiadne dáta')
          else
            PieChart(
              dataMap: chartData,
              animationDuration: const Duration(milliseconds: 400),
              chartRadius: radius,
              legendOptions: const LegendOptions(
                showLegends: true,
                legendPosition: LegendPosition.bottom,
              ),
              chartValuesOptions: const ChartValuesOptions(
                showChartValues: true,
                showChartValuesInPercentage: true,
                decimalPlaces: 1,
              ),
              baseChartColor: Colors.grey.shade200,
              totalValue: total.toDouble(),
            ),
        ],
      ),
    );
  }
}
