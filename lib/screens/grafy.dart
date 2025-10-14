import 'package:flutter/material.dart';
import 'package:exit_poll_request/widgets/glass_card.dart';

class GrafyScreen extends StatelessWidget {
  const GrafyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grafy')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/pozadie/pozadie.jpg', fit: BoxFit.cover),
          Container(color: const Color.fromRGBO(0, 0, 0, 0.12)),
          const Center(
            child: GlassCard(
              child: Text(
                'Tu budú grafy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
