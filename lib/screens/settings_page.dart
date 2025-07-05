// lib/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

// Corrected import path for ThemeProvider
import 'package:screen_time_app/main.dart';
import 'package:screen_time_app/screens/updates_page.dart';
// import 'package:screen_time_app/screens/avatar_selection_page.dart'; // No longer directly used here

// Global app ID (from main.dart)
const String __app_id = String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot>? _profileSubscription;

  @override
  void initState() {
    super.initState();
    _listenToProfileChanges(); // Listen for any profile changes relevant to settings
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  void _listenToProfileChanges() {
    final User? user = _auth.currentUser;
    if (user == null) {
      print("SettingsPage: No user to listen for profile changes.");
      return;
    }

    final docRef = _firestore.collection('artifacts').doc(__app_id).collection('users').doc(user.uid).collection('profile').doc('details');

    _profileSubscription = docRef.snapshots().listen((snapshot) {
      if (!mounted) return;
      if (snapshot.exists && snapshot.data() != null) {
        print("Profile data exists in settings page.");
        // If you need to react to other profile changes in settings, add logic here
      } else {
        print("Profile document not found for settings.");
      }
    }, onError: (error) {
      if (mounted) {
        print("Error listening to profile changes in settings: $error");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Toggle Section
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'App Theme',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Switch(
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (isOn) {
                        themeProvider.toggleTheme(isOn);
                      },
                      activeColor: Colors.blue.shade700,
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.grey.shade200,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Notifications Toggle Section
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Switch(
                      value: themeProvider.isNotificationsEnabled,
                      onChanged: (isOn) {
                        themeProvider.toggleNotifications(isOn);
                      },
                      activeColor: Colors.blue.shade700,
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.grey.shade200,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Updates Section
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Icon(Icons.update_rounded, color: Colors.blue.shade700),
                title: Text(
                  'App Updates',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UpdatesPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Privacy Policy Section
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ExpansionTile(
                title: Text(
                  'Privacy Policy',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                leading: Icon(Icons.privacy_tip_rounded,
                    color: Colors.blue.shade700),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                    child: Text(
                      'Privacy Policy (DustBank)\n'
                      'Effective Date: July 5, 2025\n'
                      'Last Updated: July 5, 2025\n'
                      'DustBank ("we", "our", or "us") values your privacy. This Privacy Policy explains how we collect, use, share,\n'
                      'and protect your data.\n'
                      '1. What Data We Collect\n'
                      '- Behavior tags\n'
                      '- In-app usage patterns\n'
                      '- Optional user metadata\n'
                      '- UUID or device ID\n'
                      '2. How We Use Your Data\n'
                      '- To generate weekly NFTs\n'
                      '- To offer brand rewards\n'
                      '- For anonymized analytics\n'
                      '3. No Personal Identity Shared\n'
                      '- No names, phones, or emails collected\n'
                      '- No PII shared with brands\n'
                      '4. Data Sharing\n'
                      '- Only anonymized tags shared\n'
                      '- No resale without consent\n'
                      '5. Data Security\n'
                      '- Encrypted storage\n'
                      '- UUIDs are hashed\n'
                      '6. User Control\n'
                      '- Option to delete data\n'
                      '- Reset profile feature\n'
                      '7. Child Policy\n'
                      '- Not intended for users under 13\n'
                      '8. Changes\n'
                      '- Notified through app banner\n'
                      '9. Contact\n'
                      'Email: your.email@example.com',
                      style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black87),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Terms and Conditions Section
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ExpansionTile(
                title: Text(
                  'Terms and Conditions',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                leading: Icon(Icons.description_rounded, color: Colors.blue.shade700),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                    child: Text(
                      'Terms & Conditions (DustBank)\n'
                      '1. Usage\n'
                      'Use DustBank only for personal insights. No commercial scraping or cloning.\n'
                      '2. Rewards\n'
                      'Brand rewards are external. We are not liable for delivery or quality.\n'
                      '3. Data Ownership\n'
                      'You own your behavior. We only generate insights.\n'
                      '4. Conduct\n'
                      'No abuse or illegal behavior allowed. Offenders may be blocked.\n'
                      '5. Modifications\n'
                      'We may update features or terms anytime.\n'
                      '6. Disclaimer\n'
                      'DustBank does not offer medical or financial advice. Use for awareness only.',
                      style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black87),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Dust Bank Description Section
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ExpansionTile(
                title: Text(
                  'Dust Bank Description',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                leading: Icon(Icons.savings_rounded, color: Colors.blue.shade700),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                    child: Text(
                      'DustBank is a behavior-intelligence app that captures how you live, feel, and bounce back - and converts it into a powerful weekly NFT insight card.\n'
                      'Unlike traditional habit trackers or emotion journals, DustBank doesn\'t just log your steps - it decodes your emotional and behavioral fingerprint across five unique life layers:\n'
                      '* Burnout - Moments of overwhelm and exhaustion\n'
                      '* Impulse - Spur-of-the-moment actions or reactions\n'
                      '* Detox - Times when you consciously break patterns\n'
                      '* Bounce Back - Your recovery and resilience days\n'
                      '* Learning - Reflections, realizations, and growth\n'
                      'Every week, DustBank reflects your behavior through a personal NFT card - a visual and private snapshot of how you showed up that week. These NFTs are yours. You can keep them, track them, or even exchange them for real-world brand rewards.\n'
                      'Powered by anonymous tracking and privacy-first design, DustBank gives you:\n'
                      '- Zero sign-up friction (UUID-based entry)\n'
                      '- Weekly reflections without journaling pressure\n'
                      '- Emotional awareness without public sharing\n'
                      '- A growing reward system from aligned brand partners\n'
                      'For brands: DustBank creates emotion-moment matching, helping you reach users not just by age or location - but by how they feel.\n'
                      'Join the movement. Own your data. Reflect your life.\n'
                      'DustBank - not a diary. Not a tracker. A mirror for the soul of your week.',
                      style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black87),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
