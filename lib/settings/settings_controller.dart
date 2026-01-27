import 'package:flutter/material.dart';
import 'package:protex/document/library.dart';

import 'settings_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  // Make SettingsService a private variable so it is not used directly.
  final SettingsService _settingsService;

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late ThemeMode _themeMode;

  // Allow Widgets to read the user's preferred ThemeMode.
  ThemeMode get themeMode => _themeMode;

  late bool _eyeCare;
  /// Whether the user has selected to use the eyecare theme
  bool get eyeCare => _eyeCare;

  late bool _rememberState;
  /// Whether the user has selected to remember open documents between sessions
  bool get rememberState => _rememberState;

  late String _texCompiler;
  /// Which TeX compiler the user has chosen
  String get texCompiler => _texCompiler;

  late bool _internalPDF;
  /// Whether the user has selected to use the built-in PDF viewer
  bool get internalPDF => _internalPDF;

  late String _defDocFont;
  /// The default document font size for templates
  String get defDocFont => _defDocFont;

  late String _authorName;
  /// The default author name for documents and metadata
  String get authorName => _authorName;

  late bool _showShortcuts;
  /// Whether to show the shortcuts panel
  bool get showShortcuts => _showShortcuts;

  late Library _openDocs;
  /// The library of open documents
  Library get openDocs => _openDocs;

  late String _docSize;
  /// The default document size for templates
  String get docSize => _docSize;
  Map<String, String> get docSizes => {
    "none": "Compiler default",
    "a0paper": "A0",
    "a1paper": "A1",
    "a2paper": "A2",
    "a3paper": "A3",
    "a4paper": "A4",
    "a5paper": "A5",
    "a6paper": "A6",
    "b0paper": "B0",
    "b1paper": "B1",
    "b2paper": "B2",
    "b3paper": "B3",
    "b4paper": "B4",
    "b5paper": "B5",
    "b6paper": "B6",
    "c0paper": "C0",
    "c1paper": "C1",
    "c2paper": "C2",
    "c3paper": "C3",
    "c4paper": "C4",
    "c5paper": "C5",
    "c6paper": "C6",
    "b0j": "B0 Japanese",
    "b1j": "B1 Japanese",
    "b2j": "B2 Japanese",
    "b3j": "B3 Japanese",
    "b4j": "B4 Japanese",
    "b5j": "B5 Japanese",
    "b6j": "B6 Japanese",
    "ansiapaper": "ANSI A",
    "ansibpaper": "ANSI B",
    "ansicpaper": "ANSI C",
    "ansidpaper": "ANSI D",
    "ansiepaper": "ANSI E",
    "letterpaper": "Letter",
    "legalpaper": "Legal",
    "executivepaper": "Executive",
  };

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  void loadSettings() {
    _themeMode = _settingsService.themeMode();
    _eyeCare = _settingsService.colorMode();
    _rememberState = _settingsService.rememberState();
    _texCompiler = _settingsService.texCompiler();
    _internalPDF = _settingsService.whichPDFViewer();
    _defDocFont = _settingsService.docFont();
    _authorName = _settingsService.getAuthor();
    _showShortcuts = _settingsService.showShortcuts();
    _openDocs = _settingsService.openDocs();
    _docSize = _settingsService.docSize();

    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  Future<void> updateDocSize(String newSize) async {
    if (newSize == _docSize) return;

    _docSize = newSize;

    notifyListeners();

    await _settingsService.updateDocSize(newSize);
  }

  Future<void> get updateLibrary async {
    await _settingsService.updateLibrary(_openDocs);
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    // Do not perform any work if new and old ThemeMode are identical
    if (newThemeMode == _themeMode) return;

    // Otherwise, store the new ThemeMode in memory
    _themeMode = newThemeMode;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateThemeMode(newThemeMode);
  }

  /// Update and persist the color mode based on the user's selection
  Future<void> updateeyeCare(bool? newEyeCare) async {
    if (newEyeCare == null || newEyeCare == _eyeCare) return;

    _eyeCare = newEyeCare;

    notifyListeners();

    await _settingsService.updateColorMode(newEyeCare);
  }

  /// Update and persist the remember state based on the user's selection
  Future<void> updateRememberState(bool? newRememberState) async {
    if (newRememberState == null || newRememberState == _rememberState) return;

    _rememberState = newRememberState;
    
    notifyListeners();

    await _settingsService.updateRememberState(newRememberState);
  }

  Future<void> updateTexCompiler(String? compiler) async {
    if (compiler == null || compiler == _texCompiler) return;

    _texCompiler = compiler;

    notifyListeners();

    await _settingsService.updateTexCompiler(compiler);
  }

  Future<void> updatePDFViewer(bool? useInternal) async {
    if (useInternal == null || useInternal == _internalPDF) return;

    _internalPDF = useInternal;

    notifyListeners();

    await _settingsService.updatePDFViewer(useInternal);
  }

  Future<void> updateDocFont(String? newSize) async {
    if (newSize == null || newSize == _defDocFont) return;

    _defDocFont = newSize;

    notifyListeners();

    await _settingsService.updateDocFont(newSize);
  }

  Future<void> updateAuthorName(String? newAuthor) async {
    if (newAuthor == null || newAuthor == _authorName) return;

    _authorName = newAuthor;

    await _settingsService.updateAuthorName(newAuthor);
  }

  Future<void> updateShowShortcuts(bool? show) async {
    if (show == null || show == _showShortcuts) return;

    _showShortcuts = show;
    
    notifyListeners();

    await _settingsService.updateShowShortcuts(show);
  }

  void notifyAuthorName() => notifyListeners();
}