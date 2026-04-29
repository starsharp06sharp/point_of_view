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
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.dark,
                ),
              ),
              home: const CalculatorScreen(),
            );
          },
        );
      },
    );
  }
}
