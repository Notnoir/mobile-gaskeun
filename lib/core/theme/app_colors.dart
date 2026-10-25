import 'package:flutter/material.dart';

class AppColors {
  // Primary Stitch & Emerald Palette
  static const Color primary = Color(0xFF006C49); // Dark Forest Emerald (Stitch Primary)
  static const Color primaryContainer = Color(0xFF10B981); // Emerald-500
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF00422B);
  static const Color primaryFixed = Color(0xFF6FFBBE); // Mint Light
  static const Color primaryFixedDim = Color(0xFF4EDEA3);
  static const Color onPrimaryFixed = Color(0xFF002113);
  static const Color onPrimaryFixedVariant = Color(0xFF005236);

  // Legacy mappings for backward compatibility
  static const Color primaryDark = Color(0xFF006C49);
  static const Color primaryLight = Color(0xFFEFF4FF);
  static const Color primaryAccent = Color(0xFF4EDEA3);

  // Secondary & Accents (Warm Golden Amber)
  static const Color secondary = Color(0xFF855300);
  static const Color secondaryContainer = Color(0xFFFEA619);
  static const Color secondaryFixed = Color(0xFFFFDDB8);
  static const Color onSecondaryFixed = Color(0xFF2A1700);

  // Tertiary (Olive Bio-compost)
  static const Color tertiary = Color(0xFF416900);
  static const Color tertiaryContainer = Color(0xFF72B400);

  // Semantic Alerts
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFBA1A1A);
  static const Color dangerLight = Color(0xFFFFDAD6);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFFE0F2FE);
  static const Color success = Color(0xFF10B981);

  // Background & Surfaces (Stitch Design)
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color cardBorder = Color(0xFFE5EEFF);

  // Text Colors
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF3C4A42);
  static const Color textPrimary = Color(0xFF0B1C30);
  static const Color textSecondary = Color(0xFF3C4A42);
  static const Color textMuted = Color(0xFF6C7A71);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color outline = Color(0xFF6C7A71);
  static const Color outlineVariant = Color(0xFFBBCABF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryContainer, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF006C49)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF006C49)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
