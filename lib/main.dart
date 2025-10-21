import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase init
import 'package:exit_poll_request/data/supabase_sync.dart'; // sync → Supabase

import 'package:exit_poll_request/widgets/glass_card.dart';
import 'package:exit_poll_request/screens/pridaj_osobu.dart';
import 'package:exit_poll_request/screens/grafy.dart';
import 'package:exit_poll_request/screens/nastavenia.dart';
import 'package:exit_poll_request/screens/napoveda.dart';
import 'package:exit_poll_request/data/people_store.dart';
import 'package:exit_poll_request/data/app_db.dart';

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
late final AppDb appDb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase – doplň svoje hodnoty
  await Supabase.initialize(
    url: 'https://crxmeutmisfuaatrlalb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNyeG1ldXRtaXNmdWFhdHJsYWxiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5NTYxNDUsImV4cCI6MjA3NjUzMjE0NX0._hM0-5D3-fKSqWv1Rb5STnRY40diP8kZdpsRldy-Ih0',
  );

  appDb = await AppDb.open(); // WAL + foreign_keys
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (_, mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color.fromARGB(255, 70, 197, 98),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF2E7D32),
            brightness: Brightness.dark,
          ),
          themeMode: mode,
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loaded = false;
  Timer? _autoSync;

  @override
  void initState() {
    super.initState();
    _loadFromDb();
    _startAutoSync();
  }

  @override
  void dispose() {
    _autoSync?.cancel();
    super.dispose();
  }

  void _startAutoSync() {
    _autoSync?.cancel();
    _autoSync =
        Timer.periodic(const Duration(seconds: 15), (_) => _syncToSupabase());
  }

  Future<void> _syncToSupabase() async {
    try {
      final n = await SupaSync.upsertAll(PeopleStore.i.people);
      if (n > 0) debugPrint('Supabase sync: upsert $n riadkov');
    } catch (e) {
      debugPrint('Supabase sync error: $e');
    }
  }

  Future<void> _loadFromDb() async {
    final all = await appDb.getAllPersons();
    PeopleStore.i.people
      ..clear()
      ..addAll(all);
    if (mounted) setState(() => _loaded = true);
  }

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
                  if (!_loaded)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                  if (_loaded)
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
                            final r = await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const PridajOsobu()),
                            );
                            if (!mounted || r == null) return;

                            final uuid = _uuidV4();
                            final p = Person(
                              uuid: uuid,
                              name: r['name'] as String,
                              surname: r['surname'] as String,
                              age: r['age'] as int,
                              party: ((r['party'] as String?)?.trim().isEmpty ??
                                      true)
                                  ? 'Nezadané'
                                  : (r['party'] as String),
                              kraj: r['kraj'] as String,
                              okres: r['okres'] as String,
                            );

                            await appDb.insertPerson(p);
                            PeopleStore.i.people.add(p);
                            setState(() {});

                            // okamžitý zápis do Supabase
                            try {
                              await SupaSync.upsertOne(p);
                            } catch (e) {
                              debugPrint('Supabase upsertOne error: $e');
                            }
                          },
                        ),
                        _MenuButton(
                          icon: Icons.numbers,
                          label: 'Grafy',
                          color: cs.secondary,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const GrafyScreen()),
                          ),
                        ),
                        _MenuButton(
                          icon: Icons.settings,
                          label: 'Nastavenia',
                          color: cs.tertiary,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const NastaveniaScreen()),
                          ),
                        ),
                        _MenuButton(
                          icon: Icons.help_outline,
                          label: 'Nápoveda',
                          color: cs.error,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const NapovedaScreen()),
                          ),
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
                top: BorderSide(
                    color: Theme.of(context).dividerColor, width: 0.5)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: const Text(
            'Autor: Tomáš Z.  •  Študentský projekt pre predmet Mobilné technológie',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}

/// jednoduchý UUID v4 bez balíka
String _uuidV4() {
  final r = Random.secure();
  String hex(int n) =>
      List.generate(n, (_) => r.nextInt(16).toRadixString(16)).join();
  final a = hex(8),
      b = hex(4),
      c = (r.nextInt(0x1000) | 0x4000).toRadixString(16),
      d = ((r.nextInt(0x4000) | 0x8000)).toRadixString(16),
      e = hex(12);
  return '$a-$b-$c-$d-$e';
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
