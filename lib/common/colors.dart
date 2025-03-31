import 'package:flutter/material.dart';
import 'package:protex/editor/template_preview.dart';

class AppColors {
  /// To provide a visual warning to the user that an action could cause data loss and should be carefully considered
  static Color warning = Color(0xFFD91313);

  /// The background color for the [TemplatePreview] card
  static Color templateBackground = Color(0xFFd3d3d3);

  /// The text color for the [TemplatePreview] card on the [templateBackground]
  static Color templateText = Color(0xFF1d1d1d);

  static Color muted(BuildContext context) => Theme.of(context).colorScheme.onSurface.withAlpha(0x99);
}