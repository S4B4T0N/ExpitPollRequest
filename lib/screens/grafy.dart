import 'package:flutter/material.dart';
import 'package:exit_poll_request/widgets/glass_card.dart';
import 'package:pie_chart/pie_chart.dart';

class GrafyScreen extends StatelessWidget {
  const GrafyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // demo dáta; neskôr ich napojíš na PeopleStore / backend
    final data = <String, double>{
      'Strana A': 35,
      'Strana B': 28,
      'Strana C': 22,
      'Nezadané': 15,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Grafy')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/pozadie/pozadie.jpg', fit: BoxFit.cover),
          Container(color: const Color.fromRGBO(0, 0, 0, 0.12)),
          Center(
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Preferencie strán',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
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
