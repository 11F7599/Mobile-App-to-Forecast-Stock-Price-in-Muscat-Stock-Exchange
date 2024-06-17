import 'package:flutter/material.dart';

class IntroPage01 extends StatelessWidget {
  const IntroPage01({super.key});

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
                  'assets/images/onboarding_images/onboarding_p001.png',
                  width: 250,  // Width in logical pixels
                  height: 250, // Height in logical pixels
                ),
              ),
              const Text("Welcome to MSX+", style: TextStyle(fontSize: 17, color:Colors.black)),
              const Text(
                "Your Gateway \n"
                "to the Muscat Stock Exchange", 
              style: TextStyle(fontSize: 21, color:Colors.black, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 16,),
              const Text(
                "Experience the Muscat Stock Exchange like never before. Advanced and easily accessible, "
                "MSX+ brings you closer to the market with everything you need in one app." , 
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