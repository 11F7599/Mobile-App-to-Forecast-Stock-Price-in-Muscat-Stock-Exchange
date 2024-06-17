import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

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
              Navigator.of(context).pop();
              //Navigator.pushNamedAndRemoveUntil(context, '/', arguments: 3, (Route<dynamic> route) => false);
              },
             ),
             const Text('Menu', style: TextStyle(fontSize: 16)),
              ],),
          ],
          ),
          ),
          );
  }
}