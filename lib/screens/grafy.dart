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
    _worldFuture = WorldRepository.i.fetchPeople();
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
          Container(color: const Color.fromRGBO(0, 0, 0, 0.12)),
          Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ScopeToggle(
                  leftLabel: 'Global',
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
              const SizedBox(height: 8),
              Expanded(child: _buildContent(isWorld)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isWorld) {
    if (!isWorld) {
      final people = PeopleStore.i.people;
      return _ChartsCard(people: people, title: 'Local data');
    }

    return FutureBuilder<List<Person>>(
      future: _worldFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
        return _ChartsCard(people: people, title: 'Global data');
      },
    );
  }
}

class _ChartsCard extends StatelessWidget {
  const _ChartsCard({required this.people, required this.title});

  final List<Person> people;
  final String title;

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

    // 3) Vekové skupiny
    final Map<String, int> vekCounts = _ageBuckets(people);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
          child: Row(
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text('Respondenti: ${people.length}'),
            ],
          ),
        ),
        GlassCard(
          child: LayoutBuilder(
            builder: (context, c) {
              const gap = 24.0;
              final tileW = (c.maxWidth - gap) / 2;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  _chartTile('Rozdelenie podľa strany', partyCounts, tileW),
                  _chartTile('Rozdelenie podľa kraja', krajCounts, tileW),
                  _chartTile('Rozdelenie podľa veku', vekCounts, tileW),
                ],
              );
            },
          ),
        ),
      ],
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
      if (a >= 18 && a <= 24) {
        m['18–24'] = (m['18–24'] ?? 0) + 1;
      } else if (a <= 34) {
        m['25–34'] = (m['25–34'] ?? 0) + 1;
      } else if (a <= 44) {
        m['35–44'] = (m['35–44'] ?? 0) + 1;
      } else if (a <= 54) {
        m['45–54'] = (m['45–54'] ?? 0) + 1;
      } else if (a <= 64) {
        m['55–64'] = (m['55–64'] ?? 0) + 1;
      } else {
        m['65+'] = (m['65+'] ?? 0) + 1;
      }
    }
    return m;
  }

  Widget _chartTile(String title, Map<String, int> data, double tileW) {
    if (data.isEmpty) {
      return SizedBox(
        width: tileW,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Žiadne dáta'),
          ],
        ),
      );
    }

    final total = data.values.fold<int>(0, (a, b) => a + b);
    final Map<String, double> chartData = {
      for (final e in data.entries) e.key: e.value.toDouble()
    };

    final radius = (tileW - 32) / 2;

    return SizedBox(
      width: tileW,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          PieChart(
            dataMap: chartData,
            animationDuration: const Duration(milliseconds: 400),
            chartRadius: radius,
            legendOptions: const LegendOptions(
              showLegends: true,
              legendPosition: LegendPosition.bottom,
            ),
            chartValuesOptions: ChartValuesOptions(
              showChartValues: true,
              showChartValuesInPercentage: true,
              decimalPlaces: 1,
              // DÔLEŽITÉ: vytlačí hodnoty mimo výsekov
              showChartValuesOutside: true,
              // lepšia čitateľnosť
              showChartValueBackground: true,
              chartValueBackgroundColor: Colors.black.withOpacity(0.05),
            ),
            baseChartColor: Colors.grey,
            totalValue: total.toDouble(),
          ),
        ],
      ),
    );
  }
}
