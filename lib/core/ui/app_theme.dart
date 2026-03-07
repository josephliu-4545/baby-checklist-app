import 'package:flutter/material.dart';

import 'app_spacing.dart';

class AppTheme {
  static ThemeData light() {
    const primary = Color(0xFFF6C9D4);
    const secondary = Color(0xFFF9D8C2);
    const tertiary = Color(0xFFD9C6F3);
    const background = Color(0xFFFFF9F7);
    const surface = Color(0xFFFFFFFF);
    const outline = Color(0xFFE7D7D3);

    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Color(0xFF3A1E26),
      primaryContainer: Color(0xFFFFE4EA),
      onPrimaryContainer: Color(0xFF2F141B),
      secondary: secondary,
      onSecondary: Color(0xFF3A2716),
      secondaryContainer: Color(0xFFFFEADB),
      onSecondaryContainer: Color(0xFF2B1B10),
      tertiary: tertiary,
      onTertiary: Color(0xFF2C2140),
      tertiaryContainer: Color(0xFFF0E8FF),
      onTertiaryContainer: Color(0xFF1E162E),
      error: Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      background: background,
      onBackground: Color(0xFF231F20),
      surface: surface,
      onSurface: Color(0xFF231F20),
      surfaceTint: primary,
      surfaceContainerHighest: Color(0xFFF7F1EF),
      onSurfaceVariant: Color(0xFF5B4F4E),
      outline: outline,
      outlineVariant: Color(0xFFF0E3E0),
      shadow: Color(0x33000000),
      scrim: Color(0x66000000),
      inverseSurface: Color(0xFF3A3436),
      onInverseSurface: Color(0xFFF8F0F2),
      inversePrimary: Color(0xFFFFB1C2),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
    );

    return base.copyWith(
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      ),
      cardTheme: CardThemeData(
        elevation: 0.5,
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusMd,
        ),
        margin: EdgeInsets.zero,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusMd,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          base.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onPrimaryContainer);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.radiusSm,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusSm,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusSm,
          borderSide: BorderSide(width: 2, color: colorScheme.primary),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppSpacing.radiusSm,
          borderSide: BorderSide(color: Color(0xFFB3261E)),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppSpacing.radiusSm,
          borderSide: BorderSide(width: 2, color: Color(0xFFB3261E)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 14,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.radiusSm,
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          foregroundColor: colorScheme.onSurface,
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.radiusSm,
          ),
          side: BorderSide(color: colorScheme.outline),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.radiusSm,
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        labelStyle: base.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.tertiaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: const StadiumBorder(),
      ),
    );
  }
}
