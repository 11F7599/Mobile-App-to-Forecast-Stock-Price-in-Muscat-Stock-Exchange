import 'package:flutter/material.dart';

class IntroPage02 extends StatelessWidget {
  const IntroPage02({super.key});

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
                  'assets/images/onboarding_images/onboarding_p002.png',
                  width: 250,  // Width in logical pixels
                  height: 250, // Height in logical pixels
                ),
              ),
              const SizedBox(height: 5),
              const Text("Track and Predict", style: TextStyle(fontSize: 17, color:Colors.black)),
              const Text(
                "Stay One Step Ahead",
              style: TextStyle(fontSize: 21, color:Colors.black, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 16,),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black), // default text style
                  children: <TextSpan>[
                    TextSpan(text: '✔ ', style: TextStyle(color: Colors.green)), // check icon as a unicode character
                    TextSpan(text: 'Real-time stock price tracking\n'),
                    TextSpan(text: '✔ ', style: TextStyle(color: Colors.green)),
                    TextSpan(text: 'Smart Predictions for Better Decisions\n'),
                    TextSpan(text: '✔ ', style: TextStyle(color: Colors.green)),
                    TextSpan(text: 'Customizable alerts for stock performance\n'),
                  ],
                ),
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