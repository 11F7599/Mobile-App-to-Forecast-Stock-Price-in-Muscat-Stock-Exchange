import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:stock_price_forecasting_for_msx/screens/brokers.dart';
import 'package:stock_price_forecasting_for_msx/screens/on_social_media.dart';
import 'package:stock_price_forecasting_for_msx/screens/onboarding_screen.dart';
import 'package:stock_price_forecasting_for_msx/screens/stock_details.dart';
import 'firebase_options.dart';

import 'main_scaffold.dart';
import 'screens/email_verification.dart';
import 'screens/email_verification_message.dart';
import 'screens/investor/watchlist.dart';
import 'screens/investor/explore.dart';
import 'screens/investor/ideas.dart';
import 'screens/investor/menu.dart';
import 'screens/profile.dart';
import 'screens/sign_in.dart';
import 'screens/sign_up.dart';
import 'screens/investor/upgrade_plan.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp()); 
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //title: 'My App',
      initialRoute: '/',
      routes: {
        //'/': (context) => const Auth(),
        '/': (context) => const OnBoardingScreen(),
        '/mainscaffold': (context) => const MainScaffold(),
        '/watchlist': (context) => const Watchlist(),
        '/explore': (context) => const Explore(),
        '/ideas': (context) => const Ideas(),
        '/menu': (context) => const Menu(),
        '/signin': (context) => const Signin(),
        '/signup': (context) => const Signup(),
        '/upgradeplan' : (context) => const UpgradePlan(),
        '/profile' : (context) => const Profile(),
        '/emailverification' : (context) => const EmailVerification(),
        '/emailverificationmessage' : (context) => const EmailVerificationMessage(),
        '/brokers' : (context) => const Brokers(),
        '/stockdetails' : (context) => const StockDetails(),
        '/onsocialmedia' : (context) => const OnSocialMedia(),
      },
    );
  }
}
