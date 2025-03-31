import 'package:flutter/material.dart';

class MenuEntry {
  /// A [MenuEntry] item with a label to identify it to the user, an optional [MenuSerializableShortcut] for easy navigation, an optional [VoidCallback] to define what action is performed when it is pressed, and an optional [List] of [MenuEntry]s if it should display a submenu.
  const MenuEntry(this.label, {this.shortcut, this.onPressed, this.menuChildren})
    : assert(
      menuChildren == null || onPressed == null,
      "onPressed is ignored if menuChildren are provided"
    );

  /// A [String] value for the [MenuEntry] to identify itself to the user
  final String label;

  /// An optional [MenuSerializableShortcut] if a keyboard shortcut should be assigned to this item
  final MenuSerializableShortcut? shortcut;
  /// An optional [VoidCallback] if the [MenuEntry] should have a click event.
  /// 
  /// DO NOT use if [menuChildren] is used
  final VoidCallback? onPressed;
  /// An optional [List] of [MenuEntry]s to be displayed in a submenu.
  /// 
  /// DO NOT use if [onPressed] is used
  final List<MenuEntry>? menuChildren;

  /// Create a [List] of [Widget] for a given [MenuEntry]
  /// 
  /// If the [MenuEntry] has [menuChildren], a [SubmenuButton] [Widget] will be returned.
  /// 
  /// Otherwise, a [MenuItemButton] with the appropriate keyboard shortcut, click listener, and label will be returned.
  static List<Widget> build(List<MenuEntry> selections) {
    Widget buildSelection(MenuEntry selection) {
      if (selection.menuChildren != null) {
        return SubmenuButton(
          menuChildren: MenuEntry.build(selection.menuChildren!), 
          child: Text(selection.label)
        );
      }
      return MenuItemButton(
        shortcut: selection.shortcut,
        onPressed: selection.onPressed,
        child: Text(selection.label),
      );
    }

    return selections.map<Widget>(buildSelection).toList();
  }

  /// Get a list of keyboard shortcuts to activate
  static Map<MenuSerializableShortcut, Intent> shortcuts(List<MenuEntry> selections) {
    final Map<MenuSerializableShortcut, Intent> result = <MenuSerializableShortcut, Intent>{};
    for (final MenuEntry selection in selections) {
      if (selection.menuChildren != null) {
        result.addAll(MenuEntry.shortcuts(selection.menuChildren!));
      } else {
        if (selection.shortcut != null && selection.onPressed != null) {
          result[selection.shortcut!] = VoidCallbackIntent(selection.onPressed!);
        }
      }
    }

    return result;
  }
}