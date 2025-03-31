// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:protex/common/colors.dart';
import 'package:protex/common/navigation_service.dart';
import 'package:protex/compiler/builder.dart';
import 'package:protex/compiler/status.dart';
import 'package:protex/l10n/app_localizations.dart';
import 'package:protex/main.dart';
import 'package:uuid/v8.dart';

class Document extends ChangeNotifier {
  Document(this.path, this.title, this.contents, {this.metadata, this.saved = true, this.cursorPosition = 0, this.pdf});

  final String id = UuidV8().generate();
  String? path;
  String title;
  String contents;
  Map<String, String>? metadata;
  bool saved;
  int cursorPosition = 0;
  File? pdf;
  final Status status = Status();
  late Compiler? _compiler;
  Compiler? get compiler => _compiler;

  factory Document.fromFile(File file) {
    String readFile = file.readAsStringSync();
    bool isJson = false;

    try {
      jsonDecode(readFile);
      isJson = true;
    } catch (e) {
      log("plain text file", error: e);
      showAdaptiveDialog(
        context: NavigationService.navigatorKey.currentContext!, 
        builder: (context) {
          return AlertDialog.adaptive(
            title: Text(l10n.oldFileWarningTitle),
            content: Text(l10n.oldFileWarning(file.path)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.ok))
            ],
          );
        }
      );
    }
    late final Map<String, dynamic> phase1Metadata;
    late final Map<String, String> phase2Metadata;
    if (isJson) {
      try {
        phase1Metadata = jsonDecode(readFile)['metadata'];
        phase2Metadata = phase1Metadata.map((key, value) => MapEntry(key, value.toString()));
      } catch (e) {
        log("failed to parse metadata", error: e);
        phase2Metadata = {};
      }
    }

    return Document(file.path, Platform.isWindows ? file.path.split(r'\').last : file.path.split('/').last, isJson ? jsonDecode(readFile)['content'] : readFile, metadata: isJson ? phase2Metadata : null, saved: true);
  }

  @override
  String toString() {
    return [id, path, title, contents, metadata, saved].toString();
  }

  void createCompiler(BuildContext context) {
    //newCompiler.addListener(() => notifyListeners());
    _compiler = Compiler(context, this);
    notifyListeners();
  }

  Future<String?> get compile async => await _compiler?.compile;

  Future<void> save(BuildContext context) async {
    if (path == null) {
      if (Platform.isLinux) {
        String? tempPath = await FilesystemPicker.openDialog(
          context: context,
          title: AppLocalizations.of(context)!.saveAs,
          showGoUp: true,
          contextActions: [
            FilesystemPickerNewFolderContextAction(),
          ],
          directory: Directory("/home/"),
          shortcuts: [FilesystemPickerShortcut(name: AppLocalizations.of(context)!.root, path: Directory("/")), FilesystemPickerShortcut(name: AppLocalizations.of(context)!.home, path: Directory("/home/")), FilesystemPickerShortcut(name: AppLocalizations.of(context)!.documents, path: await getApplicationDocumentsDirectory()),],
          fsType: FilesystemType.folder,
          allowedExtensions: ['.ptex'],
        );
        if (tempPath != null) {
          title = await showDialog(
            context: context, 
            barrierDismissible: false,
            builder: (context) {
              String? returnValue;
              bool? valid;

              return StatefulBuilder(builder: (context, setState) {
                return AlertDialog.adaptive(
                  title: Text(AppLocalizations.of(context)!.saveAs),
                  content: TextField(
                    autofocus: true,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fileName, errorText: valid ?? true ? null : AppLocalizations.of(context)!.invalidFileName, errorBorder: valid ?? true ? null : OutlineInputBorder(borderSide: BorderSide(color: AppColors.warning))),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        setState(() {
                          valid = false;
                        });
                        return;
                      } else if (value.contains("/") || value.contains("\\") || value.contains(":") || value.contains("*") || value.contains("?") || value.contains("\"") || value.contains("<") || value.contains(">") || value.contains("|")) {
                        setState(() {
                          valid = false;
                        });
                        return;
                      } else {
                        setState(() {
                          valid = true;
                        });
                      }
                      returnValue = value;
                    },
                  ), 
                  actions: [
                    TextButton(onPressed: () => valid ?? false ? Navigator.pop(context, returnValue) : null, child: Text(AppLocalizations.of(context)!.ok))
                  ],
                );
              }
            );
          });
          path = "$tempPath/${title.replaceAll(" ", "_")}${title.endsWith('.ptex') ? "" : ".ptex"}";
        }
      } else {
        path = await FilePicker.platform.saveFile(
          dialogTitle: AppLocalizations.of(context)!.save,
          initialDirectory: path ?? (await getApplicationDocumentsDirectory()).toString(),
          type: FileType.custom,
          allowedExtensions: ['ptex']
        );
      }
      if (path != null) {
        //log(path!);
        if (!path!.endsWith('.ptex')) {
          log(path!.substring(path!.length-4));
          path = "${path!}.ptex";
        }
        title = Platform.isWindows ? path!.split('\\').last : path!.split('/').last;
        saved = true;
      }
    }
    if (path != null) {
      if (settingsController.authorName.isNotEmpty) metadata != null ? metadata!['authorName'] = settingsController.authorName : metadata = {"authorName": settingsController.authorName};
      File(path!).writeAsStringSync(jsonEncode({'metadata': metadata, 'content': contents, 'id': id}));
      saved = true;
      if (title.endsWith("*")) title = title.substring(0, title.length-1);
    }

    notifyListeners();
  }

  void documentChanged() {
    if (!title.contains("*")) title += '*';
    saved = false;
    notifyListeners();
  }

  void updateBuildStatus(bool currentStatus) {
    status.building = currentStatus;
    notifyListeners();
  }

  void updateBuildProgress(double currentProgress) {
    status.buildProgress = currentProgress > 1 ? currentProgress/100 : currentProgress;
    if (currentProgress == 0 || currentProgress == 100) {
      status.building = false;
    }
    notifyListeners();
  }

  void updatePdf(File newPdf) {
    pdf = newPdf;
    notifyListeners();
  }
}