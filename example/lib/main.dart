import 'package:example/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interactive_chart/interactive_chart.dart';
import 'package:intl/intl.dart' as intl;

Future main() async {
  Get.put(ChartController()); // Initialize controller
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // Changed to GetMaterialApp
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final controller = Get.find<ChartController>(); // Find controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Interactive Chart Demo"),
        actions: [
          IconButton(
            icon: Obx(() => Icon(controller.darkMode.value
                ? Icons.dark_mode
                : Icons.light_mode)),
            onPressed: controller.toggleDarkMode,
          ),
          IconButton(
            icon: Obx(() => Icon(
                  controller.showAverage.value
                      ? Icons.show_chart
                      : Icons.bar_chart_outlined,
                )),
            onPressed: controller.toggleShowAverage,
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(24.0),
        child: Obx(() => (controller.candles.isEmpty)
            ? const Center(child: CircularProgressIndicator())
            : InteractiveChart(
              style: ChartStyle(
                priceGainColor: Colors.green,
                priceLossColor: Colors.red,
              ),
                candles: controller.candles.toList(),
                timeLabel: (timestamp, visibleDataCount) {
                  final date = DateTime.fromMillisecondsSinceEpoch(timestamp)
                      .toIso8601String()
                      .split("T")
                      .first
                      .split("-");

                  // Otherwise, we should show month and date.
                  return "${date[1]}-${date[2]}"; // mm-dd
                },
                overlayInfo: (candle) {
                  final date = intl.DateFormat('EEE, MMM d, H:mm').format(
                    DateTime.fromMillisecondsSinceEpoch(candle.timestamp));
                  var info = {
                    "Date": date,
                    "Open": candle.open?.toStringAsFixed(2) ?? "-",
                    "High": candle.high?.toStringAsFixed(2) ?? "-",
                    "Low": candle.low?.toStringAsFixed(2) ?? "-",
                    "Close": candle.close?.toStringAsFixed(2) ?? "-"
                  };

                  int buyCount = 1;
                  int sellCount = 1;

                  for (var trade in candle.trades!) {
                    if (trade.isBuyer) {
                      info["buy$buyCount"] =
                          "(Price: ${trade.price}, Quantity: ${trade.quantity})";
                      buyCount++;
                    } else {
                      info["sell$sellCount"] =
                          "(Price: ${trade.price}, Quantity: ${trade.quantity})";
                      sellCount++;
                    }
                  }

                  return info;
                },
              )),
      ),
    );
  }
}
