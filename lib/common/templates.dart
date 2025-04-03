import 'package:flutter/material.dart';
import 'package:protex/document/document.dart';
import 'package:protex/document/library.dart';
import 'package:protex/l10n/app_localizations.dart';
import 'package:protex/main.dart';

class Templates { // TODO add more templates
  /// An empty [Document] that is placed in the [Library] when the user wants to open a blank new file
  static Document newDoc({BuildContext? context}) => Document(null, context != null ? AppLocalizations.of(context)!.emptyTemp : l10n.emptyTemp, "", saved: false);

  static Document minArticle({BuildContext? context}) => Document(null, context != null ? AppLocalizations.of(context)!.minArticleTitle : l10n.minArticleTitle, context != null ? AppLocalizations.of(context)!.minArticleContents(settingsController.defDocFont, settingsController.authorName, settingsController.docSize != "none" ? "${settingsController.docSize}, " : "") : l10n.minArticleContents(settingsController.defDocFont, settingsController.authorName, settingsController.docSize != "none" ? "${settingsController.docSize}, " : ""), saved: false);

  static Document minReport({BuildContext? context}) => Document(null, context != null ? AppLocalizations.of(context)!.minReportTitle : l10n.minReportTitle, context != null ? AppLocalizations.of(context)!.minReportContents(settingsController.defDocFont, settingsController.authorName, settingsController.docSize != "none" ? "${settingsController.docSize}, " : "") : l10n.minReportContents(settingsController.defDocFont, settingsController.authorName, settingsController.docSize != "none" ? "${settingsController.docSize}, " : ""), saved: false);

  static Document minBook({BuildContext? context}) => Document(null, context != null ? AppLocalizations.of(context)!.minBookTitle : l10n.minBookTitle, context != null ? AppLocalizations.of(context)!.minBookContents(settingsController.defDocFont, settingsController.authorName, settingsController.docSize != "none" ? "${settingsController.docSize}, " : "") : l10n.minBookContents(settingsController.defDocFont, settingsController.authorName, settingsController.docSize != "none" ? "${settingsController.docSize}, " : ""), saved: false);

  /// A list of template [Document]s for easy iteration
  static List<Document> allTemplates(BuildContext? context) => [newDoc(context: context), minArticle(context: context), minReport(context: context), minBook(context: context)];
}