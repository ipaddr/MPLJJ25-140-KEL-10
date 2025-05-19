import 'package:flutter/material.dart';
import 'package:socio_care/features/user/education/widgets/education_detail_widget.dart';

class EducationDetailPage extends StatelessWidget {
  final String articleId;
  final String title;
  final String content;

  const EducationDetailPage({
    super.key,
    required this.articleId,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail Edukasi",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Container(
        // Add this to make the container fill the available space
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: EducationDetailViewWidget(
              articleId: articleId,
              title: title,
              content: content,
            ),
          ),
        ),
      ),
    );
  }
}
