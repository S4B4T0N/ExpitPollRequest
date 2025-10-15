import 'package:flutter/material.dart';

class NapovedaScreen extends StatelessWidget {
  const NapovedaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nápoveda')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/pozadie/pozadie.jpg', fit: BoxFit.cover),
          Container(color: const Color.fromRGBO(0, 0, 0, 0.12)),
          const Center(child: Text('Obsah nápovedy')),
        ],
      ),
    );
  }
}
