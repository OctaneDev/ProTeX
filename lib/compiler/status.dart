import 'package:protex/document/document.dart';

class Status {
  /// Whether the document is currently being compiled
  bool building = false;
  /// Whether the document is currently being saved
  bool saving = false;

  /// If the document is building, this is its percentage to completion
  double buildProgress = 0;

  /// Private bool [Function] to get the status of the document
  bool _inProgress() => building || saving;

  /// Whether something is currently happening with the open [Document]
  late bool inProgress = _inProgress();
}