import 'package:flutter/material.dart';
import 'package:protex/common/colors.dart';

class SettingsItem extends StatelessWidget {

  /// The left-most widget, usually a [Text] item. 
  /// 
  /// Optional
  final Widget leading;
  /// The right-most widget, usually the field for changing the setting, itself. 
  /// 
  /// Optional
  final Widget? trailing;
  /// Should anything be done when the user taps on the list item? If yes, that goes here. 
  /// 
  /// Optional
  final void Function()? onTap;

  /// A custom ListTile framework for individual settings
  const SettingsItem({super.key, this.trailing, required this.leading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: key,
      title: leading,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class ListSectionTitle extends StatelessWidget {
  final String title;

  const ListSectionTitle(this.title, {super.key});
  
  @override
  Widget build(BuildContext context) {
    return Text(
      key: key,
      title,
      style: TextStyle(
        fontSize: 16,
        color: AppColors.muted(context)
      ),
    );
  }
}

class ListItemTitle extends StatelessWidget {
  final String title;

  const ListItemTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      key: key,
      title,
      style: TextStyle(
        fontSize: 18
      ),
    );
  }
}