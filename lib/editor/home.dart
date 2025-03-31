import 'package:flutter/material.dart';
import 'package:protex/common/templates.dart';
import 'package:protex/editor/template_preview.dart';
import 'package:protex/l10n/app_localizations.dart';
import 'package:protex/main.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 8, bottom: 16),
          child: Text(
            AppLocalizations.of(context)!.homeTitle,
            style: Theme.of(context).textTheme.headlineMedium,)
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: width(context)/350 >= 1 ?(width(context)/350).toInt() : 1,
            mainAxisSpacing: 32,
            crossAxisSpacing: 16,
            childAspectRatio: 4/3,
            children: List.generate(
              Templates.allTemplates(context).length, 
              (int index) => TemplatePreview(template: Templates.allTemplates(context)[index])
            ),
          )
        )
      ],
    );
  }
}