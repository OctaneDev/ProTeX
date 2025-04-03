// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ProTeX';

  @override
  String get ok => 'Okay';

  @override
  String get cont => 'Continue';

  @override
  String get cancel => 'Cancel';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get copied => 'Copied to clipboard';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get quit => 'Quit';

  @override
  String get file => 'File';

  @override
  String get newDoc => 'New document';

  @override
  String get newTab => 'New tab';

  @override
  String get open => 'Open';

  @override
  String get save => 'Save';

  @override
  String get saveAs => 'Save as...';

  @override
  String get export => 'Export...';

  @override
  String get build => 'Build PDF';

  @override
  String get close => 'Close document';

  @override
  String get edit => 'Edit';

  @override
  String get prefs => 'Preferences';

  @override
  String get find => 'Find...';

  @override
  String get replace => 'Replace';

  @override
  String get go => 'Go';

  @override
  String get cacheLocation => 'Cache folder';

  @override
  String get tempLocation => 'Temp folder';

  @override
  String get view => 'View';

  @override
  String get showShortcuts => 'Show shortcuts';

  @override
  String get findReplace => 'Find and replace';

  @override
  String get replaceAll => 'Replace all';

  @override
  String get findNext => 'Find next';

  @override
  String get findPrev => 'Find previous';

  @override
  String get statusReady => 'Status: ready';

  @override
  String get homeTitle => 'Get started';

  @override
  String get emptyTemp => 'Empty Document';

  @override
  String get minArticleTitle => 'Basic article';

  @override
  String minArticleContents(String fontSize, String name, String docSize) {
    return '\\documentclass[$fontSize]{article}\n\\usepackage[utf8]{inputenc}\n\\usepackage[${docSize}margin=1in]{geometry}\n\\author{$name}\n\\title{Blank article}\n\\date{\\today}\n\\begin{document}\n\\maketitle\n\\end{document}';
  }

  @override
  String get minReportTitle => 'Basic report';

  @override
  String minReportContents(String fontSize, String name, String docSize) {
    return '\\documentclass[$fontSize]{report}\n\\usepackage[utf8]{inputenc}\n\\usepackage[${docSize}margin=1in]{geometry}\n\\author{$name}\n\\title{Blank report}\n\\date{\\today}\n\\begin{document}\n\\maketitle\n\\tableofcontents\n\\end{document}';
  }

  @override
  String get minBookTitle => 'Basic book';

  @override
  String minBookContents(String fontSize, String name, String docSize) {
    return '\\documentclass[$fontSize]{book}\n\\usepackage[utf8]{inputenc}\n\\usepackage[${docSize}margin=1in]{geometry}\n\\author{$name}\n\\title{Blank book}\n\\date{\\today}\n\\begin{document}\n\\frontmatter\n\\maketitle\n\\tableofcontents\n\\chapter{Preface}\n\\mainmatter\n\\chapter{First chapter}\n\\appendix\n\\chapter{Appendix}\n\\backmatter\n\\chapter{Final note}\n\\end{document}';
  }

  @override
  String get unsavedChangesWarningTitle => 'Warning: unsaved changes';

  @override
  String get unsavedChangesWarning => 'This document has unsaved changes that will be lost if you continue.';

  @override
  String get oldFileWarningTitle => 'Warning: document missing features';

  @override
  String oldFileWarning(String file) {
    return 'The document you ($file) selected does not support all the features of this app. If you save changes to this file, it will no longer be compatible with other TeX editors.';
  }

  @override
  String get compileErrorDialogTitle => 'Failed to compile';

  @override
  String get pythonNotFoundException => 'An acceptable version of Python was not found on your computer. Please make sure you have Python 3.x installed and that the binary\'s directory is in your system\'s PATH.';

  @override
  String get compileFailedException => 'The selected TeX compiler failed to process your document.';

  @override
  String get biberFailedException => 'Biber failed to process your document. Please ensure that it is installed and can be called as \"biber\" from your system\'s shell.';

  @override
  String openPdfException(String file) {
    return 'Failed to launch file $file.';
  }

  @override
  String get stoppedEarly => 'PDF build stopped early.';

  @override
  String get invalidTex => 'Check for unclosed braces or other syntax errors.';

  @override
  String get root => 'Root';

  @override
  String get home => 'Home';

  @override
  String get documents => 'Documents';

  @override
  String get fileName => 'File name';

  @override
  String get invalidFileName => 'Invalid file name';

  @override
  String get appStyleSettingsTitle => 'ProTeX';

  @override
  String get authorName => 'Default author name';

  @override
  String get defaultDocFontSize => 'Default document font size';

  @override
  String get defaultDocSize => 'Default document size';

  @override
  String get whichPDFViewer => 'Open PDFs with';

  @override
  String get sysDefaultPDF => 'System default';

  @override
  String get internalPDF => 'ProTeX PDF Viewer';

  @override
  String get themeMode => 'App theme';

  @override
  String get systemTheme => 'System theme';

  @override
  String get lightTheme => 'Light theme';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get colorMode => 'App color scheme';

  @override
  String get colorModeSystem => 'System color';

  @override
  String get colorModeEyeCare => 'Eye-safe';

  @override
  String get texSettingsTitle => 'TeX settings';

  @override
  String get texCompiler => 'TeX compiler';

  @override
  String get noneSelected => 'None selected';

  @override
  String get latex => 'LaTeX';

  @override
  String get pdftex => 'pdfTeX';

  @override
  String get xetex => 'XeTeX';

  @override
  String get lualatex => 'LuaLaTeX';

  @override
  String get pythonSettingsTitle => 'Python settings';

  @override
  String get installTex => 'Download TeXLive';

  @override
  String get title => 'Title';

  @override
  String get part => 'Part';

  @override
  String get chapter => 'Chapter';

  @override
  String get section => 'Section';

  @override
  String get subsection => 'Subsection';

  @override
  String get subsubsection => 'Subsubsection';

  @override
  String get bold => 'Bold';

  @override
  String get italic => 'Italic';

  @override
  String get underline => 'Underline';

  @override
  String get emphasize => 'Emphasize';

  @override
  String get unordered => 'Unordered list';

  @override
  String get ordered => 'Ordered list';

  @override
  String get listItem => 'List item';

  @override
  String get quote => 'Quote';

  @override
  String get bar => 'Bar';

  @override
  String get tilde => 'Tilde';

  @override
  String get citation => 'Citation';

  @override
  String get equations => 'Equation section';

  @override
  String get hat => 'Hat';

  @override
  String get fraction => 'Fraction';

  @override
  String get bigFraction => 'Big fraction';

  @override
  String get chemForm => 'Chemical formula';

  @override
  String get pyCode => 'Python code';

  @override
  String get centerAlign => 'Center align';

  @override
  String get includeGraphics => 'Include graphics';

  @override
  String get circuitSection => 'CircuiTikz section';
}
