// lib/screens/wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For currency formatting

// Import the OffersScreen for navigation
import 'offers_screen.dart';

// Global app ID (from main.dart, redefined here for direct access in this file)
const String __app_id = String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _currentBalance = 0.0;
  int _dustCoins = 0;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isBalanceVisible = true; // State variable for balance visibility

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  // Function to show a SnackBar message
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return; // Ensure widget is still mounted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.montserrat()),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _fetchWalletData() async {
    if (!mounted) return; // Ensure widget is still mounted
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _errorMessage = "User not logged in.";
          _isLoading = false;
        });
      }
      debugPrint("WalletScreen: User not logged in, cannot fetch data.");
      return;
    }

    try {
      final walletRef = FirebaseFirestore.instance
          .collection('artifacts')
          .doc(__app_id)
          .collection('users')
          .doc(user.uid)
          .collection('wallet')
          .doc('details');

      // Listen for real-time updates using onSnapshot
      walletRef.snapshots().listen((snapshot) {
        if (!mounted) return; // Ensure widget is still mounted before updating state

        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data()!;
          setState(() {
            _currentBalance = (data['currentBalance'] as num?)?.toDouble() ?? 0.0;
            _dustCoins = (data['dustCoins'] as num?)?.toInt() ?? 0;
            _isLoading = false;
          });
          debugPrint("Wallet data updated: Current Balance: $_currentBalance, Dust Coins: $_dustCoins");
        } else {
          // Document does not exist, initialize with default values
          setState(() {
            _currentBalance = 0.0;
            _dustCoins = 0;
            _isLoading = false;
          });
          debugPrint("Wallet document does not exist, initializing with default values.");
          // Optionally, create the document with initial values if it doesn't exist
          walletRef.set({
            'currentBalance': 0.0,
            'dustCoins': 0,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)); // Use merge to avoid overwriting other fields if they exist
        }
      }, onError: (error) {
        if (mounted) {
          setState(() {
            _errorMessage = "Failed to load wallet data: $error";
            _isLoading = false;
          });
        }
        debugPrint("Firestore Listener Error: $error");
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "An unexpected error occurred: $e";
          _isLoading = false;
        });
      }
      debugPrint("Error fetching wallet data: $e");
    }
  }

  void _onRedeemPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OffersScreen()),
    );
  }

  void _onWithdrawPressed() {
    // Placeholder for withdrawal logic
    _showSnackBar("Withdrawal functionality coming soon!", isError: false);
  }

  // Method to toggle balance visibility
  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Currency formatter
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final User? user = FirebaseAuth.instance.currentUser; // Get current user for UID

    // Determine text color based on theme brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColorForDustCoins = isDarkMode ? Colors.white : Colors.black87;


    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchWalletData,
                child: Text('Retry', style: GoogleFonts.montserrat()),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current Balance Debit Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0), // Adjusted padding for decreased height
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.4), // Changed to white with 40% opacity
                  spreadRadius: 3,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Balance',
                      style: GoogleFonts.montserrat(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(Icons.credit_card_rounded, color: Colors.white70, size: 28), // Card icon
                  ],
                ),
                const SizedBox(height: 10),
                Row( // Row for balance and eye icon
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isBalanceVisible
                          ? currencyFormatter.format(_currentBalance)
                          : '********', // Masked balance
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isBalanceVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        color: Colors.white70,
                        size: 28,
                      ),
                      onPressed: _toggleBalanceVisibility,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'User ID: ${user?.uid ?? 'Not available'}', // Display user UUID
                  style: GoogleFonts.montserrat(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    'SCREEN TIME CARD',
                    style: GoogleFonts.montserrat(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _onWithdrawPressed,
                    icon: const Icon(Icons.account_balance_rounded),
                    label: Text('Withdraw', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Dust Coins and Redeem Button (Dust Coins box now full width, Redeem inside)
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dust Coins',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$_dustCoins',
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: textColorForDustCoins, // Adaptive color based on theme
                    ),
                  ),
                  const SizedBox(height: 20), // Space between text and button
                  SizedBox(
                    width: double.infinity, // Make button full width
                    child: ElevatedButton.icon(
                      onPressed: _onRedeemPressed,
                      icon: const Icon(Icons.card_giftcard_rounded),
                      label: Text('Redeem', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
