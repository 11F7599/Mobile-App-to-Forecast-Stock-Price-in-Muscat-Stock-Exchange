import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({super.key});

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    sendVerificationEmailFunction(context);
    setTimerForAutoRedirect(context);
  }

  void setTimerForAutoRedirect(context){
    Timer.periodic(
      const Duration(seconds: 1), 
      (timer) async{
      await FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser == null) {
      // User has signed out
      timer.cancel();
      Navigator.pushNamedAndRemoveUntil(context, '/', arguments: 3, (Route<dynamic> route) => false);
    }
      else if (FirebaseAuth.instance.currentUser?.emailVerified ?? false){
        timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created successfully')));
        Navigator.of(context).pushNamed('/emailverificationmessage');
      }
    });
  }

    void sendVerificationEmailFunction(BuildContext context) async {
    //String email = "tryhooks@gmail.com";
    _authService.sendVerificationEmail((bool success, String? errorMessage){
      if (success) {
    // Navigate to Email verification screen
    //Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
    //Navigator.of(context).pushNamed('/emailverification');
  } else {
    // Display an error message to the user
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage ?? 'An error occurred during resend verification email')));
  }
    });
  }

void deleteAnAccountFunction(BuildContext context) async {
    _authService.deleteAnAccount((bool success, String? errorMessage){
    if (success) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage ?? 'registration canceled successfully')));
    Navigator.pushNamedAndRemoveUntil(context, '/', arguments: 3, (Route<dynamic> route) => false); // Go back to menu screen
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage ?? 'An error occurred during canceling the registration')));
    Navigator.pushNamedAndRemoveUntil(context, '/', arguments: 0, (Route<dynamic> route) => false); // Go back to Watchlist screen
  }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
             children:[
             IconButton(icon: const Icon(Icons.arrow_back_ios_outlined),
             onPressed: () {deleteAnAccountFunction(context);},
             ),
             const Text('Cancel Registration', style: TextStyle(fontSize: 16)),
              ],),
              Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/waiting.gif', width: 300, height: 300,),
                        const Text('Waiting for email verification',style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 5),
                        Text(FirebaseAuth.instance.currentUser!.email.toString(),style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        //Resend Verification Email
                                GestureDetector(
                    child: const Text('Resend verification email', style: TextStyle(color: Color.fromARGB(214, 56, 56, 56)),),
                    onTap: (){sendVerificationEmailFunction(context);},
                                ),
                                const SizedBox(height: 50),
                      ],
                    ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}