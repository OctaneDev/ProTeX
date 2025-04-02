import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:protex/common/navigation_service.dart';
import 'package:protex/document/library.dart';
import 'package:protex/editor/shortcut.dart';
import 'package:protex/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:protex/editor/editor_view.dart';
import 'package:protex/settings/settings_controller.dart';
import 'package:protex/settings/settings_service.dart';
import 'package:protex/settings/settings_view.dart';
import 'package:protex/document/document.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

// TODO create module for preprocessor
// TODO save state

/// The seed color that will be used throughout the app based on the system's theme
late final Color seedColor;

/// The eye-safe seed color
final Color eyeCare = Color(0xFFF57C00);

/// Is the screen narrower than 320px? It's a tiny screen
bool tinyScreen(BuildContext context) => MediaQuery.of(context).size.width < 320;

/// Is the screen narrower than 480px? It's a small screen
bool smallScreen(BuildContext context) => MediaQuery.of(context).size.width < 480;

/// Is the screen narrower than 720px? It's a medium screen
bool mediumScreen(BuildContext context) => MediaQuery.of(context).size.width < 720;

/// Is the screen narrower than 1440px? It's a large screen
bool largeScreen(BuildContext context) => MediaQuery.of(context).size.width < 1440;

/// Is the screen at least 1440px wide? It's an extra large screen
bool xlScreen(BuildContext context) => MediaQuery.of(context).size.width >= 1440;

/// Get the current viewport's height
double height(BuildContext context) => MediaQuery.of(context).size.height;

/// Get the current viewport's width
double width(BuildContext context) => MediaQuery.of(context).size.width;

/// Get the current viewport's aspect ratio
double aspectRatio(BuildContext context) => MediaQuery.of(context).size.aspectRatio;

/// The SharedPreferences instance to be used throughout the app
late final SharedPreferences prefs;

/// The initialized SettingsController
final SettingsController settingsController = SettingsController(SettingsService());

/// The [List] of open [Document]s throughout the App
final Library openDocs = Library();

/// A context-less way to get [AppLocalizations]
late AppLocalizations l10n;

/// The parsed [Pubspec] used to retrieve build information
late final Pubspec parsedPubspec;

