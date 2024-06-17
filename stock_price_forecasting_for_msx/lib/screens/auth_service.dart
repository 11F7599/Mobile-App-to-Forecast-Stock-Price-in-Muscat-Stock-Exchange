import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_admin/firebase_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:mailer/mailer.dart';
//import 'package:mailer/smtp_server.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream to notify about changes to the user's sign-in state
  Stream<User?> get user => _auth.authStateChanges();

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (error) {
      //print(error);
      throw error;
    }
  }


// Sign up with email and password
void signUpWithEmailAndPassword(
    String email, 
    String password, 
    int phone, 
    String displayname, 
    Function(bool success, String? errorMessage) completion) async {
  late UserCredential result;
  try {
    result = await _auth.createUserWithEmailAndPassword(email: email, password: password);

    // Store additional user info in Firestore
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
    await usersCollection.doc(email.toLowerCase()).set({
      "displayname": displayname,
      "phone": phone,
      "role": "normal",
    });


    // Create watchlist collection 
    final CollectionReference promotionCollection = FirebaseFirestore.instance.collection('promotion');
    // Get document IDs from the 'promotion' collection
    final promotionSnapshot = await promotionCollection.get();
    final watchlistDocIds = promotionSnapshot.docs.map((doc) => doc.id).toList();
    // Add watchlist documents to the user document
    final watchlistCollectionRef = usersCollection.doc(email.toLowerCase()).collection('watchlist');
    for (final watchlistDocId in watchlistDocIds) {
    final watchlistDocRef = watchlistCollectionRef.doc(watchlistDocId);
    // Add a default property or leave it empty, depending on your use case
    await watchlistDocRef.set({});
    }



    // Send email verification
    await result.user!.sendEmailVerification();

    completion(true, null); // Success
  } catch (error) {
    if (error is FirebaseAuthException) {
      completion(false, 'Signup failed: ${error.message}');
    } else {
      // Optional: Cleanup by deleting the user if Firestore operation fails
      try {
        if (result.user != null) {
          await result.user!.delete();
        }
      } catch (deleteError) {
        completion(false, 'Signup failed: ${deleteError.toString()}');
        return;
      }
      
      completion(false, 'Signup failed: ${error.toString()}');
    }
  }
}


  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential result = await _auth.signInWithCredential(credential);
        return result.user;
      }
      return null;
    } catch (error) {
      print(error);
      return null;
    }
  }


  // Sign out
  Future<bool> signOut() async {
    try {
    await _googleSignIn.signOut();
    await _auth.signOut();
    return true;
    //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('sign out successfully')));
    //Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      return false;
    //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('sign out failed')),);
    }
  }

  // Check if the user is logged in
  bool isLoggedIn() {
    final User? currentUser = _auth.currentUser;
    return currentUser != null;
  }

  Future<bool> isMember(String email) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('membership').doc(email).get();


    if (documentSnapshot.exists) {
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      if (data.containsKey('expireDate')) {
        Timestamp expireTimestamp = data['expireDate'];
        DateTime expireDate = expireTimestamp.toDate();
        DateTime currentDate = DateTime.now();
        
        // Check if the expireDate is in the future
        if (expireDate.isAfter(currentDate)) {
          return true;
        }
      }
    }
    return false;
  }

  // // Get user role
  // Future<String> getUserRole(User user) async {
  //   // Assuming the role is stored as a custom claim, otherwise adjust accordingly
  //   final idTokenResult = await user.getIdTokenResult(true);
  //   final claims = idTokenResult.claims;
    
  //   if (claims != null && claims.containsKey('role')) {
  //     return claims['role'];
  //   } else {
  //     // Default to 'normal' if no role specified
  //     return 'normal';
  //   }
  // }


//Function to delete an account after failure in the verification process
Future<void> deleteAnAccount(Function(bool success, String? errorMessage) completion) async {
  try {
    // Delete user info from Firestore
    final String? userEmail = _auth.currentUser?.email;
    if (userEmail != null) {
      final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
      final DocumentReference userDocRef = usersCollection.doc(userEmail);
      
      // Delete the user document
      await userDocRef.delete();

      // Delete the 'watchlist' subcollection
      final CollectionReference watchlistCollection = userDocRef.collection('watchlist');
      final QuerySnapshot watchlistDocs = await watchlistCollection.get();
      final List<Future<void>> deletionFutures = [];
      
      for (final docSnapshot in watchlistDocs.docs) {
        deletionFutures.add(docSnapshot.reference.delete());
      }

      await Future.wait(deletionFutures);
    }

    // Delete user from FirebaseAuth
    await _auth.currentUser?.delete();

    completion(true, 'Registration canceled successfully'); // Success
  } catch (e) {
    if (e is FirebaseAuthException) { 
      if (e.code == 'requires-recent-login') {
        await _auth.signOut();
        await _googleSignIn.signOut();
        completion(false, 'Re-sign in required');
      } else {
        completion(false, 'Something went wrong: ${e.code}');
      }
    } else {
      completion(false, 'Something went wrong: ${e.toString()}');
    }
  }
}



//Function to send verification email
Future<void> sendVerificationEmail(Function(bool success, String? errorMessage) completion) async {
  try {
    await _auth.currentUser!.sendEmailVerification();
    completion(true, null); // Success
  } catch (e) {
    completion(false, 'verification failed: ${e.toString()}');
  }
}


// Function to get user info with real-time updates
Stream<Map<String, dynamic>> getUserInfoStream(String documentId) {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  return users.doc(documentId).snapshots().map((DocumentSnapshot snapshot) {
    if (!snapshot.exists) {
      return {"error": "Document does not exist"};
    }

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return data;
  });
}


Future<Map<String, dynamic>> getUserInfo(String documentId) async {
  DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(documentId).get();

  if (!snapshot.exists) {
    return {"error": "Document does not exist"};
  }

  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  return data;
}



}
