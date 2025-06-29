import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:protex/common/colors.dart';
import 'package:protex/document/document.dart';
import 'package:protex/l10n/app_localizations.dart';
import 'package:protex/main.dart';

class ItemEditor extends StatefulWidget {
  /// A [Document] viewer and editor that fills the available space
  const ItemEditor(this.document, {super.key});

  /// The [Document] for the widget to modify
  final Document document;

  @override
  State<ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends State<ItemEditor> {
  final TextEditingController controller = TextEditingController();

  List<String> _shorts() => List.generate(shortcuts.length, (index) => shortcuts[index].shortCut);
  late final List<String> shorts = _shorts();

  bool _valid = true;

  int count(String value, String search) {
    int count = 0;
    value.splitMapJoin(search, onMatch: (m) {
      count++;
      return "";
    });
    return count;
  }

  late FocusNode node;

  @override
  void initState() {
    super.initState();
    widget.document.addListener(() {
      setState(() {
        if (widget.document.hasFocus) {
          node.requestFocus();
        }
        controller.selection = TextSelection.collapsed(offset: widget.document.cursorPosition);
      });
    });
    node = FocusNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
          log("caught");
          node.requestFocus();
          setState(() {
            widget.document.contents = "${widget.document.contents.substring(0, controller.selection.base.offset)}  ${widget.document.contents.substring(controller.selection.base.offset)}";
            widget.document.setCursorPosition(controller.selection.base.offset+2);
          });
          node.requestFocus();
          return KeyEventResult.handled;
        } else if (event is KeyDownEvent && (event.logicalKey == LogicalKeyboardKey.parenthesisLeft || event.logicalKey == LogicalKeyboardKey.bracketLeft || event.logicalKey == LogicalKeyboardKey.quote || event.logicalKey == LogicalKeyboardKey.quoteSingle || event.logicalKey == LogicalKeyboardKey.braceLeft)) {
          List<String> replacement = [];
          if (event.logicalKey == LogicalKeyboardKey.parenthesisLeft) {
            replacement = ["(", ")"];
          } else if (event.logicalKey == LogicalKeyboardKey.bracketLeft) {
            replacement = ["[", "]"];
          } else if (event.logicalKey == LogicalKeyboardKey.quote) {
            replacement = ['"', '"'];
          } else if (event.logicalKey == LogicalKeyboardKey.quoteSingle) {
            replacement = ["'", "'"];
          } else if (event.logicalKey == LogicalKeyboardKey.braceLeft) {
            replacement = ["{", "}"];
          }
          setState(() {
            widget.document.contents = "${widget.document.contents.substring(0, controller.selection.start)}${replacement.first}${widget.document.contents.substring(controller.selection.start, controller.selection.end)}${replacement.last}${widget.document.contents.substring(controller.selection.end)}";
            widget.document.setCursorPosition(controller.selection.end+2);
          });
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      }
    );
    node.addListener(() {
      if (node.hasFocus) {
        setState(() {
          widget.document.setCursorPosition(controller.selection.base.offset);
        });
      }
    });
  }

  @override
  void dispose() {
    node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Document document = widget.document;
    controller.text = document.contents;
    try {
      controller.selection = TextSelection.collapsed(offset: document.cursorPosition);
    } catch (e) {
      log("failed to move cursor", error: e);
    }

    if (document.selection != null) {
      controller.selection = document.selection!;
    }

    return SafeArea(
      //minimum: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
      child: TextField(
        key: widget.key,
        focusNode: node,
        controller: controller,
        selectionControls: DesktopTextSelectionControls(),
        maxLines: null,
        expands: true,
        autofocus: document.hasFocus,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          errorBorder: _valid ? null : OutlineInputBorder(borderSide: BorderSide(color: AppColors.warning)),
          errorText: _valid ? null : AppLocalizations.of(context)!.invalidTex,
        ),
        style: TextStyle(
          fontFamily: 'SourceCodePro',
          fontWeight: FontWeight.w600
        ),
        onChanged: (value) {
           if ((count(value, "<py>") != count(value, "</py>")) || 
              (count(value, r"\begin") != count(value, r"\end")) || 
              ((count(value, r"{") - count(value, r"\{")) != (count(value, r"}") - count(value, r"\}"))) || 
              ((count(value, r"[") - count(value, r"\[")) != (count(value, r"]") - count(value, r"\]"))) || 
              ((count(value, r"$") - count(value, r"\$")) != (count(value, r"$") - count(value, r"\$")))) {
              setState(() {
                _valid = false;
                document.setCursorPosition(controller.selection.base.offset);
              });
            } else {
              setState(() {
                _valid = true;
                document.setCursorPosition(controller.selection.base.offset);
              });
            }
            for (String shortcut in shorts) {
              if (value.contains(shortcut)) {
                String replacement = shortcuts[shorts.indexOf(shortcut)].fullValue;
                int offset() {
                  if (replacement.contains(r"{}{}")) {
                    return replacement.length-3;
                  } else if (replacement.contains(r"{}")) {
                    return replacement.length-1;
                  } else if (replacement.contains("\\begin")) {
                    List<String> segments = replacement.split("\n");
                    int skip = -1;
                    if (segments[1].contains(r"\item")) {
                      skip -= 6;
                    } else if (segments[0].contains(r"[american]")) {
                      skip -= 10;
                    } 
                    for (int i = 0; i < segments.length-1; i++) {
                      skip += segments[i].length;
                    }
                    return replacement.length-skip;
                  } else if (replacement.contains(r"<py>")) {
                    return replacement.length-6;
                  }
                  return replacement.length;
                }
                setState(() {
                  value = value.replaceAll(shortcut, replacement);
                  document.setCursorPosition(controller.selection.base.offset-shortcut.length+offset());
                }
              ); 
            }
          }
          if (document.saved) {
            document.documentChanged();
          }
          document.setCursorPosition(controller.selection.base.offset);
          document.setSelection(controller.selection);
          document.contents = value;
          node.requestFocus();
        },
        /*contextMenuBuilder: (context, editableTextState) {
          // TODO implement context menu
        }*/
      )
    );
  }
}