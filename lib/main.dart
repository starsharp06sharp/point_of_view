import 'package:flutter/material.dart';

import 'l10n/generated/app_localizations.dart';
import 'screens/calculator_screen.dart';
import 'services/hidden_files_service.dart';
import 'services/locale_service.dart';
import 'services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.load();
  await HiddenFilesService.load();
  await LocaleService.load();
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.mode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: LocaleService.locale,
          builder: (context, locale, _) {
            return MaterialApp(
              onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
              debugShowCheckedModeBanner: false,
              themeMode: mode,
              locale: locale,
              supportedLocales: LocaleService.supported,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              localeListResolutionCallback: LocaleService.resolve,
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.light,
                ),
                scrollbarTheme: _scrollbarTheme(),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.dark,
                ),
                scrollbarTheme: _scrollbarTheme(),
              ),
              home: const CalculatorScreen(),
            );
          },
        );
      },
    );
  }
}

ScrollbarThemeData _scrollbarTheme() {
  return ScrollbarThemeData(
    thickness: WidgetStateProperty.resolveWith<double>((states) {
      if (states.contains(WidgetState.dragged)) return 14;
      if (states.contains(WidgetState.hovered)) return 10;
      return 6;
    }),
    radius: const Radius.circular(8),
  );
}
