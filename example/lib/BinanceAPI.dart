import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:interactive_chart/interactive_chart.dart'; // Import the 'dio' package

class BinanceAPI {
  static final _dio = Dio(); // Create an instance of the 'Dio' class

  static Future<List<ExtendedCandleData>> fetchPastTradesOfFutureBot(
      String symbol) async {
    final response = await _dio.get(
      "https://api.tradingwizardpro.com/formatted-candles",
      queryParameters: {'symbol': symbol},
    );

    if (response.statusCode == 200) {

      List<ExtendedCandleData> candles = (response.data as List)
          .map((candle) => ExtendedCandleData.fromJson(candle)).toList().reversed.toList();


      return candles;
    } else {
      throw Exception('Failed to load past trades from Lambda');
    }
  }
}

  


class ExtendedCandleData extends CandleData {
  ExtendedCandleData(
      {required int timestamp,
      double? open,
      double? high,
      double? low,
      double? close,
      double? volume,
      List<TradeData>? trades})
      : super(
            timestamp: timestamp,
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume,
            trades: trades);

  factory ExtendedCandleData.fromJson(Map<String, dynamic> json) {
    
    return ExtendedCandleData(
      timestamp: json['kline']['openTime'] as int ,
      open: json['kline']['open'] as double,
      high: json['kline']['high'] as double,
      low: json['kline']['low'] as double,
      close: json['kline']['close'] as double,
      volume: 0,
      trades: (json['orders'] as List?)
          ?.map<TradeData>((trade) => TradeData.fromJson(trade))
          .toList(),
    );
  }
}
