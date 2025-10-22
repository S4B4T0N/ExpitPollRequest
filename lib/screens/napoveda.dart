// lib/screens/napoveda.dart
import 'package:flutter/material.dart';
import 'package:exit_poll_request/widgets/glass_card.dart';

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
          Center(
            child: GlassCard(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ListView(
                  shrinkWrap: true,
                  children: const [
                    _HelpSection(
                      title: 'Ako pridať osobu',
                      body: 'Na úvodnej obrazovke zvoľ „Pridať osobu“. Vyplň '
                          'meno, priezvisko, vek, kraj a okres. Strana je '
                          'voliteľná. Ulož tlačidlom „Uložiť“.',
                    ),
                    _HelpSection(
                      title: 'Grafy',
                      body: 'Grafy zobrazujú rozdelenie podľa zvolenej strany. '
                          'Percentá sa rátajú z aktuálne uložených záznamov.',
                    ),
                    _HelpSection(
                      title: 'Úložisko dát',
                      body: 'Údaje sú uložené lokálne v SQLite na tomto '
                          'zariadení. Neodosielajú sa na internet.',
                    ),
                    _HelpSection(
                      title: 'Mazanie dát',
                      body: 'Vymazanie záznamov bude dostupné v Nastaveniach '
                          'alebo odstránením lokálnej DB (pokročilé).',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  const _HelpSection({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(body),
        ],
      ),
    );
  }
}
