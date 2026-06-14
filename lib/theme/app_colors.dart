import 'package:flutter/material.dart';

/// All brand colors in one place — no hardcoding elsewhere.
class AppColors {
  AppColors._();
  // ── Primary purple palette ──────────────────────────────────────────────────
  static const Color primary = Color(0xFF8F7FC0);

  // A softer overlay tint for light mode ripples, selections, or glassmorphic backgrounds
  static const Color primarySurface = Color(0xFFF3EFFF);
  static const Color primarySurfaceDark = Color(0xFF261D42);
  // ── Semantic / status ───────────────────────────────────────────────────────
  static const Color completed = Color(0xFF4CAF50);
  static const Color pending = Color(0xFFFF9800);

  static const Color danger = Color(0xFFE53935);
  // ── Neutrals — light mode ───────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8F6FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE8E0F0);
  static const Color lightTextPrimary = Color(0xFF1A1035);
  static const Color lightTextSecondary = Color(0xFF7A7090);
  static const Color lightDivider = Color(0xFFEEE8F8);

  // ── Neutrals — dark mode ────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F0A1E);
  static const Color darkSurface = Color(0xFF1A1232);
  static const Color darkCard = Color(0xFF221A3A);
  static const Color darkBorder = Color(0xFF332850);
  static const Color darkTextPrimary = Color(0xFFF0EBFF);
  static const Color darkTextSecondary = Color(0xFF9B90BB);
  static const Color darkDivider = Color(0xFF2A2040);
}
