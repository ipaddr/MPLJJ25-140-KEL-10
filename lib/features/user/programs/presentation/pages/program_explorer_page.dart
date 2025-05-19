import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(RouteNames.userDashboard);
          },
        ),
        title: const Text(
          "Eksplorasi Program",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Filter Program'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Pilih kategori program:'),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            children: [
                              FilterChip(
                                label: const Text('Kesehatan'),
                                onSelected: (selected) {
                                  // Filter logic would go here
                                  Navigator.pop(context);
                                },
                              ),
                              FilterChip(
                                label: const Text('Pendidikan'),
                                onSelected: (selected) {
                                  // Filter logic would go here
                                  Navigator.pop(context);
                                },
                              ),
                              FilterChip(
                                label: const Text('Modal Usaha'),
                                onSelected: (selected) {
                                  // Filter logic would go here
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
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
      ),
    );
  }
}
