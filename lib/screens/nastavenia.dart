import 'package:flutter/material.dart';
import 'package:exit_poll_request/widgets/glass_card.dart';
import 'package:exit_poll_request/main.dart' show themeMode;

class NastaveniaScreen extends StatefulWidget {
  const NastaveniaScreen({super.key});

  @override
  State<NastaveniaScreen> createState() => _NastaveniaScreenState();
}

class _NastaveniaScreenState extends State<NastaveniaScreen> {
  ThemeMode _local = themeMode.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nastavenia')),
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
                    'Nastavenia aplikácie',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  // Výber režimu len pre aplikáciu
                  RadioListTile<ThemeMode>(
                    title: const Text('Systém'),
                    value: ThemeMode.system,
                    groupValue: _local,
                    onChanged: (v) => setState(() => _local = v!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Svetlý'),
                    value: ThemeMode.light,
                    groupValue: _local,
                    onChanged: (v) => setState(() => _local = v!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Tmavý'),
                    value: ThemeMode.dark,
                    groupValue: _local,
                    onChanged: (v) => setState(() => _local = v!),
                  ),

                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            themeMode.value = _local; // zmení tému len v appke
                            Navigator.pop(context);
                          },
                          child: const Text('Uložiť'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Zrušiť'),
                        ),
                      ),
                    ],
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
