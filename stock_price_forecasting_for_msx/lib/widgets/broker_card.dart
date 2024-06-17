import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BrokerCard extends StatelessWidget {
  final String imagePath;
  final String brokerName;
  final String email;
  final String url;

  const BrokerCard({
    required this.imagePath,
    required this.brokerName,
    required this.email,
    required this.url,
    super.key,
  });


  Future<void> _launchUrl() async {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri)) {
        throw 'Could not launch $url';
      }
    }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchUrl,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue, // Color of the border
            width: 2.0, // Width of the border
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: 60,
              height: 50,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brokerName,
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                ),
                Text(
                  email,
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
