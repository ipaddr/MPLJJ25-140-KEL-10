import 'package:flutter/material.dart';

class ProgramDetailPage extends StatelessWidget {
  final String programId; // Or use a slug
  final bool isRecommended;

  const ProgramDetailPage({
    super.key,
    required this.programId,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
        title: const Text(
          "Detail Program",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
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
        child: SingleChildScrollView(
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
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Konfirmasi Pengajuan'),
                            content: const Text(
                              'Apakah Anda yakin ingin mengajukan program ini? '
                              'Pastikan data pribadi Anda sudah lengkap dan benar.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Pengajuan berhasil dikirim!'),
                                    ),
                                  );
                                },
                                child: const Text('Ajukan'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text("Ajukan Sekarang"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}