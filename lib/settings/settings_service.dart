import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:protex/document/library.dart';
import 'package:protex/main.dart';

/// A service that stores and retrieves user settings.
class SettingsService {

  String themeModeString(ThemeMode theme) {
    return {
      ThemeMode.light: "light",
      ThemeMode.dark: "dark",
      ThemeMode.system: "auto",
    }[theme] ?? "light";
  }

  ThemeMode? themeModeFromString(String? theme) {
    return {
      "light": ThemeMode.light,
      "dark": ThemeMode.dark,
      "auto": ThemeMode.system,
    }[theme];
  }

  Library openDocs() {
    String? library = prefs.getString("openDocs");
    return library != null ? Library.fromJson(jsonDecode(library)) : Library();
  }

  /// Loads the User's preferred ThemeMode from local or remote storage.
  ThemeMode themeMode() {
    String? savedTheme = prefs.getString("theme");
    return themeModeFromString(savedTheme) ?? ThemeMode.system;
  }

  /// Loads the User's preferred color scheme from local or remote storage.
  bool colorMode() {
    bool? savedColorMode = prefs.getBool("colorMode");
    return savedColorMode ?? false;
  }

  /// Loads whether the user has selected to remember open documents between sessions
  bool rememberState() {
    bool? remember = prefs.getBool("rememberState");
    return remember ?? true;
  }

  String texCompiler() {
    String? compiler = prefs.getString("texCompiler");
    return compiler ?? l10n.lualatex;
  }

  bool whichPDFViewer() {
    bool? internalPDF = prefs.getBool("whichPDF");
    return internalPDF ?? false;
  }

  String docFont() {
    String? fontSize = prefs.getString("fontSize");
    return fontSize ?? "10pt";
  }

  String getAuthor() {
    String? authorName = prefs.getString("authorName");
    return authorName ?? "";
  }

  bool showShortcuts() {
    bool? show = prefs.getBool("showShortcuts");
    return show ?? false;
  }

  String docSize() {
    String? docSize = prefs.getString("docSize");
    return docSize ?? "none";
  }

  Future<void> updateDocSize(String docSize) async {
    await prefs.setString("docSize", docSize);
  }

  Future<void> updateLibrary(Library library) async {
    await prefs.setString("openDocs", jsonEncode(library.toJson()));
  }

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    await prefs.setString("theme", themeModeString(theme));
  }

  /// Persists the user's preferred color mode to local or remote storage.
  Future<void> updateColorMode(bool eyeCare) async {
    await prefs.setBool("colorMode", eyeCare);
  }

  /// Persists whether the user has selected to remember open documents between sessions
  Future<void> updateRememberState(bool rememberState) async {
    await prefs.setBool("rememberState", rememberState);
  }

  /// Persists the user's preferred TeX compiler to local or remote storage.
  Future<void> updateTexCompiler(String compiler) async {
    await prefs.setString("texCompiler", compiler);
  }

  /// Persists the user's preferred PDF viewer to local or remote storage.
  Future<void> updatePDFViewer(bool internalPDF) async {
    await prefs.setBool("whichPDF", internalPDF);
  }

  Future<void> updateDocFont(String docFont) async {
    await prefs.setString("fontSize", docFont);
  }

  Future<void> updateAuthorName(String authorName) async {
    await prefs.setString("authorName", authorName);
  }

  Future<void> updateShowShortcuts(bool show) async {
    await prefs.setBool("showShortcuts", show);
  }
}