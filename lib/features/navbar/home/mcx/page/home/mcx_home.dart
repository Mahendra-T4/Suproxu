import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:suproxu/Assets/font_family.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/extensions/color_blinker.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/features/navbar/home/mcx/page/symbol/mcx_symbol.dart';
import 'package:suproxu/features/navbar/home/model/mcx_entity.dart';
import 'package:suproxu/features/navbar/home/nse-future/widgets/searchbar_widget.dart';

import 'dart:developer' as developer;

import 'package:suproxu/features/navbar/home/websocket/mcx_websocket_service.dart';
import 'package:suproxu/features/navbar/wishlist/model/mcx_symbol_param.dart';
import 'package:suproxu/features/navbar/wishlist/repositories/wishlist_repo.dart';

class McxHome extends StatefulWidget {
  const McxHome({super.key});
  static const String routeName = '/mcx-home-page';

  @override
  State<McxHome> createState() => _McxHomeState();
}

class _McxHomeState extends State<McxHome> {
  final TextEditingController _searchController = TextEditingController();
  late final SocketService socket;
  MCXDataEntity mcx = MCXDataEntity();

  Future<bool> rWatchList(symbolKey) async {
    final success = await WishlistRepository.removeWatchListSymbols(
      category: 'MCX',
      symbolKey: symbolKey,
    );

    return success;
  }

  MCXDataEntity filteredMcx = MCXDataEntity();
  String? errorMessage;
  String _currentSearchQuery = '';

  String _formatNumber(dynamic v) {
    if (v == null) return '0.00';
    if (v is double) return v.toStringAsFixed(2);
    if (v is int) return v.toString();
    return double.tryParse(v.toString())?.toStringAsFixed(2) ?? v.toString();
  }

