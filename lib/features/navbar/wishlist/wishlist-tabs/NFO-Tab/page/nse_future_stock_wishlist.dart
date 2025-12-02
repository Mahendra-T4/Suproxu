import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:suproxu/Assets/assets.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/extensions/color_blinker.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/core/service/Auth/user_validation.dart';
import 'package:suproxu/features/navbar/home/model/symbol_page_param.dart';
import 'package:suproxu/features/navbar/home/nse-future/page/nse_future.dart';
import 'package:suproxu/features/navbar/home/nse-future/page/nse_future_symbol_page.dart';
import 'package:suproxu/features/navbar/wishlist/model/sorting_param.dart';
import 'package:suproxu/features/navbar/wishlist/model/wishlist_entity.dart';
import 'package:suproxu/features/navbar/wishlist/repositories/wishlist_repo.dart';
import 'package:suproxu/features/navbar/wishlist/websocket/nfo_watchlist_ws.dart';
import 'package:suproxu/features/navbar/wishlist/widgets/search_widget.dart';

class NseFutureStockWishlist extends StatefulWidget {
  const NseFutureStockWishlist({super.key});

  @override
  State<NseFutureStockWishlist> createState() => _NseFutureStockWishlistState();
}

class _NseFutureStockWishlistState extends State<NseFutureStockWishlist> {
  late final NFOWatchListWebSocketService nfoSocket;
  NFOWishlistEntity nfoWishlist = NFOWishlistEntity();
  TextEditingController searchController = TextEditingController();
  bool isMarketOpen = true; // This should be fetched from your backend
  bool isSearch = false;

  List<String> removingNfoItems = [];
  List<NFOWatchList> _localNfoWatchlist = [];
  List<NFOWatchList> _reorderedNfoCopy = [];

