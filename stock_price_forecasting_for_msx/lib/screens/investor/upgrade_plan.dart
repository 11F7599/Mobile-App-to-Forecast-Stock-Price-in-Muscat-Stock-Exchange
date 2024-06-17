import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stock_price_forecasting_for_msx/screens/auth_service.dart';

class UpgradePlan extends StatefulWidget {
  const UpgradePlan({super.key});

  @override
  State<UpgradePlan> createState() => _UpgradePlanState();
}

class _UpgradePlanState extends State<UpgradePlan> {

  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late bool _isLoggedIn;
  String? userEmail;
  late bool _isMember = false;

  Future<void> isMember(String email) async {
    _isMember = await _authService.isMember(email); // Correctly await the future
    if (mounted) {
        setState(() {});
      }
  }

  Future<void> thawaniPay() async {
    try {
    } 
    catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    _isLoggedIn = _authService.isLoggedIn(); // check if user is logged in or not
    if(_isLoggedIn){
    userEmail = _auth.currentUser?.email;
    isMember(userEmail!);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/upgrade_plan_bg.jpg"), 
            fit: BoxFit.cover, // This will cover the whole area of the scaffold
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Row(
               children:[
               IconButton(icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
               onPressed: () {Navigator.of(context).pop();},
               ),
               const Text('Back', style: TextStyle(fontSize: 16, color: Colors.white)),
                ],),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Image.asset('assets/images/MSX_logo_whiteBG.png', width: 60, height: 50,),
                          const Text('Upgrade Plan', style: TextStyle(fontSize: 26, color: Colors.white,
                          shadows: [
                            Shadow( // Bottom-left
                              offset: Offset(-1.5, -1.5),
                              color: Colors.black,
                            ),
                            Shadow( // Bottom-right
                              offset: Offset(1.5, -1.5),
                              color: Colors.black,
                            ),
                            Shadow( // Top-left
                              offset: Offset(-1.5, 1.5),
                              color: Colors.black,
                            ),
                            Shadow( // Top-right
                              offset: Offset(1.5, 1.5),
                              color: Colors.black,
                            ),
                          ],
                          )),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              !_isLoggedIn? Navigator.of(context).pushNamed('/signin') : thawaniPay();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                          border: Border.all(
                                          color: Colors.blue, // Color of the border
                                          width: 2.0, // Width of the border
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                          color: const Color.fromARGB(255, 77, 76, 76),
                                        ),
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(7, 2, 7, 2),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          color: Colors.white,
                                        ),
                                        child: const Text('PREMIUM')
                                        ),
                                      const Text('2 Omani Rial /Mo', 
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 187, 198, 204), 
                                        //fontWeight: FontWeight.bold),
                                        fontSize: 16,),
                                        ),
                                    ],),
                                    const SizedBox(height: 16,),
                                    RichText(
                                      text: const TextSpan(
                                        style: TextStyle(fontSize: 15, color: Colors.white), // default text style
                                        children: <TextSpan>[
                                          TextSpan(text: '✔ ', style: TextStyle(color: Colors.green)), // check icon as a unicode character
                                          TextSpan(text: 'Real-time stock price tracking\n'),
                                          TextSpan(text: '✔ ', style: TextStyle(color: Colors.green)),
                                          TextSpan(text: 'Smart Predictions for Better Decisions\n'),
                                          TextSpan(text: '✔ ', style: TextStyle(color: Colors.green)),
                                          TextSpan(text: 'Customizable alerts for stock performance\n'),
                                        ],
                                      ),
                                      //textAlign: TextAlign.justify,
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
      
            ],
          ),
        ),
      ),
    );
  }
}