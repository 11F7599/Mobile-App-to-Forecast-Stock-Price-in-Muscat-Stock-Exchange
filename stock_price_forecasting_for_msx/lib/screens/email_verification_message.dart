import 'package:flutter/material.dart';

class EmailVerificationMessage extends StatelessWidget {
  const EmailVerificationMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/success.gif', width: 220, height: 180),
                const Text(
                  "Your account has been created successfully",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 10),
                const Text(
                  "Congratulations! You're now part of MSX+, your go-to tool for forecasting stock prices of companies listed on the MSX Muscat Stock Exchange. Welcome aboard!",
                  style: TextStyle(fontSize: 14, color: Color.fromARGB(183, 61, 61, 61)),
                  textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  //Continue
                  GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0),color: Colors.blue,),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('Continue', style: TextStyle(color: Colors.white),),
                          ),
                        ],
                      ),
                    ),
                    onTap: (){
                      Navigator.pushNamedAndRemoveUntil(context, '/mainscaffold', (Route<dynamic> route) => false);
                      //Navigator.pushNamedAndRemoveUntil(context, '/', arguments: 0, (Route<dynamic> route) => false);
                      },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}