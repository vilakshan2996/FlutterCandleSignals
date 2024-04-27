import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interactive_chart/interactive_chart.dart';

class BinanceAPI {
  static Future<List<ExtendedCandleData>> fetchPastTrades() async {
    final response = await http.get(Uri.parse(
        "https://ivpyvhkvxpb2cov4xtz7ttsoi40bjsnq.lambda-url.ap-south-1.on.aws/"));

    if (response.statusCode == 200) {
      var result = json.decode(response.body);

      // Ensure that 'tradeData' is actually part of the JSON structure

      List<ExtendedCandleData> candles = result['candlestickData']
          .map<ExtendedCandleData>((candle) => ExtendedCandleData.fromJson(candle))
          .toList();

     
        

      return candles;
    } else {
      throw Exception('Failed to load past trades from Lambda');
    }
  }

  
}

  


class ExtendedCandleData extends CandleData {
  ExtendedCandleData({
    required int timestamp,
    double? open,
    double? high,
    double? low,
    double? close,
    double? volume,
    List<TradeData>? trades

  }) : super(
          timestamp: timestamp,
          open: open,
          high: high,
          low: low,
          close: close,
          volume: volume,
          trades: trades
        );

  factory ExtendedCandleData.fromJson(Map<String, dynamic> json) {
    print(json['trades']);
    return ExtendedCandleData(
      timestamp: json['timestamp'] as int,
      open: (json['open'] as num?)?.toDouble(),
      high: (json['high'] as num?)?.toDouble(),
      low: (json['low'] as num?)?.toDouble(),
      close: (json['close'] as num?)?.toDouble(),
      volume: (json['volume'] as num?)?.toDouble(),
      trades: (json['trades'] as List?)
          ?.map<TradeData>((trade) => TradeData.fromJson(trade))
          .toList(),
    );
  }

}


