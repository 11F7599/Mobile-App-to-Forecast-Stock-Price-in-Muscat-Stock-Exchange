import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:stock_price_forecasting_for_msx/screens/auth_service.dart';
import 'package:stock_price_forecasting_for_msx/widgets/CustomStockItem01.dart';
import 'package:stock_price_forecasting_for_msx/widgets/CustomShowBottomSheet.dart';
import 'package:stock_price_forecasting_for_msx/screens/auth_service.dart';
import 'package:stock_price_forecasting_for_msx/widgets/showBottomSheet_alertList.dart';

class Watchlist extends StatefulWidget {
  const Watchlist({Key? key}) : super(key: key);

  @override
  State<Watchlist> createState() => _WatchlistState();
}

class _WatchlistState extends State<Watchlist> {

  //final AuthService _authService = AuthService();
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  //late bool _isLoggedIn;
  final AuthService _authService = AuthService();
  late String? email;
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

  @override
  void initState() {
    super.initState();
    email = FirebaseAuth.instance.currentUser?.email;
    isLoggedIn();
    if(_isLoggedIn){ isMember(email!); }
  }

  Future<void> deleteStockFromWatchlist(String docId) async {
  try { 
    // Reference to the user's watchlist collection
    CollectionReference watchlistCollectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('watchlist');
    
    // Delete the document
    await watchlistCollectionRef.doc(docId).delete();
    
    // Show a success message or handle the UI update after successful deletion
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$docId removed from watchlist')));
  } catch (e) {
    // Handle errors, e.g., show an error message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error removing stock: $e')));
  }
}

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(flex: 3, child: Container()),
                Expanded(flex: 3, child: Image.asset('assets/images/MSX_logo.png', width: 16, height: 21,)),
                Expanded(
                  flex: 3,
                  child: Row(
                    //mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _isMember ?
                      GestureDetector(
                        child: const Icon(Icons.notifications_none_rounded, size: 33),
                        onTap: () { showBottomSheet_alertList(context, email!); },
                        ): Container(),
                      const SizedBox(width: 1),  
                      GestureDetector(
                        child: const Icon(Icons.add_outlined, size: 33),
                        onTap: () {
                          (_isLoggedIn || _isMember) ? customShowBottomSheet(context) : Navigator.of(context).pushNamed('/signin');
                        },
                        ),
                      const SizedBox(width: 1),
                      const Icon(Icons.more_horiz_rounded, size: 33),
                    ],
                  ),
                ),
              ],
            ),
            const Row(
              children: [
                Text('Watchlist', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),)
              ],
            ),
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text('Stocks', style: TextStyle(fontSize: 16),),
                )
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
              stream: email != null ? FirebaseFirestore.instance.collection('users').doc(email).collection('watchlist').snapshots()
                                    : FirebaseFirestore.instance.collection('promotion').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> watchlistSnapshot) {
                if (watchlistSnapshot.connectionState == ConnectionState.waiting) {
                  //return const CircularProgressIndicator();
                  return Image.asset('assets/images/loading_img.gif', width: 400, height: 400);
                }

                if (watchlistSnapshot.hasError) {
                  return Text('Error: ${watchlistSnapshot.error}');
                }

                if (!watchlistSnapshot.hasData || watchlistSnapshot.data == null) {
                  return const Text('No watchlist available for this user');
                }

                var watchlistStocks = watchlistSnapshot.data!.docs;

                return StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('stocks').snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> stocksSnapshot) {
                    if (stocksSnapshot.connectionState == ConnectionState.waiting) {
                      return Image.asset('assets/images/loading_img.gif', width: 400, height: 400);
                    }

                    if (stocksSnapshot.hasError) {
                      return Text('Error: ${stocksSnapshot.error}');
                    }

                    if (!stocksSnapshot.hasData || stocksSnapshot.data == null) {
                      return const Text('No data available');
                    }

                    var stocksList = stocksSnapshot.data!.docs;

                    // Filter stocks based on watchlist
                    var filteredStocks = stocksList.where((stock) {
                      var stockId = stock.id;
                      return watchlistStocks.any((watchlistStock) => watchlistStock.id == stockId);
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredStocks.length,
                      itemBuilder: (context, index) {
                        String tickerSymbol = filteredStocks[index].id;
                        var stock = filteredStocks[index].data() as Map<String, dynamic>;
                        return CustomStockItem01(
                          companyName: stock['companyName'],
                          tickerSymbol: tickerSymbol,
                          closePrice: stock['closePrice'],
                          change: stock['change'],
                          direction: stock['direction'],
                          volume: stock['volume'],
                          openPrice: stock['openPrice'],
                          highPrice: stock['highPrice'],
                          lowPrice: stock['lowPrice'],
                          trades: stock['trades'],
                          predictedClosePrice: stock['predictedClosePrice'] ?? "N/A",
                          onDelete: deleteStockFromWatchlist,
                        );
                      },
                    );
                  },
                );
              },
            )
            ),
          ],
        ),
      ),
    );
  }
}
