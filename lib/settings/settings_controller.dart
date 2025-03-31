import 'package:flutter/material.dart';

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

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  void loadSettings() {
    _themeMode = _settingsService.themeMode();
    _eyeCare = _settingsService.colorMode();
    _texCompiler = _settingsService.texCompiler();
    _internalPDF = _settingsService.whichPDFViewer();
    _defDocFont = _settingsService.docFont();
    _authorName = _settingsService.getAuthor();
    _showShortcuts = _settingsService.showShortcuts();

    // Important! Inform listeners a change has occurred.
    notifyListeners();
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