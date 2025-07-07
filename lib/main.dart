// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/nft_vault_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/offers_screen.dart';
import 'screens/login_page.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_page.dart';

import 'firebase_options.dart';
import 'dart:async'; // For StreamSubscription

const String __app_id = String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');
const String __firebase_config = String.fromEnvironment('FIREBASE_CONFIG', defaultValue: '{}');
const String __initial_auth_token = String.fromEnvironment('INITIAL_AUTH_token', defaultValue: '');

// Define ThemeProvider to manage app theme and now notifications
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default theme is light
  bool _isNotificationsEnabled = true; // Default notifications to ON
  int _unreadNotificationsCount = 0; // New state for unread notifications

  // Firestore and Auth instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ThemeMode get themeMode => _themeMode;
  bool get isNotificationsEnabled => _isNotificationsEnabled;
  int get unreadNotificationsCount => _unreadNotificationsCount;

  // Method to toggle theme and save to Firestore
  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notify widgets listening to this provider

    final User? user = _auth.currentUser;
    if (user == null) {
      print("Cannot save theme preference: User not logged in.");
      return;
    }

    try {
      final docRef = _firestore.collection('artifacts').doc(__app_id).collection('users').doc(user.uid).collection('profile').doc('details');
      await docRef.set({
        'isDarkTheme': isDark, // Save the theme preference
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print("Theme preference saved to Firestore: $isDark");
    } catch (e) {
      print("Error saving theme preference to Firestore: $e");
      // Optionally revert local state or show error to user
      // _themeMode = isDark ? ThemeMode.light : ThemeMode.dark; // Revert on error
      // notifyListeners();
    }
  }

  // Method to load theme preference from Firestore
  Future<void> loadThemePreference() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      print("Cannot load theme preference: User not logged in.");
      return;
    }

    try {
      final docRef = _firestore.collection('artifacts').doc(__app_id).collection('users').doc(user.uid).collection('profile').doc('details');
      final snapshot = await docRef.get();

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        final bool isDark = data['isDarkTheme'] ?? false; // Default to false if not found
        if (_themeMode != (isDark ? ThemeMode.dark : ThemeMode.light)) {
          _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
          notifyListeners();
          print("Theme preference loaded from Firestore: $isDark");
        }
      } else {
        print("Profile document not found for theme preference, using default light theme.");
        // Optionally save default theme if profile doesn't exist
        await docRef.set({'isDarkTheme': false}, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error loading theme preference from Firestore: $e");
    }
  }

  // Method to toggle notification preference and save to Firestore
  Future<void> toggleNotifications(bool enable) async {
    _isNotificationsEnabled = enable;
    notifyListeners(); // Notify UI immediately

    final User? user = _auth.currentUser; // Using _auth instance from ThemeProvider
    if (user == null) {
      print("Cannot save notification preference: User not logged in.");
      return;
    }

    try {
      final docRef = _firestore.collection('artifacts').doc(__app_id).collection('users').doc(user.uid).collection('profile').doc('details');
      await docRef.set({
        'isNotificationsEnabled': enable,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print("Notification preference saved to Firestore: $enable");
    } catch (e) {
      print("Error saving notification preference to Firestore: $e");
      // Optionally revert local state or show error to user
      _isNotificationsEnabled = !enable; // Revert on error
      notifyListeners();
    }
  }

  // Method to update notification state from Firestore
  void setNotificationsEnabled(bool enable) {
    if (_isNotificationsEnabled != enable) {
      _isNotificationsEnabled = enable;
      notifyListeners();
    }
  }

  // New method to set unread notifications count
  void setUnreadNotificationsCount(int count) {
    if (_unreadNotificationsCount != count) {
      _unreadNotificationsCount = count;
      notifyListeners();
    }
  }

  // Method to add a new notification (for simulation/internal use)
  Future<void> addNotification({required String title, required String body}) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Cannot add notification: User not logged in.");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('artifacts')
          .doc(__app_id)
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add({
        'title': title,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
      print("New notification added to Firestore.");
    } catch (e) {
      print("Error adding notification: $e");
    }
  }

  // Method to mark a specific notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Cannot mark notification as read: User not logged in.");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('artifacts')
          .doc(__app_id)
          .collection('users')
          .doc(user.uid) // Ensure we're targeting the user's specific notifications
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      print("Notification $notificationId marked as read.");
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase initialized successfully.");

    final FirebaseAuth auth = FirebaseAuth.instance;

    if (__initial_auth_token.isNotEmpty) {
      try {
        debugPrint("Attempting sign-in with custom token...");
        await auth.signInWithCustomToken(__initial_auth_token);
        debugPrint("Signed in with custom token.");
      } on FirebaseAuthException catch (e) {
        debugPrint("Failed to sign in with custom token: ${e.code} - ${e.message}. Attempting anonymous sign-in.");
        await auth.signInAnonymously();
        debugPrint("Signed in anonymously after custom token failure.");
      } catch (e) {
        debugPrint("An unexpected error during custom token sign-in: $e. Attempting anonymous sign-in.");
        await auth.signInAnonymously();
        debugPrint("Signed in anonymously after unexpected error.");
      }
    } else {
      debugPrint("No initial auth token provided. Signing in anonymously.");
      await auth.signInAnonymously();
      debugPrint("Signed in anonymously.");
    }

    if (auth.currentUser != null) {
      debugPrint("Current authenticated user UID: ${auth.currentUser!.uid}");
    } else {
      debugPrint("No user authenticated after initial attempts.");
    }

  } catch (e) {
    debugPrint("Error initializing Firebase or during initial authentication: $e");
  }

  runApp(
    // Wrap MyApp with ChangeNotifierProvider to provide ThemeProvider
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the ThemeProvider for changes
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      key: const ValueKey('mainApp'), // Added a ValueKey to MaterialApp
      title: 'Screen Time Tracker', // Hardcoded title
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.blue.shade700,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.blue.shade200,
          selectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.montserrat(),
          type: BottomNavigationBarType.fixed,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      darkTheme: ThemeData( // Define a dark theme
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade900,
        cardColor: Colors.grey.shade800,
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: Colors.white70,
          displayColor: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade800,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey.shade800,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.montserrat(),
          type: BottomNavigationBarType.fixed,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      themeMode: themeProvider.themeMode, // Use themeMode from ThemeProvider
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            debugPrint("Auth state: Waiting for connection...");
            return Scaffold(
              key: const ValueKey('loadingScreen'),
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            debugPrint("Auth state: Error - ${snapshot.error}");
            return Scaffold(
              key: const ValueKey('errorScreen'),
              body: Center(
                child: Text('Error: ${snapshot.error}', style: GoogleFonts.montserrat(color: Colors.red)),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            debugPrint("Auth state: User logged in.");
            // Load theme preference as soon as user is authenticated
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<ThemeProvider>(context, listen: false).loadThemePreference();
            });
            return const MainScreen();
          } else {
            debugPrint("Auth state: No user logged in. Showing LoginPage.");
            return const LoginPage();
          }
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  String? _avatarImageUrl;
  StreamSubscription<DocumentSnapshot>? _profileSubscription;
  StreamSubscription<DocumentSnapshot>? _userProfileDetailsSubscription; // Renamed for clarity
  StreamSubscription<QuerySnapshot>? _unreadNotificationsSubscription;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    debugPrint("MainScreen initState called.");
    _pages = [
      const HomeScreen(),
      const NftVaultScreen(),
      const WalletScreen(),
      const OffersScreen(),
      const ProfileScreen(),
    ];
    debugPrint("MainScreen pages initialized. Number of pages: ${_pages.length}");
    _pages.asMap().forEach((index, page) {
      debugPrint("Page $index: ${page.runtimeType}");
    });

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        if (user != null) {
          _listenToAvatarChanges(user.uid);
          // This listener will now also update the theme and notifications based on Firestore
          _listenToUserProfileDetails(user.uid);
          _listenToUnreadNotifications(user.uid);
        } else {
          _profileSubscription?.cancel();
          _userProfileDetailsSubscription?.cancel(); // Cancel the consolidated listener
          _unreadNotificationsSubscription?.cancel();
          setState(() {
            _avatarImageUrl = null;
          });
          Provider.of<ThemeProvider>(context, listen: false).setNotificationsEnabled(true);
          Provider.of<ThemeProvider>(context, listen: false).setUnreadNotificationsCount(0);
          // Reset to default theme if user logs out
          Provider.of<ThemeProvider>(context, listen: false).toggleTheme(false); // Default to light
        }
      }
    });
  }

  void _listenToAvatarChanges(String userId) {
    final docRef = FirebaseFirestore.instance.collection('artifacts').doc(__app_id).collection('users').doc(userId).collection('profile').doc('details');

    // This subscription is specifically for the avatar URL in the AppBar
    _profileSubscription?.cancel();
    _profileSubscription = docRef.snapshots().listen((snapshot) {
      if (!mounted) return;
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        setState(() {
          _avatarImageUrl = data['avatarUrl'];
        });
        print("MainScreen AppBar avatar updated: $_avatarImageUrl");
      } else {
        setState(() {
          _avatarImageUrl = null;
        });
      }
    }, onError: (error) {
      if (mounted) {
        print("Error listening to avatar changes in MainScreen: $error");
      }
    });
  }

  // Consolidated listener for user profile details (notifications and theme)
  void _listenToUserProfileDetails(String userId) {
    final docRef = FirebaseFirestore.instance.collection('artifacts').doc(__app_id).collection('users').doc(userId).collection('profile').doc('details');

    _userProfileDetailsSubscription?.cancel(); // Use the new subscription variable
    _userProfileDetailsSubscription = docRef.snapshots().listen((snapshot) {
      if (!mounted) return;
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        // Update notification preference
        final bool isNotificationsEnabled = data['isNotificationsEnabled'] ?? true;
        Provider.of<ThemeProvider>(context, listen: false).setNotificationsEnabled(isNotificationsEnabled);

        // Update theme preference
        final bool isDarkTheme = data['isDarkTheme'] ?? false; // Default to false (light)
        // Only call toggleTheme if the theme actually changed to avoid unnecessary Firestore writes
        if (Provider.of<ThemeProvider>(context, listen: false).themeMode != (isDarkTheme ? ThemeMode.dark : ThemeMode.light)) {
           Provider.of<ThemeProvider>(context, listen: false).toggleTheme(isDarkTheme);
        }
        print("User profile details updated: Notifications: $isNotificationsEnabled, Dark Theme: $isDarkTheme");

      } else {
        // If profile document doesn't exist, set defaults
        Provider.of<ThemeProvider>(context, listen: false).setNotificationsEnabled(true);
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme(false); // Default to light
        print("Profile document not found for user details, setting defaults.");
      }
    }, onError: (error) {
      if (mounted) {
        print("Error listening to user profile details in MainScreen: $error");
        Provider.of<ThemeProvider>(context, listen: false).setNotificationsEnabled(true);
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme(false); // Default to light on error
      }
    });
  }


  void _listenToUnreadNotifications(String userId) {
    final notificationsCollectionRef = FirebaseFirestore.instance
        .collection('artifacts')
        .doc(__app_id)
        .collection('users')
        .doc(userId)
        .collection('notifications');

    _unreadNotificationsSubscription?.cancel();
    _unreadNotificationsSubscription = notificationsCollectionRef
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      final int unreadCount = snapshot.docs.length;
      Provider.of<ThemeProvider>(context, listen: false).setUnreadNotificationsCount(unreadCount);
      print("Unread notifications count updated: $unreadCount");
    }, onError: (error) {
      if (mounted) {
        print("Error listening to unread notifications: $error");
        Provider.of<ThemeProvider>(context, listen: false).setUnreadNotificationsCount(0);
      }
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
      debugPrint("Bottom navigation tapped. Selected index: $_selectedIndex");
    });
  }

  void _navigateToNotificationsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsPage()),
    );
  }

  @override
  void dispose() {
    debugPrint("MainScreen dispose called.");
    _pageController.dispose();
    _profileSubscription?.cancel();
    _userProfileDetailsSubscription?.cancel(); // Cancel the consolidated listener
    _unreadNotificationsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("MainScreen build called. Current selected index: $_selectedIndex");
    final User? user = FirebaseAuth.instance.currentUser;
    final String userName = user?.uid.substring(0, 8) ?? "Guest";

    final int unreadCount = Provider.of<ThemeProvider>(context).unreadNotificationsCount;
    final bool notificationsEnabled = Provider.of<ThemeProvider>(context).isNotificationsEnabled;

    return Scaffold(
      key: const ValueKey('mainScreenScaffold'),
      appBar: AppBar(
        title: Text(
          '${_getGreeting()}, $userName',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (notificationsEnabled)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_rounded, color: Colors.white),
                  onPressed: _navigateToNotificationsPage,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 11,
                    top: 11,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              backgroundImage: _avatarImageUrl != null
                  ? NetworkImage(_avatarImageUrl!)
                  : null,
              child: _avatarImageUrl == null
                  ? Icon(
                      Icons.person,
                      color: Colors.blue.shade700,
                      size: 25,
                    )
                  : null,
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
            debugPrint("PageView page changed to index: $_selectedIndex");
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security_rounded),
            label: 'NFT Vault',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer_rounded),
            label: 'Offers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
