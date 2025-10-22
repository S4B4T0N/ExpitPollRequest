// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://crxmeutmisfuaatrlalb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNy'
        'eG1ldXRtaXNmdWFhdHJsYWxiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5NTYxNDUsImV4'
        'cCI6MjA3NjUzMjE0NX0._hM0-5D3-fKSqWv1Rb5STnRY40diP8kZdpsRldy-Ih0',
  );
  _cloudEnabled = true;

  await AppDb.open();
  final local = await AppDb.i.getAllPersons();
  PeopleStore.i.people
    ..clear()
    ..addAll(local);

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
            colorSchemeSeed: const Color(0xFF006D77),
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF83C5BE),
            brightness: Brightness.dark,
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _syncToCloud(BuildContext context) async {
    if (!_cloudEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cloud nie je nakonfigurovaný')),
      );
      return;
    }
    try {
      final all = await AppDb.i.getAllPersons();
      try {
        await SupaSync.upsertAll(all);
      } catch (_) {
        for (final p in all) {
          await SupaSync.upsertOne(p);
        }
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync hotový')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync zlyhal: $e')),
      );
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
          Positioned.fill(child: bg),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Exit Poll Request',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          _navBtn(
                            context: context,
                            label: 'Pridať osobu',
                            icon: Icons.person_add_alt_1,
                            color: Theme.of(context).colorScheme.primary,
                            builder: (ctx) => const PridajOsobu(),
                          ),
                          _navBtn(
                            context: context,
                            label: 'Grafy',
                            icon: Icons.pie_chart,
                            color: Theme.of(context).colorScheme.secondary,
                            builder: (ctx) => const GrafyScreen(),
                          ),
                          _navBtn(
                            context: context,
                            label: 'Nastavenia',
                            icon: Icons.settings,
                            color: Theme.of(context).colorScheme.tertiary,
                            builder: (ctx) => const NastaveniaScreen(),
                          ),
                          _navBtn(
                            context: context,
                            label: 'Nápoveda',
                            icon: Icons.help_outline,
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            builder: (ctx) => const NapovedaScreen(),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _syncToCloud(context),
                            icon: const Icon(Icons.sync),
                            label: const Text('Sync → Cloud'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Text(
            'Autor: Tomáš Z.  •  Študentský projekt',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }

  Widget _navBtn({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required WidgetBuilder builder,
  }) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: builder),
      ),
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
