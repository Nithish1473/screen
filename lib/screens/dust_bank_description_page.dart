// lib/screens/dust_bank_description_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DustBankDescriptionPage extends StatelessWidget {
  const DustBankDescriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dust Bank Description',
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
              'What is DustBank?',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'DustBank is a behavior-intelligence app that captures how you live, feel, and bounce back - and converts it into a powerful weekly NFT insight card.',
              style: GoogleFonts.montserrat(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            Text(
              'Unlike traditional habit trackers or emotion journals, DustBank doesn\'t just log your steps - it decodes your emotional and behavioral fingerprint across five unique life layers:',
              style: GoogleFonts.montserrat(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '* Burnout - Moments of overwhelm and exhaustion',
                    style: GoogleFonts.montserrat(fontSize: 16),
                  ),
                  Text(
                    '* Impulse - Spur-of-the-moment actions or reactions',
                    style: GoogleFonts.montserrat(fontSize: 16),
                  ),
                  Text(
                    '* Detox - Times when you consciously break patterns',
                    style: GoogleFonts.montserrat(fontSize: 16),
                  ),
                  Text(
                    '* Bounce Back - Your recovery and resilience days',
                    style: GoogleFonts.montserrat(fontSize: 16),
                  ),
                  Text(
                    '* Learning - Reflections, realizations, and growth',
                    style: GoogleFonts.montserrat(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Every week, DustBank reflects your behavior through a personal NFT card - a visual and private snapshot of how you showed up that week. These NFTs are yours. You can keep them, track them, or even exchange them for real-world brand rewards.',
              style: GoogleFonts.montserrat(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            Text(
              'Powered by anonymous tracking and privacy-first design, DustBank gives you:',
              style: GoogleFonts.montserrat(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '- Zero sign-up friction (UUID-based entry)',
                    style: GoogleFonts.montserrat(fontSize: 16),
                  ),
                  Text(
                    '- Weekly reflections without journaling pressure',
                    style: GoogleFonts.montserrat(fontSize: 16),
                  ),
                  Text(
                    '- Emotional awareness without public sharing',
                    style: GoogleFonts.montserrat(fontSize: 16),
                  ),
                  Text(
                    '- A growing reward system from aligned brand partners',
                    style: GoogleFonts.montserrat(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'For brands: DustBank creates emotion-moment matching, helping you reach users not just by age or location - but by how they feel.',
              style: GoogleFonts.montserrat(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            Text(
              'Join the movement. Own your data. Reflect your life.\nDustBank - not a diary. Not a tracker. A mirror for the soul of your week.',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
