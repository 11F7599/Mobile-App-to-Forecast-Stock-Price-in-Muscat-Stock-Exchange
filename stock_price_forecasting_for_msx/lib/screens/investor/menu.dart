import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/CustomGestureDetector01.dart';
import '../auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {

  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late bool _isLoggedIn;
  late Map<String, dynamic> _userinfo;
  late bool _isMember = false;
  String? userEmail;
  String? expireDate = "Upgrade";


  Future<void> isMember(String email) async {
    _isMember = await _authService.isMember(email); // Correctly await the future
    if (_isMember) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('membership').doc(email).get();
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      DateTime expireDateTime = data['expireDate'].toDate();
      expireDate = DateFormat('dd MMM yyyy').format(expireDateTime).toString();
    }
    if (mounted) {
        setState(() {});
      }
  }


  @override
  void initState() {
    super.initState();
    _isLoggedIn = _authService.isLoggedIn(); // check if user is logged in or not
    _userinfo = {};
    getUserInformation();

    if(_isLoggedIn){
    userEmail = _auth.currentUser?.email;
    isMember(userEmail!);
    }
  }

//   void getUserInformation() {
//     if(_isLoggedIn){
//     String? userEmail = _auth.currentUser?.email;
//     if (userEmail != null){
//     Stream<Map<String, dynamic>> userInfoStream = _authService.getUserInfoStream(userEmail); // get user info
//     userInfoStream.listen((Map<String, dynamic> data) {
//         setState(() {
//           _userinfo = data;
//         });
//     });
//     }
//     }
// }

void getUserInformation() async {
  if (_isLoggedIn) {
    String? userEmail = _auth.currentUser?.email;
    if (userEmail != null) {
      Map<String, dynamic> userInfo = await _authService.getUserInfo(userEmail); // Fetch user info asynchronously
      setState(() {
        _userinfo = userInfo;
      });
    }
  }
}

void signOut() async {
bool signOut = await _authService.signOut();
if (signOut){
setState(() {
  _isLoggedIn = false;
  expireDate = "Upgrade";
  });
ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('sign out successfully')));
}  
else{
ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('sign out failed')),);
}
}


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 41, 12, 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 33),
                child: Row(
                  children: [
                    Text('Menu', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),)
                  ],
                ),
              ),
              //Premium Access Button
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0),color: Colors.pinkAccent.shade400,),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Premium Access', style: TextStyle(fontWeight: FontWeight.bold, color:Colors.white),),
                        Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.0),color: Colors.white,), 
                          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                          child: _isMember ? Text(expireDate!) : const Text('Upgrade'),
                          ),
                      ],
                    ),
                  ),
                ),
                onTap: (){
                  if(_isLoggedIn){
                  Navigator.of(context).pushNamed('/upgradeplan');
                  } else{
                  Navigator.of(context).pushNamed('/upgradeplan');
                  Navigator.of(context).pushNamed('/signin');
                }},
              ),
              //Sign in Button
              GestureDetector(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0),color: const Color.fromARGB(255, 232, 238, 240)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 25),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: _isLoggedIn
                                ? Text(
                                    _userinfo.containsKey("displayname") ? _userinfo["displayname"].toString() : "loading.."
                                  )
                                : const Text('Sign in'),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: (){
                  if(_isLoggedIn) { Navigator.of(context).pushNamed('/profile'); }
                  else { Navigator.of(context).pushNamed('/signin'); }
                  },
              ),
              // Setting & Chat Buttons
              Row(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GestureDetector(child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0),color: const Color.fromARGB(255, 232, 238, 240)),
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Column(
                          children: [
                            Icon(Icons.settings_outlined, size: 23),
                            Text('Settings')
                          ],
                        ),
                      ),
                    ),
                    onTap: (){},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0),color: const Color.fromARGB(255, 232, 238, 240)),
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Column(
                          children: [
                            Icon(Icons.chat_outlined, size: 23),
                            Text('Chat')
                          ],
                        ),
                      ),
                    ),
                    onTap: (){},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              //Brokers Button
              CustomGestureDetector01(
                iconName: Icons.business, 
                name: 'Brokers', 
                arrow: Icons.arrow_right_outlined, 
                onTap: () { Navigator.of(context).pushNamed('/brokers'); },
              ),
              const SizedBox(height: 15),
              //Share app
              CustomGestureDetector01(
                iconName: Icons.share, 
                name: 'Share app',  
                onTap: () {},
              ),
              //Rate us
              CustomGestureDetector01(
                iconName: Icons.rate_review_outlined, 
                name: 'Rate us',  
                onTap: () {},
              ),
              const SizedBox(height: 15),
              //Social media
              CustomGestureDetector01(
                iconName: Icons.alternate_email_outlined, 
                name: 'Social media',  
                arrow: Icons.arrow_right_outlined,
                onTap: () { Navigator.of(context).pushNamed('/onsocialmedia'); },
              ),
              //About
              CustomGestureDetector01(
                iconName: Icons.info_outline, 
                name: 'About',  
                arrow: Icons.arrow_right_outlined,
                onTap: () {},
              ),
              const SizedBox(height: 15),
              //Sign out
              _isLoggedIn ?
              CustomGestureDetector01(
                iconName: Icons.logout_outlined, 
                name: 'Sign out',
                color: Colors.pinkAccent.shade400, 
                onTap: () {
                  signOut();
                  },
              ) : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}