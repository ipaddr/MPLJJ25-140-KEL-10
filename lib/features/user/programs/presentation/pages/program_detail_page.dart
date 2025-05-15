import 'package:flutter/material.dart';

class ProgramDetailPage extends StatelessWidget {
  final String programId; // Or use a slug
  final bool isRecommended;

  const ProgramDetailPage({
    Key? key,
    required this.programId,
    this.isRecommended = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Implement fetching program details based on programId
    // TODO: Use BlocBuilder or CubitBuilder to handle loading, success, and error states

    // Placeholder data for demonstration
    const String programTitle = "Nama Program Bantuan";
    const String programDescription =
        "Ini adalah deskripsi lengkap dari program bantuan. Ini menjelaskan tujuan program, siapa yang memenuhi syarat, dan apa yang diberikannya.";
    const String termsAndConditions =
        "Syarat & Ketentuan:\n- Warga negara Indonesia.\n- Berusia minimal 18 tahun.\n- Memenuhi kriteria pendapatan tertentu.\n- Dokumen yang dibutuhkan: KTP, Kartu Keluarga, dll.";
    const String howToRegister =
        "Cara Pendaftaran:\n1. Kunjungi situs web resmi atau kantor terkait.\n2. Isi formulir pendaftaran.\n3. Lampirkan dokumen yang diperlukan.\n4. Tunggu proses verifikasi.";
    const String submissionStatus =
        "Status Pengajuan: Belum Diajukan"; // Example: Diproses, Disetujui, Ditolak

    return Scaffold(
      appBar: AppBar(title: const Text("Detail Program")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              programTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Deskripsi Program:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(programDescription, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text(
              "Syarat & Ketentuan:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(termsAndConditions, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text(
              "Cara Pendaftaran:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(howToRegister, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text(
              "Status Pengajuan:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(submissionStatus, style: const TextStyle(fontSize: 16)),
            if (isRecommended) // Conditionally display based on isRecommended
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement logic to initiate program application
                  },
                  child: const Text("Ajukan Sekarang"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
