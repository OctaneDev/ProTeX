// ignore_for_file: use_build_context_synchronously

import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protex/common/templates.dart';
import 'package:protex/document/document.dart';
import 'package:protex/l10n/app_localizations.dart';

class Library extends ChangeNotifier {
  /// Internal, private state of the [Library]
  final List<Document> _documents = [];

  /// An unmodifiable view of the [Document]s in the [Library]
  UnmodifiableListView<Document> get documents => UnmodifiableListView(_documents);

  /// The current size of the [Library]
  int get length => _documents.length;

  /// The index of the last [Document] in the [Library]
  int get last => _documents.indexOf(_documents.last);

  /// Whether the [Library] is empty
  bool get isEmpty => _documents.isEmpty;

  /// Whether the [Library] is not empty
  bool get isNotEmpty => _documents.isNotEmpty;

  /// Internal, private current index
  int _currentIndex = 0;

  /// The current index of the [Document] in the library being viewed by the user
  int get currentIndex => _currentIndex;

  @override
  String toString() {
    return documents.toString();
  }

  /// Updates the [currentIndex]
  void updateIndex(int index) {
    _currentIndex = index;
    //notifyListeners();
  }

  /// Adds a [Document] to the [Library]
  void add(Document document) {
    document.addListener(() => notifyListeners());
    _documents.add(document);
    notifyListeners();
  }

  /// Adds multiple [Document]s to the [Library]
  void addAll(List<Document> documents) {
    for (Document document in documents) {
      document.addListener(() => notifyListeners());
    }
    _documents.addAll(documents);
    notifyListeners();
  }

  /// Removes a single [Document] from the [Library]
  void remove(Document document) {
    _documents.remove(document);
    notifyListeners();
  }

  /// Removes a single [Document] at a given index from the [Library]
  void removeAt(int index) {
    try {
      _documents.removeAt(index);
      notifyListeners();
    } catch (e) {
      log("user moved too fast", error: e);
    }
  }

  /// Removes all [Document]s from the [Library] at once
  void removeAll() {
    _documents.clear();
    notifyListeners();
  }

  /// Replaces the current open [Document] with a new one 
  void newDocument(int index) {
    _documents[index] = Templates.newDoc();
    notifyListeners();
  }

  /// Open a single [Document] with the [FilePicker]
  void open(BuildContext context) async {
    String? path;
    FilePickerResult? result;

    final Directory documentsPath = await getApplicationDocumentsDirectory();

    if (Platform.isLinux) {
      path = await FilesystemPicker.openDialog(
        context: context,
        title: AppLocalizations.of(context)!.open,
        showGoUp: true,
        fileTileSelectMode: FileTileSelectMode.wholeTile,
        directory: Directory("/home/"),
        shortcuts: [FilesystemPickerShortcut(name: AppLocalizations.of(context)!.root, path: Directory("/")), FilesystemPickerShortcut(name: AppLocalizations.of(context)!.home, path: Directory("/home/")), FilesystemPickerShortcut(name: AppLocalizations.of(context)!.documents, path: documentsPath),],
        fsType: FilesystemType.file,
        allowedExtensions: ['.tex', '.ptex'],
      );
    } else {
      result = await FilePicker.platform.pickFiles(
        dialogTitle: AppLocalizations.of(context)!.open,
        initialDirectory: (await getApplicationDocumentsDirectory()).toString(),
        type: FileType.custom,
        allowedExtensions: ['tex', 'ptex']
      );
    }

    bool exists = false;
    int? existingIndex;

    if (documents.isNotEmpty) {
      for (Document doc in documents) {
        if ((result != null && doc.path == result.paths.first) || (path != null && doc.path == path)) {
          exists = true;
          existingIndex = documents.indexOf(doc);
        }
      }
    }


    if (!exists && result != null) {
      //log(name: "Result", result.toString());
      add(Document.fromFile(File(result.paths.first!)));
    } else if (!exists && path != null) {
      //log(name: "Path", path.toString());
      add(Document.fromFile(File(path)));
    } else if (exists && existingIndex != null) {
      updateIndex(existingIndex);
    } else {
      log(result.toString(), name: "Library.open");
    }
  }

  /// Open multiple [Document]s from a drag and drop event
  void openAll(List<XFile> files) {
    for (XFile file in files) {
      if (file.path.endsWith(".ptex") || file.path.endsWith(".tex")) add(Document.fromFile(File(file.path)));
    }
  }
}