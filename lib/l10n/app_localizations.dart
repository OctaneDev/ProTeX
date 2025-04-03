import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'ProTeX'**
  String get appName;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get ok;

  /// No description provided for @cont.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get cont;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copied;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @newDoc.
  ///
  /// In en, this message translates to:
  /// **'New document'**
  String get newDoc;

  /// No description provided for @newTab.
  ///
  /// In en, this message translates to:
  /// **'New tab'**
  String get newTab;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveAs.
  ///
  /// In en, this message translates to:
  /// **'Save as...'**
  String get saveAs;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export...'**
  String get export;

  /// No description provided for @build.
  ///
  /// In en, this message translates to:
  /// **'Build PDF'**
  String get build;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close document'**
  String get close;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @prefs.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get prefs;

  /// No description provided for @find.
  ///
  /// In en, this message translates to:
  /// **'Find...'**
  String get find;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// No description provided for @cacheLocation.
  ///
  /// In en, this message translates to:
  /// **'Cache folder'**
  String get cacheLocation;

  /// No description provided for @tempLocation.
  ///
  /// In en, this message translates to:
  /// **'Temp folder'**
  String get tempLocation;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @showShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Show shortcuts'**
  String get showShortcuts;

  /// No description provided for @findReplace.
  ///
  /// In en, this message translates to:
  /// **'Find and replace'**
  String get findReplace;

  /// No description provided for @replaceAll.
  ///
  /// In en, this message translates to:
  /// **'Replace all'**
  String get replaceAll;

  /// No description provided for @findNext.
  ///
  /// In en, this message translates to:
  /// **'Find next'**
  String get findNext;

  /// No description provided for @findPrev.
  ///
  /// In en, this message translates to:
  /// **'Find previous'**
  String get findPrev;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Status: ready'**
  String get statusReady;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get homeTitle;

  /// No description provided for @emptyTemp.
  ///
  /// In en, this message translates to:
  /// **'Empty Document'**
  String get emptyTemp;

  /// No description provided for @minArticleTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic article'**
  String get minArticleTitle;

  /// No description provided for @minArticleContents.
  ///
  /// In en, this message translates to:
  /// **'\\documentclass[{fontSize}]{article}\n\\usepackage[utf8]{inputenc}\n\\usepackage[margin=1in]{geometry}\n\\author{{name}}\n\\title{Blank article}\n\\date{\\today}\n\\begin{document}\n\\maketitle\n\\end{document}'**
  String minArticleContents(String fontSize, String name);

  /// No description provided for @minReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic report'**
  String get minReportTitle;

  /// No description provided for @minReportContents.
  ///
  /// In en, this message translates to:
  /// **'\\documentclass[{fontSize}]{report}\n\\usepackage[utf8]{inputenc}\n\\usepackage[margin=1in]{geometry}\n\\author{{name}}\n\\title{Blank report}\n\\date{\\today}\n\\begin{document}\n\\maketitle\n\\tableofcontents\n\\end{document}'**
  String minReportContents(String fontSize, String name);

  /// No description provided for @minBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic book'**
  String get minBookTitle;

  /// No description provided for @minBookContents.
  ///
  /// In en, this message translates to:
  /// **'\\documentclass[{fontSize}]{book}\n\\usepackage[utf8]{inputenc}\n\\usepackage[margin=1in]{geometry}\n\\author{{name}}\n\\title{Blank book}\n\\date{\\today}\n\\begin{document}\n\\frontmatter\n\\maketitle\n\\tableofcontents\n\\chapter{Preface}\n\\mainmatter\n\\chapter{First chapter}\n\\appendix\n\\chapter{Appendix}\n\\backmatter\n\\chapter{Final note}\n\\end{document}'**
  String minBookContents(String fontSize, String name);

  /// No description provided for @unsavedChangesWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning: unsaved changes'**
  String get unsavedChangesWarningTitle;

  /// No description provided for @unsavedChangesWarning.
  ///
  /// In en, this message translates to:
  /// **'This document has unsaved changes that will be lost if you continue.'**
  String get unsavedChangesWarning;

  /// No description provided for @oldFileWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning: document missing features'**
  String get oldFileWarningTitle;

  /// No description provided for @oldFileWarning.
  ///
  /// In en, this message translates to:
  /// **'The document you ({file}) selected does not support all the features of this app. If you save changes to this file, it will no longer be compatible with other TeX editors.'**
  String oldFileWarning(String file);

  /// No description provided for @compileErrorDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed to compile'**
  String get compileErrorDialogTitle;

  /// No description provided for @pythonNotFoundException.
  ///
  /// In en, this message translates to:
  /// **'An acceptable version of Python was not found on your computer. Please make sure you have Python 3.x installed and that the binary\'s directory is in your system\'s PATH.'**
  String get pythonNotFoundException;

  /// No description provided for @compileFailedException.
  ///
  /// In en, this message translates to:
  /// **'The selected TeX compiler failed to process your document.'**
  String get compileFailedException;

  /// No description provided for @biberFailedException.
  ///
  /// In en, this message translates to:
  /// **'Biber failed to process your document. Please ensure that it is installed and can be called as \"biber\" from your system\'s shell.'**
  String get biberFailedException;

  /// No description provided for @openPdfException.
  ///
  /// In en, this message translates to:
  /// **'Failed to launch file {file}.'**
  String openPdfException(String file);

  /// No description provided for @stoppedEarly.
  ///
  /// In en, this message translates to:
  /// **'PDF build stopped early.'**
  String get stoppedEarly;

  /// No description provided for @invalidTex.
  ///
  /// In en, this message translates to:
  /// **'Check for unclosed braces or other syntax errors.'**
  String get invalidTex;

  /// No description provided for @root.
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get root;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get fileName;

  /// No description provided for @invalidFileName.
  ///
  /// In en, this message translates to:
  /// **'Invalid file name'**
  String get invalidFileName;

  /// No description provided for @appStyleSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'ProTeX'**
  String get appStyleSettingsTitle;

  /// No description provided for @authorName.
  ///
  /// In en, this message translates to:
  /// **'Default author name'**
  String get authorName;

  /// No description provided for @defaultDocFontSize.
  ///
  /// In en, this message translates to:
  /// **'Default document font size'**
  String get defaultDocFontSize;

  /// No description provided for @whichPDFViewer.
  ///
  /// In en, this message translates to:
  /// **'Open PDFs with'**
  String get whichPDFViewer;

  /// No description provided for @sysDefaultPDF.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get sysDefaultPDF;

  /// No description provided for @internalPDF.
  ///
  /// In en, this message translates to:
  /// **'ProTeX PDF Viewer'**
  String get internalPDF;

  /// The title for the theme mode setting
  ///
  /// In en, this message translates to:
  /// **'App theme'**
  String get themeMode;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System theme'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get darkTheme;

  /// The title for the eye care setting
  ///
  /// In en, this message translates to:
  /// **'App color scheme'**
  String get colorMode;

  /// Set the seed color as the system's accent color
  ///
  /// In en, this message translates to:
  /// **'System color'**
  String get colorModeSystem;

  /// Set the seed color as the eye-safe color
  ///
  /// In en, this message translates to:
  /// **'Eye-safe'**
  String get colorModeEyeCare;

  /// No description provided for @texSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'TeX settings'**
  String get texSettingsTitle;

  /// No description provided for @texCompiler.
  ///
  /// In en, this message translates to:
  /// **'TeX compiler'**
  String get texCompiler;

  /// No description provided for @noneSelected.
  ///
  /// In en, this message translates to:
  /// **'None selected'**
  String get noneSelected;

  /// No description provided for @latex.
  ///
  /// In en, this message translates to:
  /// **'LaTeX'**
  String get latex;

  /// No description provided for @pdftex.
  ///
  /// In en, this message translates to:
  /// **'pdfTeX'**
  String get pdftex;

  /// No description provided for @xetex.
  ///
  /// In en, this message translates to:
  /// **'XeTeX'**
  String get xetex;

  /// No description provided for @lualatex.
  ///
  /// In en, this message translates to:
  /// **'LuaLaTeX'**
  String get lualatex;

  /// No description provided for @pythonSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Python settings'**
  String get pythonSettingsTitle;

  /// No description provided for @installTex.
  ///
  /// In en, this message translates to:
  /// **'Download TeXLive'**
  String get installTex;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @part.
  ///
  /// In en, this message translates to:
  /// **'Part'**
  String get part;

  /// No description provided for @chapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get chapter;

  /// No description provided for @section.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get section;

  /// No description provided for @subsection.
  ///
  /// In en, this message translates to:
  /// **'Subsection'**
  String get subsection;

  /// No description provided for @subsubsection.
  ///
  /// In en, this message translates to:
  /// **'Subsubsection'**
  String get subsubsection;

  /// No description provided for @bold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get bold;

  /// No description provided for @italic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get italic;

  /// No description provided for @underline.
  ///
  /// In en, this message translates to:
  /// **'Underline'**
  String get underline;

  /// No description provided for @emphasize.
  ///
  /// In en, this message translates to:
  /// **'Emphasize'**
  String get emphasize;

  /// No description provided for @unordered.
  ///
  /// In en, this message translates to:
  /// **'Unordered list'**
  String get unordered;

  /// No description provided for @ordered.
  ///
  /// In en, this message translates to:
  /// **'Ordered list'**
  String get ordered;

  /// No description provided for @listItem.
  ///
  /// In en, this message translates to:
  /// **'List item'**
  String get listItem;

  /// No description provided for @quote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get quote;

  /// No description provided for @bar.
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get bar;

  /// No description provided for @tilde.
  ///
  /// In en, this message translates to:
  /// **'Tilde'**
  String get tilde;

  /// No description provided for @citation.
  ///
  /// In en, this message translates to:
  /// **'Citation'**
  String get citation;

  /// No description provided for @equations.
  ///
  /// In en, this message translates to:
  /// **'Equation section'**
  String get equations;

  /// No description provided for @hat.
  ///
  /// In en, this message translates to:
  /// **'Hat'**
  String get hat;

  /// No description provided for @fraction.
  ///
  /// In en, this message translates to:
  /// **'Fraction'**
  String get fraction;

  /// No description provided for @bigFraction.
  ///
  /// In en, this message translates to:
  /// **'Big fraction'**
  String get bigFraction;

  /// No description provided for @chemForm.
  ///
  /// In en, this message translates to:
  /// **'Chemical formula'**
  String get chemForm;

  /// No description provided for @pyCode.
  ///
  /// In en, this message translates to:
  /// **'Python code'**
  String get pyCode;

  /// No description provided for @centerAlign.
  ///
  /// In en, this message translates to:
  /// **'Center align'**
  String get centerAlign;

  /// No description provided for @includeGraphics.
  ///
  /// In en, this message translates to:
  /// **'Include graphics'**
  String get includeGraphics;

  /// No description provided for @circuitSection.
  ///
  /// In en, this message translates to:
  /// **'CircuiTikz section'**
  String get circuitSection;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
