import 'package:flutter/material.dart';
import 'package:protex/main.dart';
import 'package:protex/settings/settings_item.dart';
import 'package:protex/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget { // TODO add support for Python virtual environments
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) { // TODO add encryption, etc. metadata support
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          SettingsItem(
            leading: ListSectionTitle(AppLocalizations.of(context)!.appStyleSettingsTitle)
          ),
          SettingsItem(
            leading: ListItemTitle(AppLocalizations.of(context)!.authorName),
            trailing: SizedBox(
              width: width(context) > 250 ? 200 : width(context)/3, 
              child: TextField(
                controller: TextEditingController(text: controller.authorName),
                textAlign: TextAlign.end,
                onChanged: (value) => controller.updateAuthorName(value),
                onTapUpOutside: (event) => controller.notifyAuthorName(),
              )
            ),
          ),
          /*SettingsItem(
            leading: Text(AppLocalizations.of(context)!.whichPDFViewer),
            trailing: DropdownButton<bool>(
              value: controller.internalPDF,
              items: [
                DropdownMenuItem(
                  value: false,
                  child: Text(AppLocalizations.of(context)!.sysDefaultPDF)
                ),
                DropdownMenuItem(
                  value: true,
                  child: Text(AppLocalizations.of(context)!.internalPDF)
                ),
              ], onChanged: controller.updatePDFViewer),
          ),*/
          SettingsItem(
            leading: ListItemTitle(AppLocalizations.of(context)!.themeMode),
            trailing: DropdownButton<ThemeMode>(
              value: controller.themeMode,
              onChanged: controller.updateThemeMode,
              padding: EdgeInsets.symmetric(horizontal: 12),
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(AppLocalizations.of(context)!.systemTheme),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(AppLocalizations.of(context)!.lightTheme),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(AppLocalizations.of(context)!.darkTheme),
                )
              ],
            ),
          ),
          SettingsItem(
            leading: ListItemTitle(AppLocalizations.of(context)!.colorMode),
            trailing: DropdownButton<bool>(
              value: controller.eyeCare,
              onChanged: controller.updateeyeCare, 
              padding: EdgeInsets.symmetric(horizontal: 12),
              items: [
                DropdownMenuItem(
                  value: false,
                  child: Text(AppLocalizations.of(context)!.colorModeSystem)
                ),
                DropdownMenuItem(
                  value: true,
                  child: Text(AppLocalizations.of(context)!.colorModeEyeCare)
                ),
              ]
            ),
          ),
          Divider(),
          SettingsItem(
            leading: ListSectionTitle(
              AppLocalizations.of(context)!.texSettingsTitle
            )
          ),
          SettingsItem(
            leading: ListItemTitle(AppLocalizations.of(context)!.defaultDocFontSize),
            trailing: DropdownButton<String>(
              value: controller.defDocFont,
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem(value: "10pt", child: Text("10pt")),
                DropdownMenuItem(value: "11pt", child: Text("11pt")),
                DropdownMenuItem(value: "12pt", child: Text("12pt")),
              ], 
              onChanged: controller.updateDocFont
            ),
          ),
          SettingsItem(
            leading: ListItemTitle(AppLocalizations.of(context)!.defaultDocSize),
            trailing: DropdownButton<String>(
              value: controller.docSize,
              items: List.generate(controller.docSizes.length, (index) {
                String key = controller.docSizes.keys.elementAt(index);
                String value = controller.docSizes[key]!;

                return DropdownMenuItem(
                  value: key,
                  child: Text(value)
                );
              }), 
              onChanged: (value) {
                if (value != null) {
                  controller.updateDocSize(value);
                } else {
                  controller.updateDocSize("none");
                }
              }
            ),
          ),
          SettingsItem(
            leading: ListItemTitle(AppLocalizations.of(context)!.texCompiler),
            trailing: DropdownButton(
              value: controller.texCompiler,
              padding: EdgeInsets.symmetric(horizontal: 12),
              items: <DropdownMenuItem<String>>[
                /*DropdownMenuItem(
                  value: AppLocalizations.of(context)!.noneSelected,
                  child: Text(AppLocalizations.of(context)!.noneSelected)
                ),*/
                DropdownMenuItem(
                  value: AppLocalizations.of(context)!.latex,
                  child: Text(AppLocalizations.of(context)!.latex)
                ),
                DropdownMenuItem(
                  value: AppLocalizations.of(context)!.pdftex,
                  child: Text(AppLocalizations.of(context)!.pdftex)
                ),
                DropdownMenuItem(
                  value: AppLocalizations.of(context)!.lualatex,
                  child: Text(AppLocalizations.of(context)!.lualatex)
                ),
                DropdownMenuItem(
                  value: AppLocalizations.of(context)!.xetex,
                  child: Text(AppLocalizations.of(context)!.xetex)
                ),
              ], 
              onChanged: controller.updateTexCompiler
            ),
          ),
          SettingsItem(
            leading: ListItemTitle(AppLocalizations.of(context)!.installTex),
            trailing: IconButton(
              onPressed: () async => await launchUrl(Uri.parse("https://www.tug.org/texlive/")), 
              icon: Icon(Icons.open_in_new)
            ),
          ),
          /*Divider(),
          SettingsItem(
            leading: ListSectionTitle(
              AppLocalizations.of(context)!.pythonSettingsTitle
            )
          ),*/
        ]
      ),
    );
  }
}
