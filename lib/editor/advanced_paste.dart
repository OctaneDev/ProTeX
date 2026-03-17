import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:html_to_tex/html_to_tex.dart';
import 'package:protex/document/document.dart';
import 'package:protex/l10n/app_localizations.dart';
import 'package:protex/main.dart';

class AdvancedPaste extends StatefulWidget {
  const AdvancedPaste({super.key, required this.doc});

  final Document doc;

  @override
  State<AdvancedPaste> createState() => _AdvancedPasteState();
}

class _AdvancedPasteState extends State<AdvancedPaste> {
  Document get doc => widget.doc;
  bool isHTML = true;

  TextEditingController inputController = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(l10n.advancedPaste),
      content: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.advancedPasteTooltip),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isHTML ? l10n.htmlPaste : l10n.mdPaste),
                Switch(
                  value: isHTML, 
                  onChanged: (bool val) {
                    setState(() {
                      isHTML = val;
                    });
                  }
                )
              ]
            ),
            SizedBox(
              height: height(context)/2,
              child: TextField(
                maxLines: null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: isHTML ? l10n.htmlPasteHint : l10n.mdPasteHint
                ),
                controller: inputController,
                scrollController: scrollController,
              )
            )
          ],
        )
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            String pasteData;
            if (isHTML) {
              pasteData = HtmlToLatex().convert(inputController.text);
            } else {
              pasteData = MarkdownToLatex().convert(inputController.text);
            }
            log(pasteData);
            doc.insertTextAtCursor(pasteData);
          }, 
          child: Text(AppLocalizations.of(context)!.cont)
        )
      ],
    );
  }
}