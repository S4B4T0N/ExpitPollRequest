import 'package:flutter/material.dart';
import 'package:exit_poll_request/widgets/glass_card.dart';
import 'package:exit_poll_request/screens/pridaj_osobu.dart';
import 'package:exit_poll_request/screens/grafy.dart';
import 'package:exit_poll_request/data/people_store.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color.fromARGB(255, 70, 197, 98),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2E7D32),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exit Poll Calculator'),
        centerTitle: true,
      ),
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
                    'Hlavné menu',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MenuButton(
                        icon: Icons.person,
                        label: 'Pridat osobu',
                        color: cs.primary,
                        onTap: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PridajOsobu(),
                            ),
                          );
                          if (!mounted || result == null) return;
                          // uloženie do shared in-memory store
                          PeopleStore.i.people.add(
                            Person(
                              name: result['name'] as String,
                              surname: result['surname'] as String,
                              party:
                                  (result['party'] as String?)
                                          ?.trim()
                                          .isEmpty ??
                                      true
                                  ? 'Nezadané'
                                  : (result['party'] as String),
                              age: result['age'] as int,
                            ),
                          );
                          setState(() {}); // ak chceš zobraziť počítadlo atď.
                        },
                      ),
                      _MenuButton(
                        icon: Icons.numbers,
                        label: 'Grafy',
                        color: cs.secondary,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const GrafyScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuButton(
                        icon: Icons.settings,
                        label: 'Nastavenia',
                        color: cs.tertiary,
                        onTap: () {},
                      ),
                      _MenuButton(
                        icon: Icons.help_outline,
                        label: 'Nápoveda',
                        color: cs.error,
                        onTap: () {},
                      ),
                      _MenuButton(
                        icon: Icons.bug_report,
                        label: 'Debug',
                        color: cs.primaryContainer,
                        onTap: () {
                          debugPrint('[DEBUG] Klik na debug tlacidlo');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('DEBUG klik')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Počet osôb: ${PeopleStore.i.people.length}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
