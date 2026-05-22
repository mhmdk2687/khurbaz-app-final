import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Make sure to import this

import '../../utils/resources/app_colors.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  // --- Helper Methods ---

  // Launches the native phone dialer
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(launchUri)) {
      debugPrint('Could not launch dialer');
    }
  }

  // Launches WhatsApp directly to the chat
  Future<void> _launchWhatsApp(String phoneNumber) async {
    // WhatsApp requires numbers without dashes or plus signs
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri launchUri = Uri.parse('https://wa.me/$cleanNumber');

    if (!await launchUrl(launchUri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch WhatsApp');
    }
  }

  // Launches the default email client
  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(launchUri)) {
      debugPrint('Could not launch email client');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kScaffoldBackground,
        appBar: AppBar(
          title: const Text(
            "تواصل معنا",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // PHONE CARD: Added trailing buttons for Call & WhatsApp
              _ContactCard(
                icon: Icons.perm_phone_msg_outlined,
                title: "رقم الهاتف",
                value: "966-567189796",
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // IconButton(
                    //   icon: const Icon(Icons.call, color: Colors.green),
                    //   onPressed: () => _makePhoneCall("966567189796"),
                    // ),
                    IconButton(
                      // You can replace this with FontAwesomeIcons.whatsapp if you use the font_awesome_flutter package
                      icon: const Icon(Icons.chat, color: Colors.teal),
                      onPressed: () => _launchWhatsApp("966567189796"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // EMAIL CARD: Made the entire card clickable
              _ContactCard(
                icon: Icons.markunread_outlined,
                title: "البريد الإلكتروني",
                value: "khurbaz@outlook.sa",
                onTap: () => _sendEmail("khurbaz@outlook.sa"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.attach_email_rounded,
                        color: Colors.teal,
                      ),
                      onPressed: () => _sendEmail("khurbaz@outlook.sa"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // HOURS CARD: Static, no click action needed
              _ContactCard(
                icon: Icons.access_time,
                title: "ساعات العمل",
                value:
                    "يومياً من 9:30 صباحاً حتى 12 منتصف الليل \nالجمعة من 02:30 ظهراً الى 12 منتصف الليل",
              ),

              const SizedBox(height: 30),

              Text(
                "نحن هنا لخدمتك دائماً 🤍",
                style: TextStyle(
                  fontFamily: 'DINNextLT',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kMainColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap; // Added to allow the whole card to be clickable
  final Widget? trailing; // Added to allow placing buttons on the left (RTL)

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: kMainColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      // Wrapped the inner content in a Material & InkWell to give a native ripple effect when tapped
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: kMainColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: kMainColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'DINNextLT',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontFamily: 'DINNextLT',
                          fontSize: 13,
                          color: kTitleGreyColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Show trailing widget (like buttons) if it exists
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
