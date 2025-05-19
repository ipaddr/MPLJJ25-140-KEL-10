import 'package:flutter/material.dart';

class EducationDetailViewWidget extends StatelessWidget {
  final String title;
  final String content;

  const EducationDetailViewWidget({
    super.key,
    required this.title,
    required this.content,
    required String articleId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16.0),
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
          // You might want to add images or other rich content here later
        ],
      ),
    );
  }
}
