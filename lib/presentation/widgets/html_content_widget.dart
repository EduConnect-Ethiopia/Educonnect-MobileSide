import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class HtmlContentWidget extends StatelessWidget {
  const HtmlContentWidget({required this.htmlContent, super.key});

  final String htmlContent;

  @override
  Widget build(BuildContext context) {
    if (htmlContent.trim().isEmpty) {
      return const Text('No content available for this lesson.');
    }

    return HtmlWidget(
      htmlContent,
      textStyle: Theme.of(context).textTheme.bodyLarge,
    );
  }
}
