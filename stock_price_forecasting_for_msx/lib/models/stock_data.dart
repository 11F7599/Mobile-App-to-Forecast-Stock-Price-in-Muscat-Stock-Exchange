class StockData {
  final String date;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final int trades;
  final int volume;
  final int turnover;
  final double closePrice;
  final double netChange;
  final double percentageChange;

  StockData({
    required this.date,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.trades,
    required this.volume,
    required this.turnover,
    required this.closePrice,
    required this.netChange,
    required this.percentageChange,
  });

  factory StockData.fromJson(Map<String, dynamic> json) {
    return StockData(
      date: json['date'],
      openPrice: json['open_price'],
      highPrice: json['high_price'],
      lowPrice: json['low_price'],
      trades: json['trades'],
      volume: json['volume'],
      turnover: json['turnover'],
      closePrice: json['close_price'],
      netChange: json['net_change'],
      percentageChange: json['percentage_change'],
    );
  }
}
