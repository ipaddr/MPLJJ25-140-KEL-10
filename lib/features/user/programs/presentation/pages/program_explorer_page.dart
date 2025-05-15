import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/features/user/programs/presentation/widgets/program_list_item_widget.dart';

class ProgramExplorerPage extends StatelessWidget {
  const ProgramExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder list of programs
    final List<Map<String, dynamic>> dummyPrograms = [
      {'name': 'Program Kesehatan Gratis', 'category': 'Kesehatan'},
      {'name': 'Beasiswa Pendidikan Anak', 'category': 'Pendidikan'},
      {'name': 'Modal Usaha Mikro', 'category': 'Modal Usaha'},
      {'name': 'Bantuan Pangan Keluarga', 'category': 'Makanan Pokok'},
      {'name': 'Program Kesehatan Ibu Hamil', 'category': 'Kesehatan'},
      {'name': 'Pelatihan Kewirausahaan', 'category': 'Modal Usaha'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eksplorasi Program'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter functionality
              // showDialog(
              //   context: context,
              //   builder: (context) => ProgramFilterDialogWidget(),
              // );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: dummyPrograms.length,
        itemBuilder: (context, index) {
          final program = dummyPrograms[index];
          return ProgramListItemWidget(
            programName: program['name'],
            programCategory: program['category'],
            // Add other required program details
            onTap: () {
              // Generate a programId for demonstration purposes
              final String programId = 'program-${index + 1}';

              // Navigate to program detail using GoRouter
              context.push(
                '/user/programs/$programId',
                extra: {
                  'isRecommended':
                      false, // Coming from explorer, not recommendations
                },
              );
            },
          );
        },
      ),
    );
  }
}
