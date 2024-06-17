//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stock_price_forecasting_for_msx/api/notification_api.dart';
import 'package:stock_price_forecasting_for_msx/screens/auth_service.dart';

import 'screens/investor/watchlist.dart';
import 'screens/investor/explore.dart';
import 'screens/investor/ideas.dart';
import 'screens/investor/menu.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  int finalParameter = 0;
  final List<Widget> _pages = const [
     Watchlist(),
     Explore(),
     Ideas(),
     Menu(),
  ];


  @override
  void initState() {
    super.initState();
    //checkEmailVerificationStatus(context); // Check email verification status when the app starts
    // Delaying the check to allow the framework to build the widget tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkEmailVerificationStatus(context); // Check email verification status when the app starts
    });

    //Get and Save Device Token
    final AuthService authService = AuthService();
    final FirebaseAuth auth = FirebaseAuth.instance;
    bool isLoggedIn = authService.isLoggedIn();
    if(isLoggedIn){
    String? userEmail = auth.currentUser?.email;
    requestPermission();
    getToken(userEmail!);
    }


        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(message.notification!.title!),
            content: Text(message.notification!.body!),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      // Handle the notification interaction when the app is opened from a notification
    });


  }

  Future<void> checkEmailVerificationStatus(BuildContext context) async {
    if(FirebaseAuth.instance.currentUser != null && !FirebaseAuth.instance.currentUser!.emailVerified){
      Navigator.of(context).pushNamed('/emailverification');
    }
  }



// bool isAdmin() {
//     final currentUser = FirebaseAuth.instance.currentUser;

//     // Check if the currentUser exists and has an "admin" role
//     if (currentUser != null && currentUser.email == "electown.team@gmail.com") {
//       return true; // User is an admin
//     } else {
//       return false; // User is not an admin
//     }
//   }

bool isAdmin() {
      return false;
  }



// @override
//   void initState() {
//     super.initState();
    
//     if ( isAdmin() ){
//   _pages = [
//     const Home(),
//     const Bookings(),
//     const ChatAdmin(),
//     const Account(),
//   ];
// }
//   }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    finalParameter = ModalRoute.of(context)?.settings.arguments as int? ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    if (finalParameter != 0) {
      _currentIndex = finalParameter;
    }

    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 231, 231, 231),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.black, 
        selectedItemColor: Colors.pinkAccent.shade400,
        items: [
          BottomNavigationBarItem(
                label: 'Watchlist', icon: Icon((_currentIndex == 0) ? Icons.star : Icons.star_border_outlined)),
            BottomNavigationBarItem(
                label: 'Explore', icon: Icon((_currentIndex == 1) ? Icons.explore : Icons.explore_outlined)),
            BottomNavigationBarItem(
                label: 'Ideas', icon: Icon((_currentIndex == 2) ? Icons.lightbulb : Icons.lightbulb_outline)),
            const BottomNavigationBarItem(
                label: 'Menu', icon: Icon(Icons.menu)),
        ],
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            finalParameter = 0;
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
