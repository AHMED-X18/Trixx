import 'package:flutter/material.dart';
import 'package:trixx/domain/models/task.dart';

/// Design tokens from the TRiXX orange design system
/// (see TRiXX_Project_Documentation_v2.md — "Charte graphique TRiXX — Palette Orange").
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFFFF7A00);
  static const Color primaryDark = Color(0xFFE85D00);
  static const Color primaryLight = Color(0xFFFFB066);
  static const Color primaryPale = Color(0xFFFFF1E6);

  // Light surfaces
  static const Color backgroundLight = Color(0xFFFFFBF7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF171717);
  static const Color textSecondaryLight = Color(0xFF6B6B6B);
  static const Color borderLight = Color(0xFFEAEAEA);

  // Dark surfaces
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceElevatedDark = Color(0xFF292929);
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFA3A3A3);
  static const Color primaryOnDark = Color(0xFFFF8A1F);

  // Functional
  static const Color success = Color(0xFF22A06B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF3B82F6);

  static Color priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.faible:
        return textSecondaryLight;
      case TaskPriority.moyen:
        return info;
      case TaskPriority.eleve:
        return primary;
      case TaskPriority.critique:
        return error;
    }
  }

  static Color priorityBackground(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.faible:
        return const Color(0xFFF3F3F3);
      case TaskPriority.moyen:
        return const Color(0xFFEAF2FE);
      case TaskPriority.eleve:
        return primaryPale;
      case TaskPriority.critique:
        return const Color(0xFFFDEAEC);
    }
  }

  static String priorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.faible:
        return 'Faible';
      case TaskPriority.moyen:
        return 'Moyen';
      case TaskPriority.eleve:
        return 'Élevé';
      case TaskPriority.critique:
        return 'Critique';
    }
  }
}
