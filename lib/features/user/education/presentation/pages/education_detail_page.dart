import 'package:flutter/material.dart';
import 'package:socio_care/features/user/education/widgets/education_detail_widget.dart'; // Assuming the widget is here

class EducationDetailPage extends StatelessWidget {
  final String articleId; // Or use slug, depending on your routing

  const EducationDetailPage({
    Key? key,
    required this.articleId,
    required title,
    required content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Edukasi')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: EducationDetailViewWidget(
            articleId: articleId,
            title: '',
            content: '',
          ),
        ),
      ),
    );
  }
}
