import 'package:flutter/material.dart';

class NavTripPalette {
  static const surface = Color(0xfff9f9f8);
  static const surfaceDim = Color(0xffdadad9);
  static const surfaceContainer = Color(0xffeeeeed);
  static const surfaceContainerLow = Color(0xfff4f4f3);
  static const surfaceContainerHighest = Color(0xffe2e2e2);
  static const ink = Color(0xff1a1c1c);
  static const mutedInk = Color(0xff57423c);
  static const terracotta = Color(0xff9a3412);
  static const terracottaDeep = Color(0xff781f00);
  static const terracottaSoft = Color(0xffffbda9);
  static const sand = Color(0xffe9e1db);
  static const sandDark = Color(0xff68635f);
  static const outline = Color(0xff8b716a);
  static const outlineVariant = Color(0xffdec0b7);
  static const note = Color(0xfffef9c3);
  static const error = Color(0xffba1a1a);
  static const success = Color(0xff0f766e);
  static const darkSurface = Color(0xff171413);
  static const darkSurfaceContainer = Color(0xff26211f);
  static const darkInk = Color(0xfffff4ef);
  static const darkMutedInk = Color(0xffdcc5bc);
}

class NavTripEditorial {
  static const ink = Color(0xff303036);
  static const navy = Color(0xff001a3d);
  static const blue = Color(0xff356de9);
  static const panel = Color(0xfff1f2f8);
}

