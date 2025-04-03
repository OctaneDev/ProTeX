import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:protex/document/document.dart';
import 'package:protex/l10n/app_localizations.dart';

class FindReplaceBar extends StatelessWidget {
  const FindReplaceBar({super.key, required this.document, required this.findController, required this.replaceController, required this.findFocusNode, required this.replace, required this.replaceFocusNode});

  /// The [Document] for the widget to modify
  final Document document;
  /// The [TextEditingController] for the find text field
  final TextEditingController findController;
  /// The [TextEditingController] for the replace text field
  final TextEditingController replaceController;
  /// The [FocusNode] for the document text field
  final FocusNode findFocusNode;
  /// The [FocusNode] for the replace text field
  final FocusNode replaceFocusNode;
  /// Whether to replace the text in the document
  /// 
  /// If true, the replace text field will be shown.
  /// If false, the replace text field will be hidden.
  /// If the replace text field is hidden, the find text field will be expanded
  /// to fill the available space.
  /// If the replace text field is shown, the find text field will be shrunk
  /// to make room for the replace text field.
  final bool replace;

  void findMe(String search, {bool prev = false}) {
    if (search.isEmpty) {
      return;
    }

    int start = 0;
    if (start == -1) {
      start = 0;
    }

    int selectionIndex = 0;

    final List<TextSelection> selections = [];

    for (int i = 0; i < document.contents.split(search).length; i++) {
      TextSelection selection = TextSelection(baseOffset: document.contents.indexOf(search, start) != -1 ? document.contents.indexOf(search, start) : 0, extentOffset: document.contents.indexOf(search, start) != -1 ? document.contents.indexOf(search, start) + search.length : 0);

      if (!selection.isCollapsed) {
        selections.add(selection);
      }
      start = document.contents.indexOf(search, start) + search.length;
      if (start == -1) {
        break;
      }
    }

    if (prev) {
      if (document.selection != null && selections.contains(document.selection)) {
        selectionIndex = selections.indexOf(document.selection!) - 1;
      }
      try {
        document.setSelection(selectionIndex < 0 ? selections.last : selections[selectionIndex]);
        document.setCursorPosition(document.contents.indexOf(search, start) != -1 ? document.contents.indexOf(search, start) + search.length : 0);
        selectionIndex <= 0 ? selectionIndex = selections.length-1 : selectionIndex--;
      } catch (e) {
        log("findMe error: $e");
        document.setSelection(
          selections.first,
        );
        document.setCursorPosition(0);
      }
    } else {
      if (document.selection != null && selections.contains(document.selection)) {
        selectionIndex = selections.indexOf(document.selection!) + 1;
      }
      try {
        document.setSelection(selectionIndex < selections.length ? selections[selectionIndex] : selections[0]);
        selectionIndex >= selections.length ? selectionIndex = 0 : selectionIndex++;
      } catch (e) {
        log("findMe error: $e");
        document.setSelection(
          selections.last,
        );
      }      
    }
  }

  void replaceMe(String search, {bool all = false}) {
    if (search.isEmpty) {
      return;
    } else if (all) {
      document.contents = document.contents.replaceAll(search, replaceController.text);
    } else {
      document.contents = document.contents.replaceFirstMapped(search, (m) => replaceController.text, document.selection!.baseOffset);
      document.setSelection(
        TextSelection(
          baseOffset: document.contents.indexOf(replaceController.text),
          extentOffset: document.contents.indexOf(replaceController.text) + replaceController.text.length,
        ),
      );
    }
    document.setSelection(
      TextSelection(
        baseOffset: document.contents.indexOf(search),
        extentOffset: document.contents.indexOf(search) + search.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextField(
            controller: findController,
            focusNode: findFocusNode,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.find,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              document.removeFocus();
              document.setSelection(
                TextSelection(
                  baseOffset: document.contents.indexOf(value),
                  extentOffset: document.contents.indexOf(value) + value.length,
                ),
              );
              document.setCursorPosition(document.cursorPosition + value.length);
            },
            onSubmitted: (value) {
              if (!replace) {
                document.giveFocus();
                findMe(value);
              } else {
                findFocusNode.unfocus();
                replaceFocusNode.requestFocus();
              }
              
            },
          ),
        ),
        const SizedBox(width: 8),
        if (replace) Expanded(
          child: TextField(
            controller: replaceController,
            focusNode: replaceFocusNode,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.replace,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) => document.removeFocus(),
          ),
        ),
        if (replace) const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            findController.clear();
            replaceController.clear();
          },
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: replace ? () {
            document.giveFocus();
            replaceMe(findController.text, all: true);
          } : () {
            document.giveFocus();
            findMe(findController.text, prev: true);
          }, 
          child: Text(replace ? AppLocalizations.of(context)!.replaceAll : AppLocalizations.of(context)!.findPrev),
        ),
        TextButton(
          onPressed: replace ? () {
            document.giveFocus();
            replaceMe(findController.text);
          } : () {
            document.giveFocus();
            findMe(findController.text);
          }, 
          child: Text(replace ? AppLocalizations.of(context)!.replace : AppLocalizations.of(context)!.findNext)
        ),
        if (replace) TextButton(
          onPressed: () {
            document.giveFocus();
            findMe(findController.text);
          }, 
          child: Text(AppLocalizations.of(context)!.findNext)
        ),
      ],
    );
  }
}