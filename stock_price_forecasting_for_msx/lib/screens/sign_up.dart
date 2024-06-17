import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/CustomTextfield01.dart';
import 'auth_service.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final displayNameController = TextEditingController();
  final emailAddressController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

    @override
  void dispose() {
    displayNameController.dispose();
    emailAddressController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signUpFunction() async {
  String displayName = displayNameController.text.trim();
  String email = emailAddressController.text.trim();
  String phoneText = phoneNumberController.text.trim();
  String password = passwordController.text.trim();

  if (displayName.isEmpty || email.isEmpty || phoneText.isEmpty || password.isEmpty)
  { 
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields'))); 
    return;
  }

  if (displayName.length > 12) 
  { 
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Display name must be no more than 12 characters long'))); 
    return;
  }

  if (phoneText.length != 8) 
  { 
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number must be 8 digits long'))); 
    return;
  }

  int? phone = int.tryParse(phoneText);
  if (phone == null) { // Check if parsing was successful
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid phone number')));
    return;
  }

  if (password.length < 8 || password.length > 16) 
  { 
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be 8 to 16 characters long'))); 
    return;
  }


_authService.signUpWithEmailAndPassword(email, password, phone, displayName, (bool success, String? errorMessage) {
  if (success) {
    // Navigate to Email verification screen
    //Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
    Navigator.of(context).pushNamed('/emailverification');
  } else {
    // Display an error message to the user
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage ?? 'An error occurred during signup')));
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
             onPressed: () {Navigator.of(context).pop();},
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
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Row(children: <Widget>[Expanded(
                            child: Text(
                              'Forecasting Stock Prices for Companies Listed on the Muscat Stock Exchange (MSX)',
                              softWrap: true,
                              overflow: TextOverflow.clip,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 112, 112, 112)),
                              ),),],),
                          ),
                          const SizedBox(height: 40),
                          const Row(
                            children: [
                              Expanded(child: Padding(
                                padding: EdgeInsets.only(left: 12),
                                child: Text('Sign up', style: TextStyle(fontSize: 17), textAlign: TextAlign.left,),
                              )),
                            ],
                          ),
                          const SizedBox(height: 10),
                          CustomTextfield01(
                            controller: displayNameController,
                            hintText: "Display name",
                            obscureText: false,
                          ),
                          const SizedBox(height: 10),
                          CustomTextfield01(
                            controller: emailAddressController,
                            hintText: "Email address",
                            obscureText: false,
                          ),
                          const SizedBox(height: 10),
                          CustomTextfield01(
                            controller: phoneNumberController,
                            hintText: "Phone number",
                            obscureText: false,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly,],
                          ),
                          const SizedBox(height: 10),
                          CustomTextfield01(
                            controller: passwordController,
                            hintText: "Password",
                            obscureText: true,
                          ),
                                const Text('At least 8 characters long that include letters and numbers',
                                style: TextStyle(color: Color.fromARGB(255, 112, 112, 112),fontSize: 13),
                                ),
                                const SizedBox(height: 25),
                                //Sign in button
                                GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0),color: Colors.blue,),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('Sign up', style: TextStyle(color: Colors.white),),
                          ),
                        ],
                      ),
                    ),
                    onTap: (){signUpFunction();},
                                ),
                                const SizedBox(height: 40),
                                //divider (or sign in with)
                                const Row(
                    children: <Widget>[
                      Expanded(child: Divider(color: Color.fromARGB(255, 199, 199, 199),thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('or sign up with', style: TextStyle(color: Color.fromARGB(255, 112, 112, 112)),),
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
                            onTap: (){},
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
                  const Text("Already have an account? "),
                  GestureDetector(
                    child: const Text("Sign in", style: TextStyle(color: Color.fromARGB(255, 22, 140, 236))),
                    onTap: (){Navigator.of(context).pop();}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}