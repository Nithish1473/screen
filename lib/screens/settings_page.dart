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
import 'package:screen_time_app/screens/privacy_policy_page.dart'; // New import
import 'package:screen_time_app/screens/terms_conditions_page.dart'; // New import
import 'package:screen_time_app/screens/dust_bank_description_page.dart'; // New import

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
    _listenToProfileChanges();
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
      } else {
        print("Profile document not found for settings.");
      }
    }, onError: (error) {
      if (mounted) {
        print("Error listening to profile changes in settings: $error");
      }
    });
  }

  void _simulateNewNotification() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (themeProvider.isNotificationsEnabled) {
      themeProvider.addNotification(
        title: 'New DustBank Insight!',
        body: 'Your weekly NFT insight card is ready. Check your vault!',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Simulated new notification! Check the home screen icon.', style: GoogleFonts.montserrat())),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notifications are currently disabled.', style: GoogleFonts.montserrat())),
      );
    }
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

            // Simulate Notification Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _simulateNewNotification,
                icon: const Icon(Icons.add_alert_rounded),
                label: Text(
                  'Simulate New Notification',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Updated Navigation Sections ---

            // App Updates Section
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
              child: ListTile(
                leading: Icon(Icons.privacy_tip_rounded, color: Colors.blue.shade700),
                title: Text(
                  'Privacy Policy',
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
                    MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Terms and Conditions Section
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Icon(Icons.description_rounded, color: Colors.blue.shade700),
                title: Text(
                  'Terms and Conditions',
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
                    MaterialPageRoute(builder: (context) => const TermsConditionsPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Dust Bank Description Section
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Icon(Icons.savings_rounded, color: Colors.blue.shade700),
                title: Text(
                  'Dust Bank Description',
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
                    MaterialPageRoute(builder: (context) => const DustBankDescriptionPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