  /// Filter MCX data based on search query
  void _performSearch(String query) {
    _currentSearchQuery = query.toLowerCase().trim();

    if (_currentSearchQuery.isEmpty) {
      // Show all data if search is empty
      setState(() {
        filteredMcx = mcx;
      });
    } else {
      // Filter by symbol name, symbol key, or category
      final filtered =
          mcx.response?.where((item) {
            final symbol = (item.symbol ?? '').toLowerCase();
            final symbolName = (item.symbolName ?? '').toLowerCase();
            final symbolKey = (item.symbolKey ?? '').toLowerCase();
            final category = (item.category ?? '').toLowerCase();

            return symbol.contains(_currentSearchQuery) ||
                symbolName.contains(_currentSearchQuery) ||
                symbolKey.contains(_currentSearchQuery) ||
                category.contains(_currentSearchQuery);
          }).toList() ??
          [];

      setState(() {
        filteredMcx = MCXDataEntity(
          status: mcx.status,
          response: filtered,
          message: 'Found ${filtered.length} result(s)',
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    socket = SocketService(
      onDataReceived: (data) {
        setState(() {
          mcx = data;
          // Re-apply search filter when new data arrives
          _performSearch(_searchController.text);
        });
      },
      keyword: _searchController.text,
      onError: (error) {
        if (!mounted) return;
        setState(() {
          errorMessage = error;
        });
      },
      onConnected: () {
        developer.log(
          'MCX WebSocket Connected Successfully',
          name: 'MCX Socket Connected',
        );
      },
      onDisconnected: () {
        developer.log(
          'MCX WebSocket Disconnected',
          name: 'MCX Socket Disconnected',
        );
      },
    );
    socket.connect();

    // Listen to search controller changes
    _searchController.addListener(() {
      _performSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    try {
      socket.disconnect();
    } catch (e) {
      developer.log('Error disconnecting socket on dispose: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      // appBar: AppBar(
      //   title: const Text('MCX'),
      // ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            try {
              socket.disconnect();
            } catch (_) {}
            socket.connect();
          },
          child: Column(
            children: [
              SearchBarWidget(controller: _searchController),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error: $errorMessage',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  errorMessage = null;
                                });
                                try {
                                  socket.disconnect();
                                } catch (_) {}
                                socket.connect();
                              },
                              child: const Text('Retry Connection'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (mcx.status != 1 || mcx.response == null) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Connecting to server...'),
                          ],
                        ),
                      );
                    }

                    // Use filtered data if search query exists, otherwise use all data
                    final displayData = _currentSearchQuery.isEmpty
                        ? mcx
                        : filteredMcx;

                    return displayData.response!.isEmpty
                        ? Center(
                            child: Text(
                              _currentSearchQuery.isEmpty
                                  ? 'No data available'
                                  : 'No results found for "$_currentSearchQuery"',
                              style: TextStyle(color: zBlack),
                            ),
                          )
                        : ListView.builder(
                            itemCount: displayData.response!.length,
                            itemBuilder: (context, index) {
                              final itemData = displayData.response![index];
                              return GestureDetector(
                                onTap: () {
                                  if (itemData.symbol != null) {
                                    context.pushNamed(
                                      MCXSymbolRecordPage.routeName,
                                      extra: MCXSymbolParams(
                                        symbol: itemData.symbol.toString(),
                                        index: index,
                                        symbolKey: itemData.symbolKey
                                            .toString(),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  color: kWhiteColor,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width:
                                                MediaQuery.sizeOf(
                                                  context,
                                                ).width /
                                                4,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  itemData.symbolName ?? '',
                                                ).textStyleH1(),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  BlinkingPriceText(
                                                    assetId: itemData.symbolKey,
                                                    text:
                                                        "₹${_formatNumber(itemData.ohlc?.salePrice)}",
                                                    compareValue:
                                                        itemData
                                                            .ohlc
                                                            ?.lastPrice ??
                                                        0.0,
                                                    currentValue:
                                                        itemData
                                                            .ohlc
                                                            ?.salePrice ??
                                                        0.0,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  BlinkingPriceText(
                                                    assetId:
                                                        itemData.symbolName,
                                                    text:
                                                        "₹${_formatNumber(itemData.ohlc?.buyPrice)}",
                                                    compareValue:
                                                        itemData
                                                            .ohlc
                                                            ?.lastPrice ??
                                                        0.0,
                                                    currentValue:
                                                        itemData
                                                            .ohlc
                                                            ?.buyPrice ??
                                                        0.0,
                                                  ),
                                                  const SizedBox(width: 8),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width:
                                                MediaQuery.sizeOf(
                                                  context,
                                                ).width /
                                                2,
                                            child: Text(
                                              itemData.expiryDate ?? '',
                                            ).textStyleH2(),
                                          ),

                                          GestureDetector(
                                            onTap: () async {
                                              bool success = false;
                                              if (mcx
                                                      .response![index]
                                                      .watchlist ==
                                                  1) {
                                                // Remove from wishlist
                                                success =
                                                    await WishlistRepository.removeWatchListSymbols(
                                                      category: 'MCX',
                                                      symbolKey: mcx
                                                          .response![index]
                                                          .symbolKey
                                                          .toString(),
                                                    );
                                              } else {
                                                // Add to wishlist
                                                success =
                                                    await WishlistRepository.addToWishlist(
                                                      category: 'MCX',
                                                      symbolKey: mcx
                                                          .response![index]
                                                          .symbolKey
                                                          .toString(),
                                                      context: context,
                                                    );
                                              }
                                              if (success && mounted) {
                                                setState(() {
                                                  mcx
                                                          .response![index]
                                                          .watchlist =
                                                      mcx
                                                              .response![index]
                                                              .watchlist ==
                                                          1
                                                      ? 0
                                                      : 1;
                                                });
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: itemData.watchlist == 1
                                                      ? Colors.green
                                                      : kGoldenBraunColor,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              width: 20,
                                              height: 20,
                                              child: itemData.watchlist == 1
                                                  ? Icon(
                                                      Icons.check,
                                                      size: 16,
                                                      color: Colors.green,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Chg: ",
                                                style: TextStyle(
                                                  color:
                                                      itemData.change
                                                          .toString()
                                                          .contains('-')
                                                      ? Colors.red
                                                      : Colors.green,
                                                  fontSize: 11.5,
                                                  fontFamily: FontFamily
                                                      .globalFontFamily,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                _formatNumber(itemData.change),
                                                style: TextStyle(
                                                  color:
                                                      itemData.change
                                                          .toString()
                                                          .contains('-')
                                                      ? Colors.red
                                                      : Colors.green,
                                                  fontSize: 11.5,
                                                  fontFamily: FontFamily
                                                      .globalFontFamily,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text("LTP: ").textStyleH3(),
                                              Text(
                                                _formatNumber(
                                                  itemData.ohlc?.lastPrice,
                                                ),
                                              ).textStyleH3(),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text("H: ").textStyleH3(),
                                              Text(
                                                _formatNumber(
                                                  itemData.ohlc?.high,
                                                ),
                                              ).textStyleH3(),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text("L: ").textStyleH3(),
                                              Text(
                                                _formatNumber(
                                                  itemData.ohlc?.low,
                                                ),
                                              ).textStyleH3(),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        thickness: 1.5,
                                        color: Colors.grey.shade800,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
