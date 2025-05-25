import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import '../widgets/recommendation_card_widget.dart';

class MyRecommendationsPage extends StatefulWidget {
  const MyRecommendationsPage({super.key});

  @override
  State<MyRecommendationsPage> createState() => _MyRecommendationsPageState();
}

class _MyRecommendationsPageState extends State<MyRecommendationsPage> {
  User? _currentUser;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _recommendedPrograms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      _currentUser = FirebaseAuth.instance.currentUser;

      if (_currentUser == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .get();

      if (userDoc.exists) {
        _userData = userDoc.data();
      }

      await _generateRecommendations();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading recommendations: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generateRecommendations() async {
    try {
      final programsQuery =
          await FirebaseFirestore.instance
              .collection('programs')
              .where('status', isEqualTo: 'active')
              .limit(10)
              .get();

      if (programsQuery.docs.isEmpty) {
        if (mounted) {
          setState(() {
            _recommendedPrograms = [];
          });
        }
        return;
      }

      List<Map<String, dynamic>> programs =
          programsQuery.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

      // Simple recommendation based on popularity
      _recommendedPrograms =
          programs.map((program) {
            program['reason'] =
                'Program populer dengan ${program['totalApplications'] ?? 0} aplikasi';
            program['recommendationScore'] =
                (program['totalApplications'] ?? 0).toDouble();
            return program;
          }).toList();

      // Sort by total applications
      _recommendedPrograms.sort((a, b) {
        final aApps = a['totalApplications'] as int? ?? 0;
        final bApps = b['totalApplications'] as int? ?? 0;
        return bApps.compareTo(aApps);
      });

      // If user data exists, add some personalization
      if (_userData != null) {
        for (var program in _recommendedPrograms) {
          final targetAudience =
              program['targetAudience']?.toString().toLowerCase() ?? '';
          final userJob = _userData!['jobType']?.toString().toLowerCase() ?? '';

          if (targetAudience.contains(userJob) ||
              targetAudience.contains('semua') ||
              targetAudience.contains('umum')) {
            program['recommendationScore'] =
                (program['recommendationScore'] ?? 0) + 10;
            program['reason'] =
                'Sesuai dengan profil Anda dan populer di kalangan pengguna';
          }
        }

        // Sort by recommendation score
        _recommendedPrograms.sort(
          (a, b) => (b['recommendationScore'] as double).compareTo(
            a['recommendationScore'] as double,
          ),
        );
      }
    } catch (e) {
      print('Error generating recommendations: $e');

      // Fallback: just get active programs
      try {
        final fallbackQuery =
            await FirebaseFirestore.instance
                .collection('programs')
                .where('status', isEqualTo: 'active')
                .limit(5)
                .get();

        _recommendedPrograms =
            fallbackQuery.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              data['reason'] = 'Program yang tersedia untuk Anda';
              data['recommendationScore'] = 50.0;
              return data;
            }).toList();
      } catch (e2) {
        print('Fallback query failed: $e2');
        _recommendedPrograms = [];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(RouteNames.userDashboard);
          },
        ),
        title: const Text(
          "Rekomendasi Program Saya",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade700, Colors.blue.shade900],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                });
                _loadRecommendations();
              }
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child:
            _isLoading
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Memuat rekomendasi...'),
                    ],
                  ),
                )
                : _currentUser == null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text('Silakan login terlebih dahulu'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.go(RouteNames.login);
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                )
                : _recommendedPrograms.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.recommend,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada rekomendasi program',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Coba lagi nanti atau lengkapi profil Anda',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.go(RouteNames.userProfile);
                        },
                        child: const Text('Lengkapi Profil'),
                      ),
                    ],
                  ),
                )
                : RefreshIndicator(
                  onRefresh: _loadRecommendations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _recommendedPrograms.length,
                    itemBuilder: (context, index) {
                      final program = _recommendedPrograms[index];
                      return RecommendationCardWidget(
                        programId: program['id'],
                        programData: program,
                        onTap: () {
                          context.push(
                            '/user/programs/detail/${program['id']}',
                          );
                        },
                      );
                    },
                  ),
                ),
      ),
    );
  }
}
