import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stock_price_forecasting_for_msx/widgets/ShowBottomSheet_resetPassword.dart';
import 'auth_service.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final emailPhoneController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    emailPhoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signinFunction() async {
    String emailPhone = emailPhoneController.text.trim();
    String password = passwordController.text.trim();

    // Here, insert logic to validate inputs and authenticate user
    if (emailPhone.isNotEmpty && password.isNotEmpty) {
      try {
        // Attempt login with authentication service
        await _authService.signInWithEmailAndPassword(emailPhone, password);
        // On success, navigate to the watchlist screen
        //Navigator.of(context).pushReplacementNamed('/', arguments: 0); 
        Navigator.pushNamedAndRemoveUntil(context, '/mainscaffold', (Route<dynamic> route) => false);
      } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuth specific errors here
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: ${e.message}')));
      } catch (e) {
        // Handle errors, e.g., show a Snackbar with an error message
        //print(e); // For debugging
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
      }
    } else {
      // Prompt user to fill all fields
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
    }
  }

  void signInWithGoogleFunction() async {
    try {
      // Use AuthService to sign in with Google
      await _authService.signInWithGoogle();
      // On success, navigate to the home screen
      Navigator.of(context).pushReplacementNamed('/watchlist'); // Adjust route as necessary
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google Sign-In failed: ${e.toString()}')));
    }
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
             onPressed: () {
              //Navigator.of(context).pop();
              Navigator.pushNamedAndRemoveUntil(context, '/mainscaffold', arguments: 3, (Route<dynamic> route) => false);
              },
             ),
             const Text('Back', style: TextStyle(fontSize: 16)),
              ],),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Image.asset('assets/images/MSX_logo.png', width: 90, height: 50,),
                        const Text('Welcome Back', style: TextStyle(fontSize: 17)),
                        const SizedBox(height: 50),
                        SizedBox(
                  height: 50,
                  child: TextField(
                    controller: emailPhoneController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12), 
                    filled: true,
                    fillColor: const Color.fromARGB(255, 232, 238, 240),
                    border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(6),),
                    hintText: "Email address",
                            ))),
                              const SizedBox(height: 10),
                              SizedBox(
                  height: 50,
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    obscuringCharacter: "*",
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12), 
                    filled: true,
                    fillColor: const Color.fromARGB(255, 232, 238, 240),
                    border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(6),),
                    hintText: "Password",
                            ),
                          ),
                              ),
                              const SizedBox(height: 20),
                              //Forgot password button
                              GestureDetector(child: const Text('Forgot password', 
                              style: TextStyle(color: Color.fromARGB(255, 22, 140, 236))), 
                              onTap: (){showBottomSheetResetPassword(context);},),
                              const SizedBox(height: 15),
                              //Sign in button
                              GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0),color: Colors.blue,),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('Sign in', style: TextStyle(color: Colors.white),),
                        ),
                      ],
                    ),
                  ),
                  onTap: (){signinFunction();},
                              ),
                              const SizedBox(height: 40),
                              //divider (or sign in with)
                              const Row(
                  children: <Widget>[
                    Expanded(child: Divider(color: Color.fromARGB(255, 199, 199, 199),thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('or sign in with', style: TextStyle(color: Color.fromARGB(255, 112, 112, 112)),),
                      ),
                      Expanded(child: Divider(color: Color.fromARGB(255, 199, 199, 199),thickness: 1,),),
                      ]),
                      const SizedBox(height: 10),
                        GestureDetector(
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0),color: const Color.fromARGB(255, 232, 238, 240),),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.0),), 
                                    padding: const EdgeInsets.fromLTRB(5, 5, 8, 5),
                                    child: Image.asset('assets/images/GoogleIcon.png', width: 20, height: 20,),
                                    ),
                                    const Text('Google'),
                                ],
                              ),
                            ),
                          ),
                          onTap: (){signInWithGoogleFunction();},
                        ),
                    ],
                  ),
                  ),
                  ],
                ),
              ),
            ),
            const Divider(color: Color.fromARGB(255, 204, 204, 204),thickness: 0.6, height: 1),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    child: const Text("Sign up", style: TextStyle(color: Color.fromARGB(255, 22, 140, 236))),
                    onTap: (){Navigator.of(context).pushNamed('/signup');}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}