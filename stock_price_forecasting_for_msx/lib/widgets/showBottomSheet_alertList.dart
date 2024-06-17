import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void showBottomSheet_alertList(BuildContext context, String userEmail) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
    ),
    builder: (BuildContext context) {
      return AlertListBottomSheet(userEmail: userEmail);
    },
  );
}

class AlertListBottomSheet extends StatefulWidget {
  final String userEmail;

  const AlertListBottomSheet({Key? key, required this.userEmail}) : super(key: key);

  @override
  _AlertListBottomSheetState createState() => _AlertListBottomSheetState();
}

class _AlertListBottomSheetState extends State<AlertListBottomSheet> {
  late Future<List<Map<String, dynamic>>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _alertsFuture = _fetchAlerts();
  }

  Future<List<Map<String, dynamic>>> _fetchAlerts() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot userDoc = await firestore.collection('users').doc(widget.userEmail).get();

    List<Map<String, dynamic>> alerts = [];

    if (userDoc.exists) {
      QuerySnapshot watchlistSnapshot = await firestore
          .collection('users')
          .doc(widget.userEmail)
          .collection('watchlist')
          .where('alert', isEqualTo: true)
          .get();

      for (var doc in watchlistSnapshot.docs) {
        alerts.add({
          'stockId': doc.id,
          'onPrice': doc.get('onPrice'),
        });
      }
    }
    return alerts;
  }

  Future<void> _deleteAlert(String stockId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore
        .collection('users')
        .doc(widget.userEmail)
        .collection('watchlist')
        .doc(stockId)
        .update({'alert': false});
    setState(() {
      _alertsFuture = _fetchAlerts(); // Refresh the list after deletion
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 300, // Adjust height as needed
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            'Active Alert List',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20), // Space between title and list
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _alertsFuture,
              builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching alerts'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No alerts found'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var alert = snapshot.data![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color.fromARGB(255, 232, 238, 240),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: Text(
                                      '${alert['stockId']}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text('On price: ${alert['onPrice']}'),
                                ],
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await _deleteAlert(alert['stockId']);
                                },
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.pinkAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
