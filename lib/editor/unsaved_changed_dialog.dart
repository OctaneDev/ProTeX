import 'package:flutter/material.dart';
import 'package:protex/common/colors.dart';
import 'package:protex/l10n/app_localizations.dart';

class UnsavedChangedDialog {
  const UnsavedChangedDialog({required this.context, required this.approveAction, required this.save});

  final BuildContext context;
  final VoidCallback save;
  final VoidCallback approveAction;

  Future<void> get showDialog async {
    await showAdaptiveDialog(
      context: context, 
      builder: (context) {
        return AlertDialog.adaptive(
          title: Text(AppLocalizations.of(context)!.unsavedChangesWarningTitle),
          content: Text(AppLocalizations.of(context)!.unsavedChangesWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text(AppLocalizations.of(context)!.cancel)
            ),
            TextButton(
              onPressed: save, 
              child: Text(AppLocalizations.of(context)!.save)
            ),
            TextButton(
              onPressed: approveAction, 
              child: Text(AppLocalizations.of(context)!.cont, style: TextStyle(color: AppColors.warning))
            ),
          ],
        );
      }
    );
  }
}