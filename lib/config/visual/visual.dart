// lib/config/visual/visual.dart
import 'package:flutter/material.dart';

/// Vizuál a paleta pre celú appku.
/// Úpravy farieb sprav iba tu.
class Visual {
  const Visual._();

  // === PALETA ===============================================================

  /// Základná farba (teal/green).
  static const Color primary = Color(0xFF006D77);

  /// Svetlá “teal” pre akcenty.
  static const Color primaryLight = Color(0xFF83C5BE);

  /// Jemná sivá linka.
  static const Color stroke = Color(0x1F000000);

  /// Povrch pre sklo a odznaky v svetlom režime.
  static Color surfaceLight(BuildContext c) => Colors.white.withOpacity(0.75);

  /// Povrch pre sklo a odznaky v tmavom režime.
  static Color surfaceDark(BuildContext c) => Colors.black.withOpacity(0.55);

  // === HEADER / FOOTER =====================================================

  /// Horný pás s názvom a voliteľným podtitulom + vertikálny “fade”.
  static Widget header({
    required BuildContext context,
    required String title,
    String? subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;
    final fg = isDark ? Colors.white : Colors.black;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          color: bg,
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                textAlign: TextAlign.start,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: fg, fontWeight: FontWeight.w700),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: fg.withOpacity(0.72)),
                ),
              ],
            ],
          ),
        ),
        // jemný gradient do obsahu
        Container(
          width: double.infinity,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [bg, bg.withOpacity(0.0)]
                  : [bg, bg.withOpacity(0.0)],
            ),
          ),
        ),
      ],
    );
  }

  /// Spodný pás s textom. Použi do `bottomNavigationBar: Visual.footer(context)`.
  static Widget footer(BuildContext context, {String? text}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;
    final fg = isDark ? Colors.white70 : Colors.black54;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // jemný gradient nahor
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: isDark
                  ? [bg, bg.withOpacity(0.0)]
                  : [bg, bg.withOpacity(0.0)],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          color: bg,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Text(
            text ?? 'Autor: Tomáš Z.  •  Študentský projekt',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: fg),
          ),
        ),
      ],
    );
  }

  // === BADGE / OSTATNÉ =====================================================

  /// Odznak s jednotným vzhľadom (napr. počet respondentov).
  static Widget badge(BuildContext context, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? surfaceDark(context) : surfaceLight(context);
    final border = Theme.of(context).colorScheme.outlineVariant;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }

  /// Segmentový prepínač “Local / Global” v štýle “tabletky”.
  /// [isLocal] = true => Local aktivný; false => Global aktivný.
  static Widget segmentedLocalGlobal({
    required BuildContext context,
    required bool isLocal,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shell = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);

    final activeBg = primary; // plný akcent
    final activeFg = Colors.white;
    final inactiveFg =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: shell,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: stroke),
      ),
      child: Row(
        children: [
          // Local
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => onChanged(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: isLocal ? activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Local',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isLocal ? activeFg : inactiveFg,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Global
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => onChanged(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: !isLocal ? activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Global',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: !isLocal ? activeFg : inactiveFg,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === POMOCNÉ STYLY PRE TLAČIDLÁ NA SKLE ==================================

  /// Jednotný vzhľad “plných” tlačidiel na skle (bez zmeny logiky).
  static ButtonStyle glassPrimaryButtonStyle(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      shadowColor: Colors.transparent,
      overlayColor: cs.onPrimary.withOpacity(0.06),
    );
  }

  /// Sekundárne tlačidlo na skle.
  static ButtonStyle glassSecondaryButtonStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? surfaceDark(context) : surfaceLight(context);
    final fg = Theme.of(context).colorScheme.onSurface;
    return ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      shadowColor: Colors.transparent,
    );
  }
}
