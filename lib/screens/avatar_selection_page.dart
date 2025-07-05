// lib/screens/avatar_selection_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // For StreamSubscription
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg for SVG rendering (still useful if other SVGs are added later)

// Global app ID (from main.dart)
const String __app_id = String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');

class AvatarSelectionPage extends StatefulWidget {
  const AvatarSelectionPage({super.key});

  @override
  State<AvatarSelectionPage> createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends State<AvatarSelectionPage> {
  String? _currentAvatarImageUrl; // Stores the URL of the user's currently selected avatar
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot>? _profileSubscription; // To listen for profile changes

  // List of avatar URLs using the images you provided and some placeholders
  final List<String> _defaultAvatars = const [
    'https://lh3.googleusercontent.com/pw/AP1G8A0Wl5Jt6Z2Z_L1Q8g_9S0u8g_1Y7o9h_0X0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y=w100-h100-no', // Your uploaded image_ca53e5.jpg
    'https://lh3.googleusercontent.com/pw/AP1G8A3Z0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y0Y=w100-h100-no', // Your uploaded image_ca53e1.jpg (cat)
    'https://placehold.co/100x100/FFD700/000000?text=Star', // Gold Star
    'https://placehold.co/100x100/87CEEB/000000?text=Cloud', // Sky Blue Cloud
    'https://placehold.co/100x100/F08080/000000?text=Heart', // Light Coral Heart
    'https://placehold.co/100x100/7B68EE/FFFFFF?text=Gem', // Medium Slate Blue Gem
    'https://placehold.co/100x100/ADD8E6/000000?text=Smiley', // Light Blue Smiley
    'https://placehold.co/100x100/90EE90/000000?text=Leaf', // Light Green Leaf
    'https://placehold.co/100x100/FFB6C1/000000?text=Flower', // Light Pink Flower
  ];

  @override
  void initState() {
    super.initState();
    _listenToProfileChanges(); // Start listening to profile changes for avatar URL
  }

  @override
  void dispose() {
    _profileSubscription?.cancel(); // Cancel subscription when widget is disposed
    super.dispose();
  }

  void _listenToProfileChanges() {
    final User? user = _auth.currentUser;
    if (user == null) {
      print("AvatarSelectionPage: No user to listen for profile changes.");
      return;
    }

    // Reference to the user's profile details document in Firestore
    final docRef = _firestore.collection('artifacts').doc(__app_id).collection('users').doc(user.uid).collection('profile').doc('details');

    // Listen for real-time updates to the profile document
    _profileSubscription = docRef.snapshots().listen((snapshot) {
      if (!mounted) return; // Ensure widget is still mounted before updating state

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        setState(() {
          _currentAvatarImageUrl = data['avatarUrl']; // Update local state with current avatar URL from Firestore
        });
        print("Profile data updated from Firestore: avatarUrl = $_currentAvatarImageUrl");
      } else {
        // If the profile document doesn't exist, reset to null
        print("Profile document not found for avatar selection, avatar will be default.");
        setState(() {
          _currentAvatarImageUrl = null;
        });
      }
    }, onError: (error) {
      // Handle any errors during the Firestore stream
      if (mounted) {
        print("Error listening to profile changes in avatar selection: $error");
      }
    });
  }

  // Function to handle avatar selection and save to Firestore
  Future<void> _selectAvatar(String avatarUrl) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to change your avatar.')),
      );
      return;
    }

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Setting avatar...')),
        );
      }

      // Save the selected avatar URL to the user's profile in Firestore
      final docRef = _firestore.collection('artifacts').doc(__app_id).collection('users').doc(user.uid).collection('profile').doc('details');
      await docRef.set({
        'avatarUrl': avatarUrl,
        'lastUpdated': FieldValue.serverTimestamp(), // Add a timestamp for tracking updates
      }, SetOptions(merge: true)); // Use merge: true to only update specified fields

      if (mounted) {
        setState(() {
          _currentAvatarImageUrl = avatarUrl; // Update local state immediately
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Avatar updated successfully!')),
        );
      }
      print('Avatar updated to: $avatarUrl');
    } catch (e) {
      print("Error saving default avatar URL to Firestore: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save avatar: $e')),
        );
      }
    }
  }

  // Helper method to build the avatar widget, handling both NetworkImage and SvgPicture
  Widget _buildAvatarWidget(String? imageUrl, {double radius = 40.0, Color? backgroundColor}) {
    // If no image URL is provided, show a default person icon
    if (imageUrl == null || imageUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.blue.shade100,
        child: Icon(
          Icons.person_rounded,
          size: radius * 1.5, // Adjust icon size based on radius
          color: Colors.blue.shade700,
        ),
      );
    } else if (imageUrl.endsWith('.svg')) {
      // If the URL ends with .svg, use SvgPicture.network
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.blue.shade100,
        child: SvgPicture.network(
          imageUrl,
          width: radius * 2, // SVG width should match diameter of CircleAvatar
          height: radius * 2, // SVG height should match diameter of CircleAvatar
          placeholderBuilder: (BuildContext context) => Container(
            padding: EdgeInsets.all(radius * 0.25), // Add some padding for the placeholder
            child: const CircularProgressIndicator(strokeWidth: 2), // Show a small loading indicator
          ),
          fit: BoxFit.contain, // Ensure the SVG fits within the circular boundary
        ),
      );
    } else {
      // For other image formats (e.g., .png, .jpg), use NetworkImage
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.blue.shade100,
        backgroundImage: NetworkImage(imageUrl),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Choose Your Avatar',
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Go back to the Profile page
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'Your Current Avatar',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Display the user's current avatar using the helper widget
                  _buildAvatarWidget(_currentAvatarImageUrl, radius: 70.0),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Select a New Avatar',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 15),
            GridView.builder(
              shrinkWrap: true, // Take only as much space as needed
              physics: const NeverScrollableScrollPhysics(), // Disable scrolling for the grid itself
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 avatars per row
                crossAxisSpacing: 10, // Horizontal spacing between avatars
                mainAxisSpacing: 10, // Vertical spacing between avatars
                childAspectRatio: 1, // Make grid items square
              ),
              itemCount: _defaultAvatars.length,
              itemBuilder: (context, index) {
                final avatarUrl = _defaultAvatars[index];
                return GestureDetector(
                  onTap: () => _selectAvatar(avatarUrl), // Call _selectAvatar when tapped
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Display each selectable avatar using the helper widget
                      _buildAvatarWidget(avatarUrl, radius: 40.0, backgroundColor: Colors.grey[200]),
                      // Show a checkmark if this avatar is currently selected
                      if (_currentAvatarImageUrl == avatarUrl)
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade500,
                          size: 30,
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
