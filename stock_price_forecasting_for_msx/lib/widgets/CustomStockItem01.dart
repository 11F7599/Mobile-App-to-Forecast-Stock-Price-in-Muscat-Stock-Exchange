import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stock_price_forecasting_for_msx/screens/auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'customShowBottomSheet_alert.dart';

class CustomStockItem01 extends StatefulWidget {
  final String companyName;
  final String tickerSymbol;
  final String closePrice;
  final String change;
  final String direction;
  final String volume;
  final String openPrice;
  final String highPrice;
  final String lowPrice;
  final String trades;
  final String predictedClosePrice;
  final Function(String) onDelete;


  CustomStockItem01({
    super.key,
    required this.companyName,
    required this.tickerSymbol,
    this.closePrice = "0.000",
    this.change = "0.000 (0%)",
    required this.direction,
    required this.volume,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.trades,
    required this.predictedClosePrice,
    required this.onDelete,
  });

  @override
  State<CustomStockItem01> createState() => _CustomStockItem01State();
}

class _CustomStockItem01State extends State<CustomStockItem01> {

  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late bool _isLoggedIn;
  String? userEmail;
  String? logoUrl;
  late bool _isMember = false;


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


  Future<void> isMember(String email) async {
    _isMember = await _authService.isMember(email); // Correctly await the future
    if (mounted) {
        setState(() {});
      }
  }

  @override
  void initState() {
    super.initState();
    _isLoggedIn = _authService.isLoggedIn(); // check if user is logged in or not
    if(_isLoggedIn){
    userEmail = _auth.currentUser?.email;
    isMember(userEmail!);
    }
    loadLogo();
  }


  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.black54;
    if (widget.direction == "up") {
      textColor = const Color.fromARGB(255, 59, 155, 62);
    } else if (widget.direction == "down") {
      textColor = Colors.red;
    }

    return GestureDetector(
      
      onTap: (){
        (_isMember || _isLoggedIn) ? Navigator.of(context).pushNamed('/stockdetails', arguments: {
        'tickerSymbol': widget.tickerSymbol.toString(), 
        'companyName': widget.companyName.toString(),
        'closePrice': widget.closePrice.toString(),
        'change': widget.change.toString(),
        'direction': widget.direction.toString(),
        'volume': widget.volume.toString(),
        'openPrice': widget.openPrice.toString(),
        'highPrice': widget.highPrice.toString(),
        'lowPrice': widget.lowPrice.toString(),
        'trades': widget.trades.toString(),
        'predictedClosePrice': widget.predictedClosePrice.toString(),
        'isMember': _isMember
        }) 
        : null;
        },
      child: Slidable(
        endActionPane: ActionPane(
          extentRatio: 0.3,
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                _isMember ? showCustomBottomSheet(context, widget.tickerSymbol, widget.closePrice, widget.change, textColor, userEmail!) : Navigator.of(context).pushNamed('/upgradeplan');
              },
              foregroundColor: Colors.blue,
              icon: Icons.alarm,
            ),
            SlidableAction(
              onPressed: (context) {
                (_isLoggedIn || _isMember) ? widget.onDelete(widget.tickerSymbol) : Navigator.of(context).pushNamed('/signin');
              },
              foregroundColor: Colors.pink.shade400,
              icon: Icons.delete,
            ),
          ],
        ),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 0.5, color: Color.fromARGB(255, 189, 189, 189)),
            ),
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
                      Text(widget.tickerSymbol, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 3),
                      Text(widget.companyName, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(double.parse(widget.closePrice).toStringAsFixed(3).toString(), style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 3),
                    Text(widget.change, style: TextStyle(fontSize: 14, color: textColor)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
