import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OnSocialMedia extends StatelessWidget {
  const OnSocialMedia({super.key});

  Future<void> _launchUrl(url) async {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri)) {
        throw 'Could not launch $url';
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_outlined),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const Text('Menu', style: TextStyle(fontSize: 16)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 8),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "We're on social media",
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                GestureDetector(
                  child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 6, 0),
                        child: Image.asset(
                        "assets/images/x icon.png",
                        width: 20,
                        height: 20,
                      ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color.fromARGB(255, 232, 238, 240),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("On X"),
                                Icon(Icons.arrow_right_outlined, size: 23),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                  onTap: () { _launchUrl("https://x.com/msx_plus"); },
              ),
              const SizedBox(height: 5),
                GestureDetector(
                  child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 6, 0),
                        child: Image.asset(
                        "assets/images/insta icon.png",
                        width: 20,
                        height: 20,
                      ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color.fromARGB(255, 232, 238, 240),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("On Instagram"),
                                Icon(Icons.arrow_right_outlined, size: 23),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                  onTap: () { _launchUrl("https://www.instagram.com/msx_plus/"); },
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