  late Timer _timer;
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        _initializeWebSocket();
        _setupAuthCheck();
      }
    });
  }

  String? errorMessage;

  void _initializeWebSocket() {
    if (_disposed) return;

    nfoSocket = NFOWatchListWebSocketService(
      onNFODataReceived: (data) {
        log('=========== NFO Wishlist Response ===========');
        log('Status: ${data.status}');
        log('Message: ${data.message}');
        log('Number of Watchlist Items: ${data.nfoWatchlist?.length ?? 0}');

        if (data.nfoWatchlist != null && data.nfoWatchlist!.isNotEmpty) {
          for (var item in data.nfoWatchlist!) {
            log('----------------------------------------');
            log('Symbol: ${item.symbol}');
            // log('Symbol Name: ${item.symbolName}');
            // log('Symbol Key: ${item.symbolKey}');
            // log('Category: ${item.category}');
            // log('Expiry Date: ${item.expiryDate}');
            // log('Current Time: ${item.currentTime}');
            // log('Change: ${item.change}');
          }
        }
        log('==========================================');

        _safeSetState(() {
          nfoWishlist = data;
          // Safely convert incoming list to NFOWatchList instances.
          final rawList = (data.nfoWatchlist as List<dynamic>?) ?? [];
          _localNfoWatchlist = rawList.map<NFOWatchList>((e) {
            if (e is NFOWatchList) return e;
            if (e is Map<String, dynamic>) return NFOWatchList.fromJson(e);
            if (e is Map) {
              try {
                return NFOWatchList.fromJson(Map<String, dynamic>.from(e));
              } catch (_) {
                return NFOWatchList();
              }
            }
            return NFOWatchList();
          }).toList();
        });
      },
      onError: (error) {
        log('WebSocket Error: $error');
        _safeSetState(() {
          nfoWishlist = NFOWishlistEntity();
          _localNfoWatchlist = [];
          errorMessage = error;
        });
      },
      onConnected: () {
        log('WebSocket Connected');
      },
      onDisconnected: () {
        log('WebSocket Disconnected');
        if (!_disposed && mounted) {
          Future.delayed(const Duration(seconds: 1), () {
            nfoSocket.connect();
          });
        }
      },
    );

    if (!_disposed && mounted) {
      nfoSocket.connect();
    }
  }

  void _setupAuthCheck() {
    AuthService().checkUserValidation();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_disposed || !mounted) {
        timer.cancel();
        return;
      }
      AuthService().checkUserValidation();
    });
  }

  // Remove unused methods

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _timer.cancel(); // Cancel the timer
    nfoSocket.disconnect();
    searchController.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_disposed && mounted) {
      setState(fn);
    }
  }

  String _formatNumber(dynamic number) {
    if (number == null) return 'N/A';
    final formatter = NumberFormat('#,##,##0.00');
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: zBlack,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            SearchWidget(
              hint: 'Search & Add',
              isReadOnly: true,
              onTap: () {
                context.pushNamed(NseFuture.routeName);
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Builder(
                builder: (context) {
                  // Show loading state
                  final data = nfoWishlist;
                  if (_localNfoWatchlist.isEmpty) {
                    return Center(
                      child: Text(
                        errorMessage ?? 'Data not available',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  // Show empty state
                  // if (data.nfoWatchlist!.isEmpty) {
                  //   return Center(
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Icon(Icons.bookmark_border,
                  //             size: 48, color: Colors.grey[400]),
                  //         const SizedBox(height: 16),
                  //         const Text(
                  //           'Your watchlist is empty',
                  //           style: TextStyle(
                  //             fontSize: 16,
                  //             color: Colors.grey,
                  //           ),
                  //         ),
                  //         const SizedBox(height: 8),
                  //         ElevatedButton(
                  //           onPressed: () {
                  //             context.pushNamed(NseFuture.routeName);
                  //           },
                  //           child: const Text('Add Symbols'),
                  //         ),
                  //       ],
                  //     ),
                  //   );
                  // }

                  return ReorderableListView.builder(
                    itemCount: data.nfoWatchlist!.length,
                    proxyDecorator: (child, index, animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          return Material(
                            elevation: 12,
                            color: zBlack,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: zBlack,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: kGoldenBraunColor.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: child,
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      _safeSetState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = _localNfoWatchlist.removeAt(oldIndex);
                        _localNfoWatchlist.insert(newIndex, item);
                        // Copy reordered data
                        _reorderedNfoCopy = List.from(_localNfoWatchlist);

                        log(
                          name: 'Reordered List: ',
                          _localNfoWatchlist.first.symbolName.toString(),
                        );
                      });

                      // Create comma-separated string for symbolKey
                      String symbolKeys = _localNfoWatchlist
                          .map((e) => e.symbolKey.toString())
                          .join(',');

                      // Create array format string for symbolOrder
                      String orderNumbers = List.generate(
                        _localNfoWatchlist.length,
                        (i) => (i + 1).toString(),
                      ).join(',');

                      WishlistRepository.symbolSorting(
                        param: SortListParam(
                          symbolKey: symbolKeys,
                          symbolOrder: orderNumbers,
                        ),
                      );
                    },
                    buildDefaultDragHandles: true,
                    itemBuilder: (context, index) {
                      var record = data.nfoWatchlist![index];
                      // Remove unused variable
                      //  final item = data.mcxWatchlist![index];
                      final date = record.expiryDate?.substring(0, 10);
                      return Container(
                        key: ValueKey(record.symbolKey),
                        child: GestureDetector(
                          onTap: () {
                            GoRouter.of(context).pushNamed(
                              NseFutureSymbolPage.routeName,
                              extra: SymbolScreenParams(
                                symbol: record.symbol.toString(),
                                index: index,
                                symbolKey: record.symbolKey.toString(),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 10,
                            ),
                            decoration: BoxDecoration(
                              color: zBlack,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            record.symbolName
                                                .toString()
                                                .toUpperCase(),
                                          ).textStyleH1(),
                                          // SizedBox(height: 4.h),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            BlinkingPriceText(
                                              assetId: data
                                                  .nfoWatchlist![index]
                                                  .symbolKey
                                                  .toString(),
                                              text:
                                                  "₹${_formatNumber(data.nfoWatchlist![index].lastSale!.price)}",
                                              compareValue: double.parse(
                                                data
                                                    .nfoWatchlist![index]
                                                    .ohlc!
                                                    .lastPrice
                                                    .toString(),
                                              ),
                                              currentValue: double.parse(
                                                data
                                                    .nfoWatchlist![index]
                                                    .lastSale!
                                                    .price
                                                    .toString(),
                                              ),
                                            ),
                                            SizedBox(width: 20.w),
                                            BlinkingPriceText(
                                              assetId: data
                                                  .nfoWatchlist![index]
                                                  .symbol
                                                  .toString(),
                                              text:
                                                  "₹${_formatNumber(data.nfoWatchlist![index].lastBuy!.price)}",
                                              compareValue: double.parse(
                                                data
                                                    .nfoWatchlist![index]
                                                    .ohlc!
                                                    .lastPrice
                                                    .toString(),
                                              ),
                                              currentValue: double.parse(
                                                data
                                                    .nfoWatchlist![index]
                                                    .lastBuy!
                                                    .price
                                                    .toString(),
                                              ),
                                            ),
                                            SizedBox(height: 5.w),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 5,
                                      children: [
                                        Text(date ?? '').textStyleH2(),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        final symbolKey = record.symbolKey
                                            .toString();

                                        if (!mounted) return;

                                        // final scaffoldMessenger =
                                        //     ScaffoldMessenger.of(context);

                                        _safeSetState(() {
                                          removingNfoItems.add(symbolKey);
                                        });

                                        try {
                                          final success =
                                              await WishlistRepository.removeWatchListSymbols(
                                                category: 'NFO',
                                                symbolKey: symbolKey,
                                              );

                                          if (success) {
                                            _safeSetState(() {
                                              data.nfoWatchlist!.removeAt(
                                                index,
                                              );
                                              _localNfoWatchlist.removeAt(
                                                index,
                                              );
                                            });
                                          }
                                        } catch (error) {
                                          log(error.toString());
                                        } finally {
                                          _safeSetState(() {
                                            removingNfoItems.remove(symbolKey);
                                          });
                                        }
                                      },
                                      icon:
                                          removingNfoItems.contains(
                                            data.nfoWatchlist![index].symbolKey
                                                .toString(),
                                          )
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.green,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              width: 20,
                                              height: 20,
                                              child: Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.green,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                                Row(
                                  // spacing: MediaQuery.sizeOf(context).width * .08,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Chg: ",
                                          style: TextStyle(
                                            color:
                                                data.nfoWatchlist![index].change
                                                    .toString()
                                                    .contains('-')
                                                ? Colors.red
                                                : const Color(0xFF00C853),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          _formatNumber(record.change ?? 0.0),
                                          style: TextStyle(
                                            color:
                                                data.nfoWatchlist![index].change
                                                    .toString()
                                                    .contains('-')
                                                ? Colors.red
                                                : const Color(0xFF00C853),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text("LTP: ").textStyleH3(),
                                        Text(
                                          _formatNumber(record.ohlc!.lastPrice),
                                        ).textStyleH3(),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text("H: ").textStyleH3(),
                                        Text(
                                          _formatNumber(record.ohlc!.high),
                                        ).textStyleH3(),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text("L: ").textStyleH3(),
                                        Text(
                                          _formatNumber(record.ohlc!.low),
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
    );
  }
}
