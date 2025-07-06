// lib/screens/terms_conditions_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms and Conditions',
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
            Text(
              'Terms & Conditions (DustBank)',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '1. Usage',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                'Use DustBank only for personal insights. No commercial scraping or cloning.',
                style: GoogleFonts.montserrat(fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '2. Rewards',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                'Brand rewards are external. We are not liable for delivery or quality.',
                style: GoogleFonts.montserrat(fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '3. Data Ownership',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                'You own your behavior. We only generate insights.',
                style: GoogleFonts.montserrat(fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '4. Conduct',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                'No abuse or illegal behavior allowed. Offenders may be blocked.',
                style: GoogleFonts.montserrat(fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '5. Modifications',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                'We may update features or terms anytime.',
                style: GoogleFonts.montserrat(fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '6. Disclaimer',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                'DustBank does not offer medical or financial advice. Use for awareness only.',
                style: GoogleFonts.montserrat(fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
