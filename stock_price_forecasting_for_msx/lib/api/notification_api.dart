import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print("User granted permission");
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional){
    print("User granted provisional permission");
  } else {
    print("User declined or has not accepted permission");
  }
}

void getToken(String email) async {
  await FirebaseMessaging.instance.getToken().then((token) {
    print("My token is $token");
    saveToken(token!, email);
  });
}

void saveToken(String token, String email) async {
  await FirebaseFirestore.instance.collection("users").doc(email).update({
    'token' : token,
  });
}


