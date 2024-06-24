import 'package:example/BinanceAPI.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interactive_chart/interactive_chart.dart';

class ChartController extends GetxController {
  RxList<ExtendedCandleData> candles = <ExtendedCandleData>[].obs;
  final RxBool isDarkModeOn = true.obs;
  final RxBool showAverage = false.obs;

  @override
  void onInit() async {
    await fetchPastTrades();
    super.onInit();
  }

  Future<void> fetchPastTrades() async {
    candles.value = await BinanceAPI.fetchPastTradesOfFutureBot('BNBUSDT');
  }

  
  //toggle dark, light mode
  void toggleTheme() {
    isDarkModeOn.value = !isDarkModeOn.value;
    Get.changeTheme(isDarkModeOn.value ? ThemeData.dark() : ThemeData.light());
  }

  

  void toggleShowAverage() {
    showAverage.toggle();
    if (showAverage.value) {
      computeTrendLines();
    } else {
      removeTrendLines();
    }
  }

  void computeTrendLines() {
    final ma7 = CandleData.computeMA(candles, 7);
    final ma30 = CandleData.computeMA(candles, 30);
    final ma90 = CandleData.computeMA(candles, 90);

    for (int i = 0; i < candles.length; i++) {
      candles[i].trends = [ma7[i], ma30[i], ma90[i]];
    }
  }

  void removeTrendLines() {
    for (final data in candles) {
      data.trends = [];
    }
  }
}
