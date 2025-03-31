import 'package:flutter/material.dart';
import 'package:protex/common/colors.dart';
import 'package:protex/document/document.dart';
import 'package:protex/main.dart';

class TemplatePreview extends StatelessWidget {
  const TemplatePreview({super.key, required this.template});

  final Document template;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: key,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => openDocs.add(template),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: TextField(
                enabled: false,
                readOnly: true,
                scrollPhysics: NeverScrollableScrollPhysics(),
                controller: TextEditingController(text: template.contents),
                decoration: InputDecoration(filled: true, fillColor: AppColors.templateBackground),
                minLines: 16,
                maxLines: 16,
                style: TextStyle(color: AppColors.templateText, fontFamily: 'SourceCodePro', fontWeight: FontWeight.w600),
              )
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Text(template.title, style: Theme.of(context).textTheme.headlineSmall,),
            )
          ],
        ),
      )
    );
  }
}