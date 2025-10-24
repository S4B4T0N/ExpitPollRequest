// lib/main.dart  (iba vizuálne úpravy; logika bez zmeny)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:exit_poll_request/config/visual/visual.dart';
import 'package:exit_poll_request/data/app_db.dart';
import 'package:exit_poll_request/data/people_store.dart';
import 'package:exit_poll_request/data/supabase_sync.dart';

import 'package:exit_poll_request/widgets/glass_card.dart';
import 'package:exit_poll_request/screens/pridaj_osobu.dart';
import 'package:exit_poll_request/screens/grafy.dart';
import 'package:exit_poll_request/screens/nastavenia.dart';
import 'package:exit_poll_request/screens/napoveda.dart';

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
bool _cloudEnabled = false;

class _AutoPush {
  static Timer? _t;
  static void start({Duration interval = const Duration(seconds: 10)}) {
    stop();
    _t = Timer.periodic(interval, (_) => _tick());
  }

  static void stop() {
    _t?.cancel();
    _t = null;
  }

  static Future<void> _tick() async {
    if (!_cloudEnabled) return;
    try {
      final all = await AppDb.i.getAllPersons();
      if (all.isEmpty) {
        debugPrint('[AutoPush] nothing to push');
        return;
      }
      final pushed = await SupaSync.upsertAll(all);
      debugPrint(
          '[AutoPush] pushed=$pushed @ ${DateTime.now().toIso8601String()}');
    } catch (e, st) {
      debugPrint('[AutoPush] error: $e');
      debugPrint('$st');
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://crxmeutmisfuaatrlalb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNyeG1ldXRtaXNmdWFhdHJsYWxiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5NTYxNDUsImV4cCI6MjA3NjUzMjE0NX0._hM0-5D3-fKSqWv1Rb5STnRY40diP8kZdpsRldy-Ih0',
  );
  _cloudEnabled = true;

  await AppDb.open();
  final local = await AppDb.i.getAllPersons();
  PeopleStore.i.people
    ..clear()
    ..addAll(local);

  _AutoPush.start();
  runApp(const ExitPollApp());
}

class ExitPollApp extends StatelessWidget {
  const ExitPollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Exit Poll Request',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Visual.primary,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Visual.primaryLight,
            brightness: Brightness.dark,
            appBarTheme: const AppBarTheme(backgroundColor: Visual.primary),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _genUuid() => const Uuid().v4();

  Future<void> _openAddPerson(BuildContext context) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>?>(
      MaterialPageRoute(builder: (_) => const PridajOsobu()),
    );
    if (result == null) return;

    final p = Person(
      uuid: _genUuid(),
      name: (result['name'] as String?)?.trim() ?? '',
      surname: (result['surname'] as String?)?.trim() ?? '',
      age: (result['age'] as int?) ?? 0,
      party: ((result['party'] as String?) ?? '').trim(),
      kraj: (result['kraj'] as String?) ?? '',
      okres: (result['okres'] as String?) ?? '',
    );

    try {
      await AppDb.i.insertPerson(p);
      PeopleStore.i.people
        ..removeWhere((x) => x.uuid == p.uuid)
        ..insert(0, p);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Osoba uložená lokálne')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ukladanie zlyhalo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = Image.asset(
      'assets/pozadie/pozadie.jpg',
      fit: BoxFit.cover,
      alignment: Alignment.center,
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Pozadie
          Positioned.fill(child: bg),

          // Layout: header hore, obsah pod ním
          Column(
            children: [
              // HEADER s SafeArea, aby nešiel pod výrez/status bar
              SafeArea(
                bottom: false,
                child: Visual.header(
                  context: context,
                  title: 'Exit Poll Request',
                  subtitle: 'Zber a spracovanie údajov respondentov',
                ),
              ),

              // OBSAH
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GlassCard(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _navBtnFull(
                                context: context,
                                label: 'Pridať osobu',
                                icon: Icons.person_add_alt_1,
                                onTap: () => _openAddPerson(context),
                              ),
                              const SizedBox(height: 12),
                              _navBtnFull(
                                context: context,
                                label: 'Grafy',
                                icon: Icons.pie_chart,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const GrafyScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _navBtnFull(
                                context: context,
                                label: 'Nastavenia',
                                icon: Icons.settings,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const NastaveniaScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _navBtnFull(
                                context: context,
                                label: 'Nápoveda',
                                icon: Icons.help_outline,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const NapovedaScreen(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _respondentCountBadge(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // FOOTER
      bottomNavigationBar: Visual.footer(context),
    );
  }

  Widget _respondentCountBadge(BuildContext context) {
    final countStream = Stream<int>.periodic(
      const Duration(seconds: 5),
      (_) => 0,
    ).asyncMap((_) async => (await AppDb.i.getAllPersons()).length);

    return StreamBuilder<int>(
      stream: countStream,
      builder: (context, snap) {
        final n = snap.data ?? 0;
        return Visual.badge(
          context,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.group, size: 18),
              const SizedBox(width: 8),
              Text('Počet respondentov: $n'),
            ],
          ),
        );
      },
    );
  }

  Widget _navBtnFull({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 300,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: Visual.glassSecondaryButtonStyle(context),
      ),
    );
  }
}
