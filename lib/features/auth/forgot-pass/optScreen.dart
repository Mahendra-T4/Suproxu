import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suproxu/core/service/connectivity/connectivity_service.dart';
import 'package:suproxu/core/service/page/not_connected.dart';


class Optscreen extends StatefulWidget {
  const Optscreen({super.key});

  @override
  State<Optscreen> createState() => _OptscreenState();
}

class _OptscreenState extends State<Optscreen> {
  final List<Map<String, dynamic>> data = [
    {
      'symbol': 'BANKNIFTY',
      'date': '31-Jul',
      'ltp': '5153.60',
      'sell': '5145.20',
      'buy': '5155.60',
      'low': '5130.30',
      'high': '5165.01',
    },
    {
      'symbol': 'AARTIIND',
      'date': '29-Aug',
      // 'change': '-1.8',
      'ltp': '7420.81',
      'sell': '7410.10',
      'buy': '7420.80',
      'low': '7320.95',
      'high': '7520.50',
    },
    {
      'symbol': 'BPCL',
      'date': '29-Aug',
      //'change': '-2.8',
      'ltp': '3480.50',
      'sell': '3410.40',
      'buy': '3480.50',
      'low': '3410.10',
      'high': '3520.45',
    },
    {
      'symbol': 'TATACHEM',
      'date': '29-Aug',
      //'change': '-20.1',
      'ltp': '1090.40',
      'sell': '1090.50',
      'buy': '1091.40',
      'low': '1082.10',
      'high': '1106.75',
    },
    {
      'symbol': 'EXIDEIND',
      'date': '29-Aug',
      // 'change': '-5.2',
      'ltp': '5130.30',
      'sell': '5110.20',
      'buy': '5130.30',
      'low': '5061.25',
      'high': '5230.75',
    },
  ];

  @override
  Widget build(BuildContext context) {
     final connectivity = context.watch<ConnectivityService>();
    return DefaultTabController(
      length: 5, // Number of tabs
      child: connectivity.isConnected ? Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            const SizedBox(height: 8),
            const Row(
              children: [
                SizedBox(
                  height: 29,
                  width: 392,
                  child: Text(
                    "    SYMBOLS                        SELL                 BUY",
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ),
              ],
            ),
            // Data list
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Row 1: Symbol and Date
                        /*Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['symbol'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  item['date'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[900],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  item['sell'],
                                  style: TextStyle(fontSize: 22, color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  item['buy'],
                                  style: TextStyle(fontSize: 22, color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),*/
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Symbol and Date Column
                            Expanded(
                              flex: 3, // Allocate more space for the symbol
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['symbol'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['date'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[900],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Sell Column
                            Expanded(
                              flex: 2, // Allocate less space for Sell
                              child: Text(
                                item['sell'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Buy Column
                            Expanded(
                              flex: 2, // Allocate less space for Buy
                              child: Text(
                                item['buy'],
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8), // Space between rows
                        // Row 2: Additional Details (LTP, Low, High)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("LTP: ${item['ltp']}",
                                    style: const TextStyle(
                                        color: Colors.green, fontSize: 15)),
                              ],
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("L: ${item['low']}",
                                    style: const TextStyle(fontSize: 15)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("H: ${item['high']}",
                                    style: const TextStyle(fontSize: 15)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ): const NoInternetConnection(),
    );
  }
}
