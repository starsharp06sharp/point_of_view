import 'package:flutter/material.dart';

import '../models/sort_option.dart';
import 'generated/app_localizations.dart';

/// Convenience wrappers so screens don't need to switch on enums inline.

extension SortOptionLabel on SortOption {
  String menuLabel(BuildContext context) {
    final l = AppLocalizations.of(context);
    switch (field) {
      case SortField.name:
        return order == SortOrder.asc ? l.sortMenuNameAsc : l.sortMenuNameDesc;
      case SortField.modified:
        return order == SortOrder.asc
            ? l.sortMenuModifiedAsc
            : l.sortMenuModifiedDesc;
    }
  }

  String shortLabel(BuildContext context) {
    final l = AppLocalizations.of(context);
    switch (field) {
      case SortField.name:
        return order == SortOrder.asc ? l.sortLabelNameAsc : l.sortLabelNameDesc;
      case SortField.modified:
        return order == SortOrder.asc
            ? l.sortLabelModifiedAsc
            : l.sortLabelModifiedDesc;
    }
  }
}

String themeModeLabel(BuildContext context, ThemeMode mode) {
  final l = AppLocalizations.of(context);
  switch (mode) {
    case ThemeMode.light:
      return l.themeLight;
    case ThemeMode.dark:
      return l.themeDark;
    case ThemeMode.system:
      return l.themeSystem;
  }
}
