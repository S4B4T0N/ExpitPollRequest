import 'package:flutter/material.dart';
import 'package:exit_poll_request/widgets/glass_card.dart';
import 'package:exit_poll_request/data/regions_sk.dart';

class PridajOsobu extends StatefulWidget {
  const PridajOsobu({super.key});

  @override
  State<PridajOsobu> createState() => _PridajOsobuState();
}

class _PridajOsobuState extends State<PridajOsobu> {
  final _formKey = GlobalKey<FormState>();
  final _menoCtrl = TextEditingController();
  final _priezCtrl = TextEditingController();
  final _vekCtrl = TextEditingController();

  final List<String> _strany = <String>[
    'Nezadané',
    'Strana A',
    'Strana B',
    'Strana C',
  ];
  String? _zvolenaStrana = 'Nezadané';

  String? _kraj;
  String? _okres;

  @override
  void dispose() {
    _menoCtrl.dispose();
    _priezCtrl.dispose();
    _vekCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pridať osobu')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/pozadie/pozadie.jpg', fit: BoxFit.cover),
          Container(color: const Color.fromRGBO(0, 0, 0, 0.12)),
          Center(
            child: GlassCard(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Osoba',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _menoCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Meno'),
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        if (t.isEmpty) return 'Zadaj meno';
                        if (t.length < 2) return 'Min. 2 znaky';
                        if (t.length > 60) return 'Max. 60 znakov';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _priezCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Priezvisko',
                      ),
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        if (t.isEmpty) return 'Zadaj priezvisko';
                        if (t.length < 2) return 'Min. 2 znaky';
                        if (t.length > 60) return 'Max. 60 znakov';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _vekCtrl,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Vek'),
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        final n = int.tryParse(t);
                        if (n == null) return 'Zadaj celé číslo';
                        if (n < 18 || n > 120) return 'Vek 18–120';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // DEPRECATED fix: initialValue namiesto value
                    DropdownButtonFormField<String>(
                      value: _kraj,
                      items: kraje
                          .map(
                            (k) => DropdownMenuItem(value: k, child: Text(k)),
                          )
                          .toList(),
                      decoration: const InputDecoration(labelText: 'Kraj'),
                      onChanged: (v) => setState(() {
                        _kraj = v;
                        _okres = null;
                      }),
                      validator: (v) => v == null ? 'Vyber kraj' : null,
                    ),
                    const SizedBox(height: 12),

                    // DEPRECATED fix: initialValue namiesto value
                    DropdownButtonFormField<String>(
                      value: _okres,
                      items:
                          (_kraj == null
                                  ? const <String>[]
                                  : (okresy[_kraj] ?? const <String>[]))
                              .map(
                                (o) =>
                                    DropdownMenuItem(value: o, child: Text(o)),
                              )
                              .toList(),
                      decoration: const InputDecoration(labelText: 'Okres'),
                      onChanged: (v) => setState(() => _okres = v),
                      validator: (v) => v == null ? 'Vyber okres' : null,
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _zvolenaStrana,
                      items: _strany
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Strana, ktorú volil(a)',
                      ),
                      onChanged: (v) => setState(() => _zvolenaStrana = v),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _onSave,
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
          ),
        ],
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'name': _menoCtrl.text.trim(),
      'surname': _priezCtrl.text.trim(),
      'age': int.parse(_vekCtrl.text.trim()),
      'party': _zvolenaStrana,
      'kraj': _kraj,
      'okres': _okres,
    };
    Navigator.pop(context, data);
  }
}
