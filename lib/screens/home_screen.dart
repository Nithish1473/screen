// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // Required for MethodChannel
import 'package:permission_handler/permission_handler.dart'; // For permission handling
import 'package:package_info_plus/package_info_plus.dart'; // To get app package name
import 'package:screen_time_app/screens/all_apps_screen.dart'; // Import the new screen
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:intl/intl.dart'; // For date formatting
import 'dart:async'; // Import for StreamSubscription

// Global app ID (from main.dart)
const String __app_id = String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  // Define the MethodChannel to communicate with native Android code
  static const MethodChannel _platform = MethodChannel('com.example.screen_time_app/usage_stats'); // IMPORTANT: Match your package name

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  String _userId = 'anonymous'; // Default for unauthenticated users

  List<Map<String, dynamic>> _appUsageStats = [];
  bool _isLoading = true;
  String _totalScreenTime = "0h 0m";
  bool _isDataStorageActive = true; // Local state for data storage preference

  StreamSubscription<DocumentSnapshot>? _profilePreferenceSubscription; // Listener for data storage preference

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add lifecycle observer
    _setupFirebaseAuthListener(); // Listen for auth state changes
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove lifecycle observer
    _profilePreferenceSubscription?.cancel(); // Cancel the preference listener
    super.dispose();
  }

  // Listen for Firebase Auth state changes to get the user ID
  void _setupFirebaseAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
          _userId = user?.uid ?? 'anonymous'; // Use UID or 'anonymous'
        });
        print("Auth state changed. User ID: $_userId");
        if (_userId != 'anonymous') {
          _listenToDataStoragePreference(); // Start listening to preference
          _checkAndRequestUsagePermission(); // Proceed with usage stats
        } else {
          _profilePreferenceSubscription?.cancel(); // Cancel listener if logged out
          setState(() {
            _isLoading = false;
            _appUsageStats = [];
            _totalScreenTime = "N/A";
            _isDataStorageActive = true; // Reset to default for anonymous/logged out
          });
        }
      }
    });
  }

  // New method to listen to the data storage preference from Firestore
  void _listenToDataStoragePreference() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("HomeScreen: No user to listen for data storage preference.");
      return;
    }

    final docRef = _firestore.collection('artifacts').doc(__app_id).collection('users').doc(user.uid).collection('profile').doc('details');

    _profilePreferenceSubscription?.cancel(); // Cancel previous subscription if any
    _profilePreferenceSubscription = docRef.snapshots().listen((snapshot) {
      if (!mounted) return; // Ensure widget is still mounted

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        setState(() {
          _isDataStorageActive = data['isDataStorageActive'] ?? true; // Default to true if not found
        });
        print("Data storage preference updated from Firestore: $_isDataStorageActive");
      } else {
        // If profile document doesn't exist, assume active and create it with default
        setState(() {
          _isDataStorageActive = true;
        });
        docRef.set({
          'displayUserId': user.uid.substring(0, 8), // Initial display name
          'isDataStorageActive': true,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print("Profile document not found for preference, initializing with defaults.");
      }
    }, onError: (error) {
      if (mounted) {
        print("Error listening to data storage preference: $error");
        // Decide how to handle error, e.g., assume active or deactivate
        setState(() {
          _isDataStorageActive = true; // Fallback to active on error
        });
      }
    });
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the app resumes from being inactive or paused (e.g., after user grants permission)
    if (state == AppLifecycleState.resumed) {
      print("App resumed. Re-checking usage permission and fetching data.");
      if (_userId != 'anonymous') { // Only re-check if logged in
        _checkAndRequestUsagePermission();
      }
    }
  }

  Future<void> _checkAndRequestUsagePermission() async {
    // Ensure user ID is available before proceeding
    if (_userId == 'anonymous') {
      print("User not authenticated, cannot check permissions or fetch data.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    final bool isGranted = await _platform.invokeMethod('checkUsagePermission');

    if (isGranted) {
      print("Usage stats permission already granted. Attempting to fetch/load data.");
      // Always fetch fresh data from native, then save to Firestore if active
      await _fetchUsageStats(forceNativeFetch: true);
    } else {
      print("Usage stats permission not granted. Prompting user.");
      setState(() {
        _isLoading = false;
      });
      _showPermissionRequiredDialog();
    }
  }

  Future<void> _loadUsageStatsFromFirestore() async {
    // This method is now primarily for initial display if native fetch is delayed or fails.
    // The actual data saving/refreshing will be handled by _fetchUsageStats.
    final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final docRef = _firestore.collection('artifacts').doc(__app_id).collection('users').doc(_userId).collection('daily_usage').doc(todayDate);

    try {
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        final List<dynamic> storedApps = data['apps'] ?? [];
        final int storedTotalTime = data['totalTime'] ?? 0;

        List<Map<String, dynamic>> parsedStats = [];
        for (var item in storedApps) {
          if (item is Map) {
            parsedStats.add(Map<String, dynamic>.from(item));
          }
        }

        print("Loaded usage data from Firestore for $todayDate.");
        setState(() {
          _appUsageStats = parsedStats;
          _totalScreenTime = _formatDuration(storedTotalTime);
          _isLoading = false;
        });
      } else {
        print("No usage data found in Firestore for today.");
        setState(() {
          _isLoading = false; // Stop loading even if no data
        });
      }
    } catch (e) {
      print("Error loading from Firestore: $e.");
      setState(() {
        _isLoading = false; // Stop loading on error
      });
    }
  }


  void _showPermissionRequiredDialog() {
    if (Navigator.of(context).canPop() && ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permission Required", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          content: Text("To track screen time, please grant 'Usage Access' permission in your phone settings. After granting, please return to the app.", style: GoogleFonts.montserrat()),
          actions: <Widget>[
            TextButton(
              child: Text("Go to Settings", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _platform.invokeMethod('requestUsagePermission');
              },
            ),
            TextButton(
              child: Text("Re-check Permission", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
                _checkAndRequestUsagePermission();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedDialog() {
    if (Navigator.of(context).canPop() && ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permission Denied", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          content: Text("Screen time tracking requires 'Usage Access' permission. Please enable it manually in your device settings to use this feature.", style: GoogleFonts.montserrat()),
          actions: <Widget>[
            TextButton(
              child: Text("OK", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchUsageStats({bool forceNativeFetch = false}) async {
    // Only set loading state if it's a forced fetch or not already loading
    if (forceNativeFetch || !_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    // Ensure user ID is available before proceeding
    if (_userId == 'anonymous') {
      print("User ID not available for fetching usage stats.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentPackageName = packageInfo.packageName;

      final List<dynamic>? result = await _platform.invokeMethod(
        'getAppUsageStats',
        {'packageName': currentPackageName},
      );

      if (result != null) {
        List<Map<String, dynamic>> parsedStats = [];
        int totalMilliseconds = 0;

        for (var item in result) {
          if (item is Map) {
            parsedStats.add(Map<String, dynamic>.from(item));
            totalMilliseconds += (item['totalTimeInForeground'] as int);
          }
        }

        parsedStats.sort((a, b) => (b['totalTimeInForeground'] as int).compareTo(a['totalTimeInForeground'] as int));

        _totalScreenTime = _formatDuration(totalMilliseconds);

        setState(() {
          _appUsageStats = parsedStats;
          _isLoading = false;
        });

        // Conditionally save to Firestore based on _isDataStorageActive
        if (_isDataStorageActive) {
          _saveUsageStatsToFirestore(parsedStats, totalMilliseconds);
        } else {
          print("Data storage is inactive. Not saving usage stats to Firestore.");
        }

      } else {
        setState(() {
          _isLoading = false;
          _appUsageStats = [];
          _totalScreenTime = "N/A";
        });
        print("Failed to get app usage stats: Result is null.");
      }
    } on PlatformException catch (e) {
      setState(() {
        _isLoading = false;
        _appUsageStats = [];
        _totalScreenTime = "Error";
      });
      print("Failed to get app usage stats: '${e.message}'.");
      if (e.code == "PERMISSION_DENIED") {
        _showPermissionDeniedDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching data: ${e.message}')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _appUsageStats = [];
        _totalScreenTime = "Error";
      });
      print("An unexpected error occurred: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }

  Future<void> _saveUsageStatsToFirestore(List<Map<String, dynamic>> stats, int totalTime) async {
    // Ensure _isDataStorageActive is checked here again, in case state changed
    if (!_isDataStorageActive) {
      print("Data storage is inactive. Aborting save to Firestore.");
      return;
    }

    final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final docRef = _firestore.collection('artifacts').doc(__app_id).collection('users').doc(_userId).collection('daily_usage').doc(todayDate);

    try {
      await docRef.set({
        'apps': stats,
        'totalTime': totalTime,
        'lastUpdated': FieldValue.serverTimestamp(), // Store server timestamp
      }, SetOptions(merge: true)); // Use merge to avoid overwriting other fields
      print("Usage stats saved to Firestore for $todayDate.");
    } catch (e) {
      print("Error saving to Firestore: $e");
    }
  }

  String _formatDuration(int milliseconds) {
    if (milliseconds <= 0) return "0h 0m";
    Duration duration = Duration(milliseconds: milliseconds);
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> top5Apps = _appUsageStats.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Screen Time Dashboard',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
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
                    'Total Screen Time Today',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          _totalScreenTime,
                          style: GoogleFonts.montserrat(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                  const SizedBox(height: 10),
                  Text(
                    'Compared to yesterday: +15%', // This is still mock data
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Top 5 Applications',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 15),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : top5Apps.isEmpty
                  ? Center(
                      child: Column(
                        children: [
                          Text(
                            "No usage data available or permission denied.",
                            style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _checkAndRequestUsagePermission,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh Data / Grant Permission'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: top5Apps.length,
                      itemBuilder: (context, index) {
                        final app = top5Apps[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                app['appName'] != null && app['appName'].isNotEmpty
                                    ? app['appName'][0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                            title: Text(
                              app['appName'] as String? ?? 'Unknown App',
                              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              app['packageName'] as String? ?? '',
                              style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey),
                            ),
                            trailing: Text(
                              _formatDuration(app['totalTimeInForeground'] as int),
                              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllAppsScreen(
                      appUsageStats: _appUsageStats,
                      formatDuration: _formatDuration,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.analytics_rounded),
              label: const Text('View Full Analytics'),
            ),
          ),
        ],
      ),
    );
  }
}
