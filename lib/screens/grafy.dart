// lib/screens/grafy.dart
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:exit_poll_request/data/people_store.dart';
import 'package:exit_poll_request/widgets/glass_card.dart';

class GrafyScreen extends StatelessWidget {
  const GrafyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final people = PeopleStore.i.people;

    // 1) Strana
    final Map<String, int> partyCounts = {};
    for (final p in people) {
      final key = p.party.isEmpty ? 'Nezadané' : p.party;
      partyCounts.update(key, (v) => v + 1, ifAbsent: () => 1);
    }

    // 2) Kraj
    final Map<String, int> krajCounts = {};
    for (final p in people) {
      final key = p.kraj.isEmpty ? 'Nezadané' : p.kraj;
      krajCounts.update(key, (v) => v + 1, ifAbsent: () => 1);
    }

    // 3) Vekové skupiny
    final Map<String, int> vekCounts = _ageBuckets(people);

    return Scaffold(
      appBar: AppBar(title: const Text('Grafy')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/pozadie/pozadie.jpg', fit: BoxFit.cover),
          Container(color: const Color.fromRGBO(0, 0, 0, 0.12)),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Rozdelenie podľa strany',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _Pie(data: _toDoubleMap(partyCounts)),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),

                      const Text(
                        'Rozdelenie podľa kraja',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _Pie(data: _toDoubleMap(krajCounts)),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),

                      const Text(
                        'Rozdelenie podľa veku',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _Pie(data: _toDoubleMap(vekCounts)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Map<String, double> _toDoubleMap(Map<String, int> src) {
    // odstráň nulové položky, aby legenda nebola zahltená
    final nonZero = <String, int>{};
    src.forEach((k, v) {
      if (v > 0) nonZero[k] = v;
    });
    return nonZero.map((k, v) => MapEntry(k, v.toDouble()));
  }

  static Map<String, int> _ageBuckets(List<Person> people) {
    final Map<String, int> out = {
      '18–30': 0,
      '31–40': 0,
      '41–50': 0,
      '51–60': 0,
      '61–70': 0,
      '71–80': 0,
      '81–90': 0,
      '91–100': 0,
      // voliteľné: nad 100 len ak sa vyskytnú
      'Nad 100': 0,
    };

    for (final p in people) {
      final a = p.age;
      if (a >= 18 && a <= 30) {
        out['18–30'] = out['18–30']! + 1;
      } else if (a >= 31 && a <= 40) {
        out['31–40'] = out['31–40']! + 1;
      } else if (a >= 41 && a <= 50) {
        out['41–50'] = out['41–50']! + 1;
      } else if (a >= 51 && a <= 60) {
        out['51–60'] = out['51–60']! + 1;
      } else if (a >= 61 && a <= 70) {
        out['61–70'] = out['61–70']! + 1;
      } else if (a >= 71 && a <= 80) {
        out['71–80'] = out['71–80']! + 1;
      } else if (a >= 81 && a <= 90) {
        out['81–90'] = out['81–90']! + 1;
      } else if (a >= 91 && a <= 100) {
        out['91–100'] = out['91–100']! + 1;
      } else if (a > 100) {
        out['Nad 100'] = out['Nad 100']! + 1;
      }
      // vek < 18 sa ignoruje; formulár ho nepovolí
    }
    return out;
  }
}

class _Pie extends StatelessWidget {
  const _Pie({required this.data});
  final Map<String, double> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text('Žiadne dáta'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final radius = (w * 0.42).clamp(140.0, 260.0);

        return PieChart(
          dataMap: data,
          animationDuration: const Duration(milliseconds: 800),
          chartType: ChartType.disc,
          chartLegendSpacing: 24,
          chartRadius: radius,
          legendOptions: const LegendOptions(
            showLegends: true,
            legendPosition: LegendPosition.bottom,
            showLegendsInRow: false,
          ),
          chartValuesOptions: const ChartValuesOptions(
            showChartValues: true,
            showChartValuesInPercentage: true,
            decimalPlaces: 1,
          ),
        );
      },
    );
  }
}