/// A [List] of the [Shortcut]s for various TeX commands
final List<Shortcut> shortcuts = [
  Shortcut(name: l10n.title, shortCut: "-T-", fullValue: r"\title{}", category: Category.general),
  Shortcut(name: l10n.part, shortCut: "-PT-", fullValue: r"\part{}", category: Category.general),
  Shortcut(name: l10n.chapter, shortCut: "-CH-", fullValue: r"\chapter{}", category: Category.general),
  Shortcut(name: l10n.section, shortCut: "-SEC-", fullValue: r"\section{}", category: Category.general),
  Shortcut(name: l10n.subsection, shortCut: "-SUBSEC-", fullValue: r"\subsection{}", category: Category.general),
  Shortcut(name: l10n.subsubsection, shortCut: "-SUBSUB-", fullValue: r"\subsubsection{}", category: Category.general),
  Shortcut(name: l10n.bold, shortCut: "-B-", fullValue: r"\textbf{}", category: Category.general),
  Shortcut(name: l10n.italic, shortCut: "-I-", fullValue: r"\textit{}", category: Category.general),
  Shortcut(name: l10n.underline, shortCut: "-U-", fullValue: r"\underline{}", category: Category.general),
  Shortcut(name: l10n.emphasize, shortCut: "-EMPH-", fullValue: r"\emph{}", category: Category.general),
  Shortcut(name: l10n.unordered, shortCut: "-UL-", fullValue: "\\begin{itemize}\n\\item \n\\end{itemize}", category: Category.general),
  Shortcut(name: l10n.ordered, shortCut: "-OL-", fullValue: "\\begin{enumerate}\n\\item \n\\end{enumerate}", category: Category.general),
  Shortcut(name: l10n.listItem, shortCut: "-LI-", fullValue: r"\item ", category: Category.general),
  Shortcut(name: l10n.quote, shortCut: "-Q-", fullValue: "\\begin{quote}\n\n\\end{quote}", category: Category.general),
  Shortcut(name: l10n.tilde, shortCut: "-TIL-", fullValue: r"\tilde{}", category: Category.general),
  Shortcut(name: l10n.citation, shortCut: "-CITE-", fullValue: r"\cite{}", category: Category.general),
  Shortcut(name: l10n.equations, shortCut: "-MA-", fullValue: "\\begin{math}\n\n\\end{math}", category: Category.stem),
  Shortcut(name: l10n.bar, shortCut: "-BAR-", fullValue: r"\bar{}", category: Category.stem),
  Shortcut(name: l10n.hat, shortCut: "-HAT-", fullValue: r"\hat{}", category: Category.stem),
  Shortcut(name: l10n.fraction, shortCut: "-FRAC-", fullValue: r"\frac{}{}", category: Category.stem),
  Shortcut(name: l10n.bigFraction, shortCut: "-CFRAC-", fullValue: r"\cfrac{}{}", category: Category.stem),
  Shortcut(name: l10n.chemForm, shortCut: "-CE-", fullValue: r"\ce{}", category: Category.stem),
  Shortcut(name: l10n.pyCode, shortCut: "-PY-", fullValue: "<py>\n\n</py>", category: Category.stem),
  Shortcut(name: l10n.circuitSection, shortCut: "-CIRC-", fullValue: "\\begin{circuitikz}[american]\n\n\\end{circuitiks}", category: Category.stem),
  Shortcut(name: l10n.centerAlign, shortCut: "-CENTER-", fullValue: "\\begin{center}\n\n\\end{center}", category: Category.general),
  Shortcut(name: l10n.includeGraphics, shortCut: "-IG-", fullValue: r"\includegraphics{}", category: Category.general),
];

void main(List<String> args) async {
  // TODO add support for args
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // ignore: deprecated_member_use
  l10n = await AppLocalizations.delegate.load(basicLocaleListResolution(widgetsBinding.window.locales, AppLocalizations.supportedLocales));

  SystemTheme.fallbackColor = const Color(0xFF00897B);
  await SystemTheme.accentColor.load().then((val) {
    seedColor = SystemTheme.accentColor.defaultAccentColor;
  });

  await windowManager.ensureInitialized();
  if (Platform.isWindows) {
    await windowManager.setTitle(l10n.appName);
    await windowManager.setMinimumSize(const Size(500, 400));
  }

  final pubspec = await rootBundle.loadString('pubspec.yaml');
  parsedPubspec = Pubspec.parse(pubspec);

  // Initialize the SharedPreferences
  prefs = await SharedPreferences.getInstance();

  // Load the user's settings
  settingsController.loadSettings();

  runApp(MainApp(settingsController: settingsController));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = widget.settingsController;
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('es', '')
          ],
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: settingsController.eyeCare ? eyeCare : seedColor,
              brightness: Brightness.light
            ).copyWith(
              surfaceTint: Colors.transparent,
            ),
            appBarTheme: AppBarTheme(
              elevation: 4.0,
              shadowColor: Theme.of(context).colorScheme.shadow,
            ),
            useMaterial3: true
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: settingsController.eyeCare ? eyeCare : seedColor,
              brightness: Brightness.dark,
            ).copyWith(
              surfaceTint: Colors.transparent,
            ),
            appBarTheme: AppBarTheme(
              elevation: 4.0,
              shadowColor: Theme.of(context).colorScheme.shadow,
            ),
            useMaterial3: true
          ),
          themeMode: settingsController.themeMode,
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case EditorView.routeName:
                    return EditorView();
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  default:
                    return EditorView();
                }
              }
            );
          },
        );
      });
  }
}
