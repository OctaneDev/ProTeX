// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protex/compiler/subprocess_runner.dart';
import 'package:protex/document/document.dart';
import 'package:protex/exceptions/subprocess_exception.dart';
import 'package:protex/exceptions/tex_exception.dart';
import 'package:protex/l10n/app_localizations.dart';
import 'package:protex/main.dart';
import 'package:url_launcher/url_launcher.dart';

class Compiler extends ChangeNotifier {
  /// Initialize the builder with [BuildContext] from the calling class and a [Document] to build.
  Compiler(this.context, this.document);

  BuildContext context;

  Document document;

  bool _running = false;

  /// Whether the [Compiler] is currently running.
  /// 
  /// This value is read only except through the [stopEarly] method.
  bool get running => _running;

  void get stopEarly {
    _running = false;
    document.updateBuildProgress(0);
    notifyListeners();
  }

  /// The precompiler method that will extract and interpret Python in the document before injecting it back into the document and sending it to the TeX compiler of choice.
  /// 
  /// Usage:
  /// ```dart
  /// await Compiler.compile
  /// ```
  /// 
  /// Throws [Exception] if Python is not installed or available in the system's PATH.
  Future<String?> get compile async {
    if (!document.saved) await document.save(context);
    // Update the running status
    _running = true;

    // Update the [Document]'s [Status] to show that it is currently building
    document.updateBuildStatus(true);

    // Define the variables that will be used during the build process
    /// The final PDF at the end of the compilation
    late final File finalPdf;
    /// The path of the temporary TeX file
    String tempTexPath = "${(await getApplicationCacheDirectory()).path}${Platform.isWindows ? "\\" : "/"}temp.tex";
    /// The path of the temporary Python file
    String tempPyPath = "${(await getApplicationCacheDirectory()).path}${Platform.isWindows ? "\\" : "/"}temp.py";
    /// The final TeX to be compiled
    String tex = "";
    /// A [String] to store all of the Python code throughout the document
    String allPy = "";
    /// The current index of the Python section being executed
    int index = 0;
    /// A [List] of all the outputs from each Python section
    List<String> pyOuts = [];
    /// How many times a given Python section prints
    List<int> prints = [];
    /// A storage [List] of Python sections to be removed from the document
    List<String> toRemove = [];
    /// The TeX with any Python sections removed after processing
    String stripped = document.contents;
    /// A temporary string for holding various bits of TeX
    String tempTex = document.contents;
    /// A function to get the system's installed version of Python, if one exists
    Future<String?> getPython() async {
      if ((await subprocess(exec: "python", args: ['--version']))?.exitCode == 0) return "python";
      if ((await subprocess(exec: "python3", args: ['--version']))?.exitCode == 0) return "python3";
      return null;
    }

    /// A string containing the system's installed version of Python, if one exists.
    /// 
    /// If one doesn't exist, an [Exception] will be thrown.
    String? python = await getPython();
    if (python == null) {
      document.updateBuildStatus(false);
      _running = false;
      return AppLocalizations.of(context)!.pythonNotFoundException;
    }

    document.updateBuildProgress(5);

    void biber(String pdfName) async { // TODO ensure biber support and add other bibliography support like bibtex
      document.updateBuildProgress(65);
      ProcessResult? tempTex = (await subprocess(exec: settingsController.texCompiler.toLowerCase(), args: [
        "--halt-on-error",
        tempTexPath
      ]))?.stdout;
      if (tempTex == null) {
        document.updateBuildProgress(0);
        throw SubprocessException(name: AppLocalizations.of(context)!.compileFailedException);
      } else if (tempTex.stderr != null && tempTex.exitCode != 0) {
        document.updateBuildProgress(0);
        throw TeXException(error: tempTex.stderr);
      } else {
        document.updateBuildProgress(70);
        ProcessResult? biber = (await subprocess(exec: "biber", args: [tempTexPath]))?.stdout;
        if (biber == null) {
          document.updateBuildProgress(0);
          throw SubprocessException(name: AppLocalizations.of(context)!.biberFailedException);
        } else if (biber.stderr != null && biber.exitCode != 0) {
          document.updateBuildProgress(0);
          throw TeXException(error: biber.stderr);
        } else {
          document.updateBuildProgress(75);
          ProcessResult? comp = (await subprocess(exec: settingsController.texCompiler.toLowerCase(), args: [
            "--halt-on-error",
            tempTexPath,
            //"--output-directory=\"${File(document.path!).parent.path}\"",
          ], wd: File(document.path!).parent.path))?.stdout;
          if (comp == null) {
            document.updateBuildProgress(0);
            throw SubprocessException(name: AppLocalizations.of(context)!.compileFailedException);
          } else if (comp.stderr != null && comp.exitCode != 0) {
            document.updateBuildProgress(0);
            throw TeXException(error: comp.stderr);
          } else {
            File tempPdf = File("${File(document.path!).parent}${Platform.isWindows ? "\\" : "/"}temp.py");
            finalPdf = tempPdf.renameSync(pdfName);
          }
        }
      }
    }

    // General compiler function
    Future<String?> compile() async {
      document.updateBuildProgress(60);
      ProcessResult? texCode = (await subprocess(exec: settingsController.texCompiler.toLowerCase(), args: [
        "--halt-on-error",
        "--jobname=${document.title.split(".").first}",
        (tempTexPath.replaceAll(r"\", "/")),
        "--output-format=pdf"
      ], wd: File(document.path!).parent.path));
      document.updateBuildProgress(70);
      if (texCode == null) {
        document.updateBuildProgress(0);
        throw SubprocessException();
      } else if (texCode.exitCode != 0 && texCode.stderr != null) {
        document.updateBuildProgress(0);
        _running = false;
        return texCode.stdout;
      } else {
        document.updateBuildProgress(80);
        return null;
      }
    }

    int count(String big, String small) => big.split(small).length-1;

    document.updateBuildProgress(10);

    String endSection = '--- End Section ---';

    while (stripped.contains("<py>") && stripped.contains("</py>")) {
      String py = stripped.split("<py>")[1].split("</py>").first;
      allPy = "$allPy\n$py\nprint(\"$endSection\")\n";
      String temp = "<py>$py</py>";
      toRemove.add(temp);
      int printCount = count(py, "print(");
      prints.add(printCount);
      index += 1;
      stripped = stripped.replaceFirst(temp, "");
    }
    document.updateBuildProgress(20);

    File(tempPyPath).writeAsStringSync(allPy);

    document.updateBuildProgress(25);
    List<String> rem1() => toRemove;
    List<String> toRemove1 = rem1();
    
    document.updateBuildProgress(27);
    ProcessResult? pyCode = await subprocess(exec: python, args: [tempPyPath]);
    bool hasOuts = true;
    if (pyCode == null) {
      document.updateBuildProgress(0);
      _running = false;
      return "pyCode failed";
    } else if (pyCode.exitCode != 0 && pyCode.stderr != null) {
      document.updateBuildProgress(0);
      _running = false;
      return pyCode.stderr;
    } else {
      document.updateBuildProgress(30);
      if (pyCode.stdout == "'" || pyCode.stdout == "" || pyCode.stdout == endSection) {
        hasOuts = false;
      }

      if (index != 0 && hasOuts) {
        if (index > 1) {
          pyOuts = pyCode.stdout.toString().replaceAll("\\\\", "\\").replaceAll("\\n", "\n").split(endSection);
          String replacement = "";
          for (int i = 0; i < index; i++) {
            replacement = "";
            int offset = 0;
            for (int j = 0; j < prints[i]; j++) {
              try {
                replacement = "$replacement${pyOuts[i+j]}";
              } catch (e) {
                log("replacement failed", error: e);
                if (j > 1) {
                  offset += 1;
                } else {
                  offset += j;
                }
                if (i+offset < pyOuts.length) replacement = "$replacement ${pyOuts[i+offset]}";
              }
              if (prints[i] > 1 && j < prints[i]-1) {
                replacement = "$replacement \\\\n";
              }
            }
            tempTex = tempTex.replaceAll(toRemove1[i], replacement);
          }
        } else {
          tempTex = tempTex.replaceAll(toRemove1.first, pyCode.stdout).replaceAll(endSection, "");
        }
        tex = tempTex;
        document.updateBuildProgress(35);
      } else if (!hasOuts) {
        tex = tempTex;
        document.updateBuildProgress(35);
      }
      if (document.path == null) {
        document.updateBuildProgress(0);
        _running = false;
        return null;
      }
      String pdfName = document.path!.replaceAll(".ptex", ".pdf");
      document.updateBuildProgress(40);
      File(tempTexPath).writeAsStringSync(tex.replaceAll("\\r", "\\\\"));
      document.updateBuildProgress(45);
      if (tex.toLowerCase().contains("backend=biber")) {
        try {
          biber(pdfName);
        } catch (e) {
          log(error: e, "biber failed");
          document.updateBuildProgress(0);
          _running = false;
          return "biber failed";
        }
      } else {
        document.updateBuildProgress(50);
        String? compileResult = await compile();
        if (compileResult != null) {
          document.updateBuildProgress(0);
          _running = false;
          return compileResult;
        } else if (!settingsController.internalPDF && running) {
          document.updateBuildProgress(90);
          if (!await launchUrl(Uri(path: pdfName, scheme: "file"), mode: LaunchMode.externalNonBrowserApplication)) {
            document.updateBuildProgress(90);
            _running = false;
            return AppLocalizations.of(context)!.openPdfException(pdfName);
          }
        }
      }
      finalPdf = File(pdfName);

      document.updatePdf(finalPdf);
      document.updateBuildProgress(100);
      _running = false;
      return null;
    }
  }
}