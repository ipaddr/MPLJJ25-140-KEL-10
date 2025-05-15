import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/features/user/core_user/presentation/widgets/user_bottom_navigation_bar.dart';

class EducationListPage extends StatelessWidget {
  const EducationListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> educationItems = [
      {
        'image': 'assets/images/education.png', // Replace with your image paths
        'title': 'Tips Mengelola Keuangan Pribadi',
        'subtitle':
            'Pelajari cara membuat anggaran, menabung, dan berinvestasi untuk masa depan.',
      },
      {
        'image': 'assets/images/education.png',
        'title': 'Memulai Usaha Kecil: Panduan Lengkap',
        'subtitle':
            'Langkah-langkah penting untuk memulai dan mengembangkan UMKM Anda.',
      },
      {
        'image': 'assets/images/education.png',
        'title': 'Memahami Jenis-jenis Bantuan Sosial',
        'subtitle':
            'Informasi mengenai berbagai program bantuan sosial yang tersedia.',
      },
      // Add more education items here
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edukasi", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: educationItems.length, // Use the actual item count
        itemBuilder: (context, index) {
          final item = educationItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              leading: Image.asset(item['image']!, width: 50, height: 50),
              title: Text(item['title']!),
              subtitle: Text(item['subtitle']!),
              onTap: () {
                // Replace this TODO and print statement
                final String articleId =
                    'article-${index + 1}'; // Generate unique ID

                // You can create more detailed content here
                final String detailedContent = '''
                ${item['subtitle']}
  
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
                ''';

                context.push(
                  '/user/education/$articleId',
                  extra: {'title': item['title'], 'content': detailedContent},
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const UserBottomNavigationBar(
        selectedIndex: 2, // Education is the third item
      ),
    );
  }
}
