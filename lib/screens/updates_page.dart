// lib/screens/updates_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  // Mock data for application updates
  final List<Map<String, String>> _updates = const [
    {
      'version': '1.2.0',
      'date': 'July 1, 2025',
      'description': '• Introduced "Dust Bank" feature for rewarding mindful screen time.\n'
          '• Enhanced app performance and stability.\n'
          '• Minor UI improvements across various screens.'
    },
    {
      'version': '1.1.5',
      'date': 'June 15, 2025',
      'description': '• Fixed an issue where app usage stats were not consistently updating.\n'
          '• Improved permission handling flow for Android 11+.\n'
          '• Optimized data fetching from native modules.'
    },
    {
      'version': '1.1.0',
      'date': 'June 1, 2025',
      'description': '• Added a dedicated "Offers" screen with categorized brand deals.\n'
          '• Implemented dark mode theme toggle in settings.\n'
          '• Refined app navigation and bottom bar icons.'
    },
    {
      'version': '1.0.0',
      'date': 'May 15, 2025',
      'description': '• Initial release of DustBank.\n'
          '• Core screen time tracking functionality.\n'
          '• Basic profile and NFT Vault placeholders.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'App Updates',
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Go back to the Settings page
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _updates.map((update) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Version ${update['version']}',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Released: ${update['date']}',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      update['description']!,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
