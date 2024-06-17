import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:stock_price_forecasting_for_msx/models/stock_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class StockDetails extends StatefulWidget {
  const StockDetails({Key? key}) : super(key: key);

  @override
  State<StockDetails> createState() => _StockDetailsState();
}

class _StockDetailsState extends State<StockDetails> {
  late String tickerSymbol;
  late String companyName;
  late String closePrice;
  late String change;
  late String direction;
  late String volume;
  late String openPrice;
  late String highPrice;
  late String lowPrice;
  late String trades;
  late String predictedClosePrice;
  late bool isMember;
  String? logoUrl;
  late List<StockData> stockDataList = [];
  late Future<List<StockData>> _stockDataFuture;


  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Map<String, dynamic> && args.containsKey('tickerSymbol')) {
      tickerSymbol = args['tickerSymbol'] as String;
      companyName = args['companyName'] as String;
      closePrice = args['closePrice'] as String;
      change = args['change'] as String;
      direction = args['direction'] as String;
      volume = args['volume'] as String;
      openPrice = args['openPrice'] as String;
      highPrice = args['highPrice'] as String;
      lowPrice = args['lowPrice'] as String;
      trades = args['trades'] as String;
      predictedClosePrice = args['predictedClosePrice'] as String;
      isMember = args['isMember'] as bool;
      loadLogo();
      _stockDataFuture = fetchStockData(tickerSymbol);
      fetchDataForDays(30);
      //fetchAndDisplayNewestData();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> loadLogo() async {
    try {
      // Load logo from Firebase Storage
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("logos").child('${tickerSymbol.toUpperCase()}.png');
      logoUrl = await ref.getDownloadURL();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {}
  }

Future<List<StockData>> fetchStockData(String symbol, [String? startDate, String? endDate]) async {
  String apiUrl = 'http://192.168.100.9:9000/stock/$symbol/';
  //String apiUrl = 'http://10.7.213.61:9000/stock/$symbol/';

  if (startDate != null && endDate != null) {apiUrl += 'filtered?start_date=$startDate&end_date=$endDate';}
  else{apiUrl += 'all';}

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => StockData.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load stock data');
  }
}


  Future<void> fetchDataForDays(int day) async {
    DateTime startDate = DateTime.now().subtract(Duration(days: day));
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    DateTime endDate = DateTime.now();
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    try {
      final List<StockData> newData = await fetchStockData(tickerSymbol, formattedStartDate, formattedEndDate);
      if (mounted) {
        setState(() {
          stockDataList = newData;
        });
      }
    } catch (e) {
      //print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error while fetching data')));
    }
  }



// Future<StockData> fetchNewestStockData(String symbol) async {
//   String apiUrl = 'http://192.168.100.9:9000/stock/$symbol/newest';
//   //String apiUrl = 'http://10.7.213.61:9000/stock/$symbol/';

//   final response = await http.get(Uri.parse(apiUrl));

//   if (response.statusCode == 200) {
//     return StockData.fromJson(jsonDecode(response.body));
//   } else {
//     throw Exception('Failed to load newest stock data');
//   }
// }

