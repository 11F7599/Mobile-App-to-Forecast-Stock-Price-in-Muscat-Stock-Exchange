import 'package:flutter/material.dart';

class IntroPage03 extends StatelessWidget {
  const IntroPage03({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16,0,16,0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/onboarding_images/onboarding_p003.png',
                  width: 250,  // Width in logical pixels
                  height: 250, // Height in logical pixels
                ),
              ),
              const Text("Get Started", style: TextStyle(fontSize: 17, color:Colors.black)),
              const Text(
                "Ready to Invest Smarter?",
              style: TextStyle(fontSize: 21, color:Colors.black, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 16,),
              const Text(
                "Create your account in just a few steps and unlock the full power of MSX+ for just 2 OMR per month.", 
                style: TextStyle(fontSize: 16), 
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 50,)
            ],
          ),
        ),
      ),
    );
  }
}