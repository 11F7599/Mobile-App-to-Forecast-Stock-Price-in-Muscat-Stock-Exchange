import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


void showCustomBottomSheet(BuildContext context, String tickerSymbol, String closePrice, String change, Color textColor, String userEmail) {
  double closePriceHold = double.parse(double.parse(closePrice).toStringAsFixed(3));
  double closePriceActive = double.parse(double.parse(closePrice).toStringAsFixed(3));
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) { 
        return Container(
          height: 200,
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Set Alert for $tickerSymbol'),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                  const Text("Price"),
                  Column(children: [
                    Text(closePriceActive.toString(), style: const TextStyle(fontSize: 18),), 
                    Text(change, style: TextStyle(color: textColor),)],),
                  Column(children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_up_rounded), // Specify the icon
                      iconSize: 30.0, // Set the size of the icon
                      color: Colors.blue, // Set the color of the icon
                      onPressed: () {
                        setState(() {
                                  closePriceActive = closePriceActive + 0.01;
                                  closePriceActive = double.parse(closePriceActive.toStringAsFixed(3));
                                });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded), // Specify the icon
                      iconSize: 30.0,
                      color: Colors.blue,
                      onPressed: () {
                        setState(() {
                                  closePriceActive = closePriceActive - 0.01;
                                  closePriceActive = double.parse(closePriceActive.toStringAsFixed(3));
                                });
                      },
                    ),
                  ],)
                ],),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: closePriceHold == closePriceActive 
                  ? Colors.grey 
                  : Colors.blue,
                    padding: const EdgeInsets.fromLTRB(50, 10, 50, 10)
                  ),
                  onPressed: closePriceHold == closePriceActive 
                  ? null
                  : () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userEmail)
                                  .collection('watchlist')
                                  .doc(tickerSymbol)
                                  .update({
                                    'onPrice': closePriceActive.toStringAsFixed(3),
                                    'onDirection': closePriceHold < closePriceActive? "up" : "down",
                                    'alert': true,
                                    });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Alert set successfully for $tickerSymbol at $closePriceActive')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to set alert: $e')),
                              );
                            } finally {
                              Navigator.pop(context);
                            }
                          },
                  child: const Text('Set Alert'),
                ),
              ],
            ),
          ),
        );
        },
      );
    },
  );
}