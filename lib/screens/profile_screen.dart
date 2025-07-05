// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async'; // ADDED THIS LINE for StreamSubscription

// Import the new SettingsPage
import 'settings_page.dart';
import 'avatar_selection_page.dart'; // Import the new AvatarSelectionPage

// Global app ID (from main.dart)
const String __app_id = String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _displayUserId = "Loading...";
  bool _isLoadingProfile = true;
  bool _isDataStorageActive = true; // New state for data storage toggle
  String? _avatarImageUrl; // New state for avatar URL

  StreamSubscription<DocumentSnapshot>? _profileSubscription; // To listen for profile changes

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _listenToProfileChanges(); // Start listening to profile changes
  }

  @override
  void dispose() {
    _profileSubscription?.cancel(); // Cancel subscription when widget is disposed
    super.dispose();
  }

  void _listenToProfileChanges() {
    final User? user = _auth.currentUser;
    if (user == null) {
      print("ProfileScreen: No user to listen for profile changes.");
      return;
    }

    final docRef = _firestore.collection('artifacts').doc(__app_id).collection('users').doc(user.uid).collection('profile').doc('details');

    _profileSubscription = docRef.snapshots().listen((snapshot) {
      if (!mounted) return; // Ensure widget is still mounted

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        setState(() {
          _displayUserId = data['displayUserId'] ?? 'N/A';
          _isDataStorageActive = data['isDataStorageActive'] ?? true; // Default to true if not found
          _avatarImageUrl = data['avatarUrl']; // Update avatar URL from Firestore
        });
        print("Profile data updated from Firestore: isDataStorageActive = $_isDataStorageActive, avatarUrl = $_avatarImageUrl");
      } else {
        // If profile document doesn't exist, initialize default values
        setState(() {
          _displayUserId = user.uid.substring(0, 8); // Initial display name
          _isDataStorageActive = true; // Default to true
          _avatarImageUrl = null; // Default to no avatar
        });
        // Optionally, create the document with default values if it doesn't exist
        docRef.set({
          'displayUserId': user.uid.substring(0, 8), // Initial display name
          'isDataStorageActive': true,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print("Profile document not found, initializing with defaults.");
      }
    }, onError: (error) {
      if (mounted) {
        print("Error listening to profile changes: $error");
        setState(() {
          _isLoadingProfile = false; // Stop loading on error
        });
      }
    });
  }

  Future<void> _loadUserProfile() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _displayUserId = "Not Logged In";
          _isLoadingProfile = false;
        });
      }
      return;
    }

    // Initial load will be handled by the listener, but this ensures initial state if listener is slow
    // or if we need to explicitly fetch once.
    // The listener will eventually update the state.
    if (mounted) {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _toggleDataStorage(bool newValue) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to change settings.')),
      );
      return;
    }

    try {
      final docRef = _firestore.collection('artifacts').doc(__app_id).collection('users').doc(user.uid).collection('profile').doc('details');
      await docRef.set({
        'isDataStorageActive': newValue,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Use merge to update only this field
      print("Data storage preference updated to: $newValue");
      if (mounted) {
        setState(() {
          _isDataStorageActive = newValue; // Update local state immediately
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data storage ${newValue ? "activated" : "deactivated"}'),
          duration: Duration(seconds: newValue ? 2 : 6), // 2 seconds for active, 6 for inactive
        ),
      );
    } catch (e) {
      print("Error updating data storage preference: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update preference: $e')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      // The StreamBuilder in main.dart will automatically navigate to LoginPage
    } catch (e) {
      print("Error during logout: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  void _navigateToAvatarSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AvatarSelectionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Profile',
          style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display avatar here, now clickable
              GestureDetector(
                onTap: _navigateToAvatarSelection, // Navigate to avatar selection page
                child: CircleAvatar(
                  radius: 50, // Medium size
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: _avatarImageUrl != null
                      ? NetworkImage(_avatarImageUrl!)
                      : null,
                  child: _avatarImageUrl == null
                      ? Icon(
                          Icons.person_rounded,
                          size: 60,
                          color: Colors.blue.shade700,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Your Profile',
                style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
              ),
              const SizedBox(height: 20),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your User ID:',
                        style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 8),
                      _isLoadingProfile
                          ? const CircularProgressIndicator()
                          : Text(
                              _displayUserId,
                              style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                            ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isDataStorageActive ? 'Active' : 'Inactive',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _isDataStorageActive ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                          Switch(
                            value: _isDataStorageActive,
                            onChanged: _toggleDataStorage,
                            activeColor: Colors.green.shade600,
                            inactiveThumbColor: Colors.red.shade400,
                            inactiveTrackColor: Colors.red.shade200,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(
                    'Logout',
                    style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
