import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stock_price_forecasting_for_msx/screens/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CustomStockItem02 extends StatefulWidget {
  final String companyName;
  final String tickerSymbol;
  final String category;
  final String? logo;
  late bool isWatchlisted;

  CustomStockItem02({
    super.key,
    required this.companyName,
    required this.tickerSymbol,
    required this.category,
    this.logo,
    this.isWatchlisted = false,
  });

  @override
  State<CustomStockItem02> createState() => _CustomStockItem02State();
}

class _CustomStockItem02State extends State<CustomStockItem02> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? email = FirebaseAuth.instance.currentUser?.email;
  bool isOperationInProgress = false;
  String? logoUrl;
  final AuthService _authService = AuthService();
  late bool _isMember = false;
  late bool _isLoggedIn = false;

  Future<void> isMember(String email) async {
    _isMember = await _authService.isMember(email);
    if (mounted) {
        setState(() {});
      }
  }

  Future<void> isLoggedIn() async {
    _isLoggedIn = _authService.isLoggedIn(); 
    if (mounted) {
        setState(() {});
      }
  }

  void removeStockFromWatchlist(stockID) async {
    try {
      setState(() {
        isOperationInProgress = true;
      });

      await _firestore
          .collection('users')
          .doc(email)
          .collection('watchlist')
          .doc(stockID)
          .delete();

      if (mounted) {
        setState(() {
          widget.isWatchlisted = false;
        });
      }
    } catch (e) {
      // Handle the error
      print('Error removing stock from watchlist: $e');
    } finally {
      if (mounted) {
        setState(() {
          isOperationInProgress = false;
        });
      }
    }
  }

  void addStockInWatchlist(stockID) async {
    try {
      setState(() {
        isOperationInProgress = true;
      });

      await _firestore
          .collection('users')
          .doc(email)
          .collection('watchlist')
          .doc(stockID)
          .set({'alert': false});

      if (mounted) {
        setState(() {
          widget.isWatchlisted = true;
        });
      }
    } catch (e) {
      // Handle the error
      print('Error adding stock to watchlist: $e');
    } finally {
      if (mounted) {
        setState(() {
          isOperationInProgress = false;
        });
      }
    }
  }

  Future<void> loadLogo() async {
    try {
      // Load logo from Firebase Storage
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("logos").child('${widget.tickerSymbol.toUpperCase()}.png');
      logoUrl = await ref.getDownloadURL();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {}
  }


  @override
  void initState() {
    super.initState();
    isLoggedIn();
    isMember(email!);
    loadLogo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 0.5, color: Color.fromARGB(255, 189, 189, 189))),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: logoUrl != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(logoUrl!, width: 30, height: 30),
                      )
                      : const Icon(Icons.image_not_supported, size: 30, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(widget.tickerSymbol,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 6),
                        Container(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 1),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 184, 184, 184),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(widget.category,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14))),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(widget.companyName,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              isOperationInProgress
                  ? Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 3),
                          child: const CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        widget.isWatchlisted
                            ? GestureDetector(
                                child: const Icon(Icons.check,
                                    size: 28,
                                    color: Color.fromARGB(255, 0, 0, 0)),
                                onTap: () {
                                  (_isMember || _isLoggedIn) ? removeStockFromWatchlist(widget.tickerSymbol) : Navigator.of(context).pushNamed('/signin');
                                })
                            : GestureDetector(
                                child: const Icon(Icons.add,
                                    size: 28,
                                    color: Color.fromARGB(255, 0, 0, 0)),
                                onTap: () {
                                  (_isMember || _isLoggedIn) ? addStockInWatchlist(widget.tickerSymbol) : Navigator.of(context).pushNamed('/signin');
                                }),
                      ],
                    ),
            ],
          ),
        ), // Add margin here
      ),
      onTap: () {},
    );
  }
}