class NavTripStyles {
  static ThemeData theme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: NavTripPalette.terracotta,
      brightness: Brightness.light,
      surface: NavTripPalette.surface,
      surfaceContainerHighest: NavTripPalette.surfaceContainerHighest,
      surfaceContainerHigh: NavTripPalette.surfaceContainerHighest,
      surfaceContainer: NavTripPalette.surfaceContainer,
      surfaceContainerLow: NavTripPalette.surfaceContainerLow,
      surfaceContainerLowest: Colors.white,
      primary: NavTripPalette.terracotta,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xff9a3412),
      onPrimaryContainer: const Color(0xffffbda9),
      secondary: const Color(0xff625e59),
      onSecondary: Colors.white,
      secondaryContainer: NavTripPalette.sand,
      onSecondaryContainer: NavTripPalette.sandDark,
      tertiary: const Color(0xff3f3f3e),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xff565656),
      onTertiaryContainer: const Color(0xffcdcbca),
      outline: const Color(0xff8b716a),
      outlineVariant: const Color(0xffdec0b7),
      error: NavTripPalette.error,
      onError: Colors.white,
      errorContainer: const Color(0xffffdad6),
      onErrorContainer: const Color(0xff93000a),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: NavTripPalette.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: NavTripPalette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 56,
          fontWeight: FontWeight.w400,
          letterSpacing: -1.1,
          height: 1.0,
          color: NavTripPalette.ink,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 42,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.8,
          height: 1.05,
          color: NavTripPalette.ink,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 32,
          fontWeight: FontWeight.w400,
          height: 1.1,
          color: NavTripPalette.ink,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 24,
          fontWeight: FontWeight.w400,
          height: 1.15,
          color: NavTripPalette.ink,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 22,
          fontWeight: FontWeight.w400,
          height: 1.15,
          color: NavTripPalette.ink,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 1.2,
          color: NavTripPalette.ink,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          height: 1.55,
          color: NavTripPalette.ink,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: NavTripPalette.ink,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          height: 1.35,
          color: NavTripPalette.ink,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: NavTripPalette.ink,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
          color: NavTripPalette.ink,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xffdec0b7),
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: NavTripPalette.surfaceContainerLow,
        selectedColor: NavTripPalette.terracotta,
        secondarySelectedColor: NavTripPalette.terracotta,
        labelStyle: const TextStyle(color: NavTripPalette.ink),
        side: const BorderSide(color: Color(0xffdec0b7)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: NavTripPalette.terracotta,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NavTripPalette.ink,
          side: const BorderSide(color: NavTripPalette.ink, width: 1.3),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.35,
          ),
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        isDense: true,
        border: UnderlineInputBorder(
          borderSide:
              BorderSide(color: NavTripPalette.outlineVariant, width: 1.4),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: NavTripPalette.outlineVariant, width: 1.4),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: NavTripPalette.terracotta, width: 1.8),
        ),
        hintStyle: TextStyle(color: NavTripPalette.outline),
        labelStyle: TextStyle(color: NavTripPalette.mutedInk),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData darkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: NavTripPalette.terracottaSoft,
      brightness: Brightness.dark,
      surface: NavTripPalette.darkSurface,
      surfaceContainerHighest: const Color(0xff3a302d),
      surfaceContainerHigh: const Color(0xff322a28),
      surfaceContainer: NavTripPalette.darkSurfaceContainer,
      surfaceContainerLow: const Color(0xff211c1a),
      surfaceContainerLowest: const Color(0xff110f0e),
      primary: NavTripPalette.terracottaSoft,
      onPrimary: const Color(0xff521500),
      primaryContainer: NavTripPalette.terracottaDeep,
      onPrimaryContainer: NavTripPalette.terracottaSoft,
      secondary: const Color(0xffdcc5bc),
      onSecondary: const Color(0xff3b2b26),
      secondaryContainer: const Color(0xff54413a),
      onSecondaryContainer: const Color(0xffffdbd1),
      tertiary: const Color(0xffd1c6bf),
      onTertiary: const Color(0xff35302d),
      tertiaryContainer: const Color(0xff4b4642),
      onTertiaryContainer: const Color(0xffeee1da),
      outline: const Color(0xffa98d84),
      outlineVariant: const Color(0xff5b4741),
      error: const Color(0xffffb4ab),
      onError: const Color(0xff690005),
      errorContainer: const Color(0xff93000a),
      onErrorContainer: const Color(0xffffdad6),
    );

    final base = theme();
    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: NavTripPalette.darkSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: NavTripPalette.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: NavTripPalette.darkInk,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: NavTripPalette.darkInk,
        displayColor: NavTripPalette.darkInk,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xff5b4741),
        thickness: 1,
        space: 1,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: NavTripPalette.darkSurfaceContainer,
        selectedColor: NavTripPalette.terracotta,
        labelStyle: const TextStyle(color: NavTripPalette.darkInk),
        side: const BorderSide(color: Color(0xff5b4741)),
      ),
      cardTheme: CardThemeData(
        color: NavTripPalette.darkSurfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static BoxDecoration paperBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xfff9f9f8), Color(0xfff1eee8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  static BoxDecoration paperCard({BuildContext? context, double radius = 16}) {
    final isDark = context != null && Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? NavTripPalette.darkSurfaceContainer : Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark ? const Color(0xff5b4741) : const Color(0xffdec0b7),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? const Color.fromRGBO(0, 0, 0, 0.4)
              : const Color.fromRGBO(0, 0, 0, 0.12),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: isDark
              ? const Color.fromRGBO(0, 0, 0, 0.2)
              : const Color.fromRGBO(0, 0, 0, 0.04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  static BoxDecoration polaroidCard({BuildContext? context}) {
    final isDark = context != null && Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xff2a2321) : Colors.white;
    return BoxDecoration(
      color: cardColor,
      border: Border.all(color: cardColor, width: 8),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? const Color.fromRGBO(0, 0, 0, 0.5)
              : const Color.fromRGBO(0, 0, 0, 0.16),
          blurRadius: 24,
          offset: const Offset(8, 12),
        ),
      ],
      borderRadius: BorderRadius.circular(2),
    );
  }

  static BoxDecoration stickyNote({BuildContext? context}) {
    final isDark = context != null && Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? const Color(0xff34301c) : NavTripPalette.note,
      borderRadius: BorderRadius.circular(4),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? const Color.fromRGBO(0, 0, 0, 0.3)
              : const Color.fromRGBO(0, 0, 0, 0.08),
          blurRadius: 12,
          offset: const Offset(2, 4),
        ),
      ],
    );
  }
}

class PaperTexture extends StatelessWidget {
  const PaperTexture({
    required this.child,
    this.opacity = 0.045,
    super.key,
  });

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: dark
                ? const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        NavTripPalette.darkSurface,
                        Color(0xff241d1a),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  )
                : NavTripStyles.paperBackground(),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.16),
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    required this.title,
    this.subtitle,
    this.alignment = CrossAxisAlignment.start,
    super.key,
  });

  final String title;
  final String? subtitle;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: NavTripPalette.mutedInk,
                ),
          ),
        ],
      ],
    );
  }
}
