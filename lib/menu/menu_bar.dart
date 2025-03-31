
import 'package:flutter/material.dart';
import 'package:protex/main.dart';
import 'package:protex/menu/menu_entry.dart';

class CompleteMenuBar extends StatefulWidget {
  const CompleteMenuBar(this.entries, {super.key});

  final List<MenuEntry> entries;

  @override
  State<CompleteMenuBar> createState() => _CompleteMenuBarState();
}

class _CompleteMenuBarState extends State<CompleteMenuBar> {

  @override
  Widget build(BuildContext context) {
    final List<MenuEntry> entries = widget.entries;

    return SizedBox(
      width: width(context),
      child: MenuBar(
        children: MenuEntry.build(entries)
      )
    );
  }
}