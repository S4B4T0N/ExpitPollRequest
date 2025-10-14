import 'package:flutter/material.dart';
import 'package:exit_poll_request/widgets/glass_card.dart';
import 'package:exit_poll_request/data/people_store.dart';
import 'package:pie_chart/pie_chart.dart';

class GrafyScreen extends StatelessWidget {
  const GrafyScreen({super.key});

  Map<String, double> _buildPieData() {
    final counts = <String, int>{};
    for (final p in PeopleStore.i.people) {
      final key = (p.party.trim().isEmpty) ? 'Nezadané' : p.party.trim();
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts.map((k, v) => MapEntry(k, v.toDouble()));
  }

  @override
  Widget build(BuildContext context) {
    final data = _buildPieData();

    return Scaffold(
      appBar: AppBar(title: const Text('Grafy')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/pozadie/pozadie.jpg', fit: BoxFit.cover),
          Container(color: const Color.fromRGBO(0, 0, 0, 0.12)),
          Center(
            child: GlassCard(
              child: data.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Žiadne dáta na graf'),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Preferencie strán',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        PieChart(
                          dataMap: data,
                          chartType: ChartType.disc, // alebo ChartType.ring
                          chartRadius: 180,
                          legendOptions: const LegendOptions(
                            showLegends: true,
                            legendPosition: LegendPosition.right,
                          ),
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValues: true,
                            showChartValuesInPercentage: true,
                            decimalPlaces: 1,
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
}
