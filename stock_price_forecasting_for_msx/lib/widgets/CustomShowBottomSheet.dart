import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stock_price_forecasting_for_msx/widgets/showBottomSheetFilter.dart';

import 'CustomStockItem02.dart';

Future<void> customShowBottomSheet(BuildContext context) async {
  double screenHeight = MediaQuery.of(context).size.height;
  double statusBarHeight = MediaQuery.of(context).padding.top;
  double availableHeight = screenHeight - statusBarHeight - 67;

  TextEditingController searchController = TextEditingController();
  String selectedCategory = "All"; // Initialize with the default value

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
    ),
    backgroundColor: Colors.white,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: availableHeight,
            ),
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 36,
                        child: TextField(
                          controller: searchController,
                          onChanged: (query) {
                            setState(() {}); // Trigger a rebuild on text change
                          },
                          decoration: InputDecoration(
                            hintText: 'Search',
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 232, 238, 240),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            prefixIcon: const Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      child: Text(
                        'Close',
                        style: TextStyle(fontSize: 16, color: Colors.blue.shade800),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      child: const Icon(Icons.tune_outlined, size: 28, color: Color.fromARGB(255, 0, 0, 0)),
                      onTap: () async {
                        String? result = await showBottomSheetFilter(context, selectedCategory);
                        setState(() {
                          selectedCategory = result ?? "All"; // Use "All" if result is null
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: FutureBuilder(
                    future: FirebaseFirestore.instance.collection('stocks').get(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Image.asset('assets/images/loading_img02.gif', width: 300, height: 300);
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Text('No data available');
                      }

                      var stocksList = snapshot.data!.docs;

                      // Filter stocks based on search query and selected category
                      var filteredStocks = stocksList.where((stock) {
                        String tickerSymbol = stock.id.toLowerCase();
                        var stockData = stock.data() as Map<String, dynamic>;
                        String companyName = stockData['companyName'].toLowerCase();
                        //String tickerSymbol = stockData['tickerSymbol'].toLowerCase();
                        String searchQuery = searchController.text.toLowerCase();
                        String stockCategory = stockData['category'].toLowerCase();

                        bool matchesSearchQuery = companyName.contains(searchQuery) || tickerSymbol.contains(searchQuery);

                        if (selectedCategory == "All") {
                          // If selectedCategory is "All," include all categories
                          return matchesSearchQuery;
                        } else {
                          // If a specific category is selected, filter based on both category and search query
                          return matchesSearchQuery && stockCategory.toLowerCase() == selectedCategory.toLowerCase();
                        }
                      }).toList();

                      return ListView.builder(
                        itemCount: filteredStocks.length,
                        itemBuilder: (context, index) {
                          String tickerSymbol = filteredStocks[index].id;
                          var stock = filteredStocks[index].data() as Map<String, dynamic>;
                          //String stockID = stock['uniqueID'];
                          String? email = FirebaseAuth.instance.currentUser?.email;

                          // Check if the user is signed in
                          Future<bool> isStockInWatchlist = email != null
                              ? FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(email)
                                  .collection('watchlist')
                                  .doc(tickerSymbol)
                                  .get()
                                  .then((watchlistDoc) => watchlistDoc.exists)
                                  .then((exists) => exists)
                                  .catchError((error) {
                                    return false;
                                  })
                              : Future.value(false);

                          return FutureBuilder<bool>(
                            future: isStockInWatchlist,
                            builder: (context, snapshot) {
                              bool isWatchlisted = snapshot.data ?? false;
                              return CustomStockItem02(
                                companyName: stock['companyName'],
                                tickerSymbol: tickerSymbol,
                                category: stock['category'],
                                logo: stock['logo'],
                                isWatchlisted: isWatchlisted,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