// void fetchAndDisplayNewestData() {
//   fetchNewestStockData(tickerSymbol).then((newestData) {
//     setState(() {
//       // Assuming you have fields to display these in your UI
//       price = newestData.closePrice.toString();
//       change = newestData.netChange.toString();
//       // You might need additional fields based on what's in StockData
//     });
//   }).catchError((error) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Failed to fetch newest data: $error'))
//     );
//   });
// }



  String interval = "1M";
  DateTimeAxis _buildDateTimeAxis() {
  if (interval == "5D") {
    return DateTimeAxis(interval: 2, rangePadding: ChartRangePadding.none);
  } 
  else {
    return DateTimeAxis(rangePadding: ChartRangePadding.none);
  }
}


  @override
  Widget build(BuildContext context) {
    Color textColor = const Color.fromARGB(137, 80, 77, 77);
    IconData directionIcon = Icons.compare_arrows;
    if (direction == "up") {
      textColor = const Color.fromARGB(255, 59, 155, 62);
      directionIcon = Icons.trending_up_outlined;
    } else if (direction == "down") {
      textColor = Colors.red;
      directionIcon = Icons.trending_down_outlined;
    }

    final List<Color> color = <Color>[];
    color.add(Colors.deepOrange[50]!);
    color.add(Colors.deepOrange[200]!);
    color.add(Colors.deepOrange);

    final List<double> stops = <double>[];
    stops.add(0.0);
    stops.add(0.5);
    stops.add(1.0);

    //final LinearGradient gradientColors = LinearGradient(colors: color, stops: stops);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children:[
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_outlined),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const Text('Back', style: TextStyle(fontSize: 16)),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent.shade200,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: logoUrl != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(logoUrl!, width: 50, height: 50),
                      )
                          : const Icon(Icons.image_not_supported, size: 30, color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                    Text(tickerSymbol, style: const TextStyle(fontSize: 14)),
                    Text(companyName, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            const Text("Close Price"),
                            Row(
                              children: [
                                Text(
                                  double.parse(closePrice).toStringAsFixed(3),
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const Text(
                                  "OMR",
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 5),
                        Column(
                          children: [
                            const Text("Predicted Price"),
                            isMember
                                ? (predictedClosePrice != 'N/A'
                                    ? Row(
                                        children: [
                                          Text(
                                            double.parse(predictedClosePrice).toStringAsFixed(3),
                                            style: const TextStyle(fontSize: 28),
                                          ),
                                          const Text(
                                            "OMR",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      )
                                    : Text(predictedClosePrice))
                                : GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushNamed('/upgradeplan');
                                    },
                                    child: const SizedBox(
                                      height: 32,
                                      width: 100,
                                      child: Card(
                                        color: Colors.deepPurpleAccent,
                                        child: Center(
                                          child: Text(
                                            "Premium",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(change, style: TextStyle(fontSize: 16, color: textColor)),
                        Icon(directionIcon, color: textColor),
                      ],
                    ),
                    Container(
                      child: FutureBuilder<List<StockData>>(
                        future: _stockDataFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final List<StockData>? data = snapshot.data;
                            if (data != null && data.isNotEmpty) {
                              return Container(
                                height:300,
                                child: SfCartesianChart(
                                  primaryXAxis: _buildDateTimeAxis(),
                                  primaryYAxis: NumericAxis(rangePadding: ChartRangePadding.additional),
                                  // Chart title
                                  //title: ChartTitle(text: 'Stock Data Analysis'),
                                  // Enable tooltip
                                  tooltipBehavior: TooltipBehavior(enable: true),
                                  series: <CartesianSeries<StockData, DateTime>>[
                                    //AreaSeries<StockData, DateTime>(
                                    LineSeries<StockData, DateTime>(
                                      dataSource: stockDataList,
                                      xValueMapper: (StockData data, _) => DateTime.parse(data.date),
                                      yValueMapper: (StockData data, _) => data.closePrice,
                                      name: 'Close Price',
                                      //gradient: gradientColors,
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return const Text('No stock data available.');
                            }
                          }
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(interval == "5D" ?const Color.fromARGB(220, 236, 234, 234):Colors.transparent), // Transparent background
                            shadowColor: MaterialStateProperty.all(Colors.transparent), // No shadow
                            overlayColor: MaterialStateProperty.all(const Color.fromARGB(186, 223, 77, 77).withOpacity(0.1)), // Slight overlay color on press
                            elevation: MaterialStateProperty.all(0), // No elevation
                            foregroundColor: MaterialStateProperty.all(Colors.black),
                          ),
                          onPressed: () {
                            setState(() {
                              interval = "5D";
                            });
                            fetchDataForDays(5);
                          },
                          child: const Text('5D'),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(interval == "1M" ?const Color.fromARGB(220, 236, 234, 234):Colors.transparent), // Transparent background
                            shadowColor: MaterialStateProperty.all(Colors.transparent), // No shadow
                            overlayColor: MaterialStateProperty.all(const Color.fromARGB(186, 223, 77, 77).withOpacity(0.1)), // Slight overlay color on press
                            elevation: MaterialStateProperty.all(0), // No elevation
                            foregroundColor: MaterialStateProperty.all(Colors.black),
                          ),
                          onPressed: () {
                            setState(() {
                              interval = "1M";
                            });
                            fetchDataForDays(30);
                          },
                          child: const Text('1M'),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(interval == "3M" ?const Color.fromARGB(220, 236, 234, 234):Colors.transparent), // Transparent background
                            shadowColor: MaterialStateProperty.all(Colors.transparent), // No shadow
                            overlayColor: MaterialStateProperty.all(const Color.fromARGB(186, 223, 77, 77).withOpacity(0.1)), // Slight overlay color on press
                            elevation: MaterialStateProperty.all(0), // No elevation
                            foregroundColor: MaterialStateProperty.all(Colors.black),
                          ),
                          onPressed: () {
                            setState(() {
                              interval = "3M";
                            });
                            fetchDataForDays(90);
                          },
                          child: const Text('3M'),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(interval == "6M" ?const Color.fromARGB(220, 236, 234, 234):Colors.transparent), // Transparent background
                            shadowColor: MaterialStateProperty.all(Colors.transparent), // No shadow
                            overlayColor: MaterialStateProperty.all(const Color.fromARGB(186, 223, 77, 77).withOpacity(0.1)), // Slight overlay color on press
                            elevation: MaterialStateProperty.all(0), // No elevation
                            foregroundColor: MaterialStateProperty.all(Colors.black),
                          ),
                          onPressed: () {
                            setState(() {
                              interval = "6M";
                            });
                            fetchDataForDays(180);
                          },
                          child: const Text('6M'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text("VOLUME", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                            Text(volume),
                          ],
                        ),
                        Column(
                          children: [
                            const Text("TRADES", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                            Text(trades),
                          ],
                        ),
                        Column(
                          children: [
                            const Text("OPEN", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                            Text(openPrice),
                          ],
                        ),
                        Column(
                          children: [
                            const Text("HIGH", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                            Text(highPrice),
                          ],
                        ),
                        Column(
                          children: [
                            const Text("LOW", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                            Text(lowPrice),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
