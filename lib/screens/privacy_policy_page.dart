// lib/screens/privacy_policy_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
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
              'Privacy Policy (DustBank)',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Effective Date: July 5, 2025\nLast Updated: July 5, 2025',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'DustBank ("we", "our", or "us") values your privacy. This Privacy Policy explains how we collect, use, share, and protect your data.',
              style: GoogleFonts.montserrat(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            Text(
              '1. What Data We Collect',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                '- Behavior tags\n- In-app usage patterns\n- Optional user metadata\n- UUID or device ID',
                style: GoogleFonts.montserrat(fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '2. How We Use Your Data',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                '- To generate weekly NFTs\n- To offer brand rewards\n- For anonymized analytics',
                style: GoogleFonts.montserrat(fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '3. No Personal Identity Shared',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                '- No names, phones, or emails collected\n- No PII shared with brands',
                style: GoogleFonts.montserrat(fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '4. Data Sharing',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                '- Only anonymized tags shared\n- No resale without consent',
                style: GoogleFonts.montserrat(fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '5. Data Security',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                '- Encrypted storage\n- UUIDs are hashed',
                style: GoogleFonts.montserrat(fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '6. User Control',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                '- Option to delete data\n- Reset profile feature',
                style: GoogleFonts.montserrat(fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '7. Child Policy',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                '- Not intended for users under 13',
                style: GoogleFonts.montserrat(fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '8. Changes',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                '- Notified through app banner',
                style: GoogleFonts.montserrat(fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '9. Contact',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                'Email: your.email@example.com',
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
