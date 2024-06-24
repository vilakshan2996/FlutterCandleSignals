import 'package:example/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interactive_chart/interactive_chart.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/intl.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ChartController()); // Initialize controller
  runApp(GetMaterialApp(
      // Changed to GetMaterialApp
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
      themeMode: (Get.find<ChartController>().isDarkModeOn.value)
          ? ThemeMode.dark
          : ThemeMode.light,
        theme: ThemeData(
        brightness: (Get.find<ChartController>().isDarkModeOn.value) ? Brightness.dark : Brightness.light,
      ),
      
  ));
}


class HomeScreen extends StatelessWidget {
  final controller = Get.find<ChartController>(); // Find controller
  String lastProcessedDate = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Interactive Chart Demo"),
        actions: [
          IconButton(
            icon: Obx(() => Icon(controller.isDarkModeOn.value
                ? Icons.dark_mode
                : Icons.light_mode)),
            onPressed: controller.toggleTheme
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
            : Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: InteractiveChart(
                style: ChartStyle(
                  priceGainColor: Colors.green,
                  priceLossColor: Colors.red,
                ),
                  candles: controller.candles.toList(),
                  timeLabel: (timestamp, visibleDataCount) {
                    final dateTime =
                        DateTime.fromMillisecondsSinceEpoch(timestamp);
                    final dateFormat = DateFormat('MM-dd'); // Format for month and date
                    final monthAndDate = dateFormat.format(dateTime); // 'MM-dd'
                    final time = dateTime
                        .toIso8601String()
                        .split("T")[1]
                        .substring(0, 5); // hh:mm
              
                    String label;
              
                    // Check if the current date is the same as the last processed date.
                    if (monthAndDate == lastProcessedDate) {
                      // If it is, we only show the hour and minute.
                      label = "$time\n"; // hh:mm
                    } else {
                      // If it's a new date, we update the lastProcessedDate and show date, hour, and minute.
                      lastProcessedDate = monthAndDate;
                      label = "$monthAndDate\n$time\n"; // yyyy-mm-dd hh:mm
                    }
              
                    return label;
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
                ),
            )),
      ),
    );
  }
}
