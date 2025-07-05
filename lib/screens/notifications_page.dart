// lib/screens/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting

import 'dart:async'; // For StreamSubscription

import 'package:screen_time_app/main.dart'; // Import ThemeProvider

// Global app ID (from main.dart)
const String __app_id = String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _notificationsSubscription;
  List<DocumentSnapshot> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }

  void _fetchNotifications() {
    final User? user = _auth.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _errorMessage = "User not logged in. Cannot fetch notifications.";
          _isLoading = false;
        });
      }
      print("NotificationsPage: User not logged in.");
      return;
    }

    final notificationsCollectionRef = _firestore
        .collection('artifacts')
        .doc(__app_id)
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true); // Order by most recent first

    _notificationsSubscription = notificationsCollectionRef.snapshots().listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _notifications = snapshot.docs;
        _isLoading = false;
        _errorMessage = null;
      });
      print("Notifications updated. Total: ${_notifications.length}");
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load notifications: $error";
          _isLoading = false;
        });
      }
      print("Error fetching notifications: $error");
    });
  }

  Future<void> _markAsRead(String notificationId) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await themeProvider.markNotificationAsRead(notificationId);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Notifications', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Notifications', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_rounded, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 20),
                  Text(
                    'No notifications yet!',
                    style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Simulate one from Settings to see it appear here.',
                    style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                final data = notification.data() as Map<String, dynamic>;
                final bool isRead = data['isRead'] ?? false;
                final String title = data['title'] ?? 'No Title';
                final String body = data['body'] ?? 'No Body';
                final Timestamp? timestamp = data['timestamp'] as Timestamp?;
                final String formattedDate = timestamp != null
                    ? DateFormat('MMM d, yyyy h:mm a').format(timestamp.toDate())
                    : 'No Date';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: isRead ? 2 : 4, // Higher elevation for unread
                  color: isRead ? Colors.grey.shade100 : Colors.blue.shade50, // Lighter color for unread
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: Icon(
                      isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                      color: isRead ? Colors.grey.shade500 : Colors.blue.shade700,
                    ),
                    title: Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        color: isRead ? Colors.black54 : Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          body,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: isRead ? Colors.black45 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    onTap: isRead ? null : () => _markAsRead(notification.id), // Only allow tapping if unread
                    trailing: isRead
                        ? null
                        : Icon(Icons.check_circle_outline_rounded, color: Colors.green.shade500), // Show check icon for unread
                  ),
                );
              },
            ),
    );
  }
}
