import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:suproxu/Assets/assets.dart';
import 'package:suproxu/Assets/font_family.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/extensions/color_blinker.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/core/service/Auth/user_validation.dart';
import 'package:suproxu/features/navbar/home/mcx/page/home/mcx_home.dart';
import 'package:suproxu/features/navbar/home/mcx/page/symbol/mcx_symbol.dart';
import 'package:suproxu/features/navbar/wishlist/model/mcx_symbol_param.dart';
import 'package:suproxu/features/navbar/wishlist/model/mcx_wishlist_entity.dart';
import 'package:suproxu/features/navbar/wishlist/model/sorting_param.dart';
import 'package:suproxu/features/navbar/wishlist/repositories/wishlist_repo.dart';
import 'package:suproxu/features/navbar/wishlist/websocket/mcx_wishlist_websocket.dart';
import 'package:suproxu/features/navbar/wishlist/widgets/search_widget.dart';

class McxStockWishlist extends StatefulWidget {
  const McxStockWishlist({super.key});
  static const String routeName = '/mcx-stock-wishlist-new';

  @override
  State<McxStockWishlist> createState() => _McxStockWishlistState();
}

class _McxStockWishlistState extends State<McxStockWishlist> {
  late MCXWishlistWebSocketService socket;
  MCXWishlistEntity mcxWishlist = MCXWishlistEntity();
  Timer? _validationTimer;
  StreamSubscription<void>? _logoutSub;
  Timer? _refreshTimer;
  String? errorMessage;
  bool _disposed = false;
  final Set<String> removingItems = {};
  List<MCXWatchlist> _localWatchlist = [];
  bool _isReordering = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        _initializeWebSocket();
        _localWatchlist = List.from(mcxWishlist.mcxWatchlist ?? []);
      }
    });

    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_disposed) {
        _refreshWishlistData();
      }
    });
    _startValidationTimer();
  }

  void _startValidationTimer() {
    _validationTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) async {
      if (!mounted) return;
      try {
        await AuthService().validateAndLogout(context);
      } catch (e) {
        debugPrint('TradeTabs auth validation error: $e');
      }
    });
    _logoutSub = AuthService().onLogout.listen((_) {
      _validationTimer?.cancel();
      debugPrint('TradeTabs: received logout event, cancelled local timer');
    });
  }

  void _initializeWebSocket() {
    if (_disposed) return;

    socket = MCXWishlistWebSocketService(
      onDataReceived: (data) {
        debugPrint('\n=========== MCX Wishlist Response ===========');
        debugPrint('Status: ${data.status}');
        debugPrint('Message: ${data.message}');
        log('Number of Watchlist Items: ${data.toString()}');

        debugPrint('==========================================\n');

        // Skip updates during reordering to prevent UI blink
        if (_isReordering) {
          debugPrint('Reordering in progress, skipping WebSocket update');
          return;
        }

        _safeSetState(() {
          mcxWishlist = data;
          _localWatchlist = List.from(mcxWishlist.mcxWatchlist ?? []);
        });
      },
      keyword: '',
      onError: (error) {
        _safeSetState(() {
          errorMessage = error;
        });
        if (!_disposed && mounted) {
          Future.delayed(const Duration(milliseconds: 100), () {
            socket.connect();
          });
        }
      },
      onConnected: () {
        debugPrint('MCX Wishlist WebSocket Connected');
        _refreshWishlistData();
      },
      onDisconnected: () {
        debugPrint('MCX Wishlist WebSocket Disconnected');
        if (!_disposed && mounted) {
          Future.delayed(const Duration(milliseconds: 100), () {
            socket.connect();
          });
        }
      },
    );

    if (!_disposed && mounted) {
      socket.connect();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _validationTimer?.cancel();
    _logoutSub?.cancel();
    _refreshTimer?.cancel();
    try {
      socket.disconnect();
    } catch (e) {
      debugPrint('Error disconnecting socket: $e');
    }
    super.dispose();
  }

  Future<void> _refreshWishlistData() async {
    debugPrint('Refreshing MCX Wishlist Data');

    // Skip refresh during reordering to prevent UI flicker
    if (_isReordering) {
      debugPrint('Reordering in progress, skipping refresh');
      return;
    }

    if (!_disposed && mounted) {
      if (socket.isConnected) {
        debugPrint('Socket connected - data will auto-refresh');
      } else {
        await socket.connect();
      }
    }
  }

  void _safeSetState(VoidCallback fn) {
    if (!_disposed && mounted) {
      setState(fn);
    }
  }

  @override
  void deactivate() {
    // DO NOT disconnect socket here - it marks socket as _isDisposed = true
    // which prevents reconnection in activate()
    debugPrint('Page deactivated - socket stays alive');
    super.deactivate();
  }

  @override
  void activate() {
    debugPrint('Page activated - reconnecting socket');
    if (!_disposed && mounted) {
      socket.reset();
      if (!socket.isConnected) {
        socket.connect();
      } else {
        _refreshWishlistData();
      }
    }
    super.activate();
  }

  String _formatNumber(dynamic v) {
    if (v == null) return '0.00';
    if (v is double) return v.toStringAsFixed(2);
    if (v is int) return v.toString();
    return double.tryParse(v.toString())?.toStringAsFixed(2) ?? v.toString();
  }

  Widget _buildListView() {
    return ReorderableListView.builder(
      itemCount: _localWatchlist.length,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Material(
              elevation: 12,
              color: kWhiteColor,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: kWhiteColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kWhiteColor, width: 2),
                ),
                child: child,
              ),
            );
          },
          child: child,
        );
      },

      onReorder: (oldIndex, newIndex) {
        _isReordering = true;

        _safeSetState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = _localWatchlist.removeAt(oldIndex);
          _localWatchlist.insert(newIndex, item);

          debugPrint('Reordered List: ${_localWatchlist.first.symbolName}');
        });

        // Create comma-separated string for symbolKey
        String symbolKeys = _localWatchlist
            .map((e) => e.symbolKey.toString())
            .join(',');

        // Create array format string for symbolOrder
        String orderNumbers = List.generate(
          _localWatchlist.length,
          (i) => (i + 1).toString(),
        ).join(',');

        WishlistRepository.symbolSorting(
              param: SortListParam(
                symbolKey: symbolKeys,
                symbolOrder: orderNumbers,
              ),
            )
            .then((_) {
              // Add delay before re-enabling WebSocket updates to let UI settle
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted && !_disposed) {
                  _isReordering = false;
                  debugPrint(
                    'Reordering completed, WebSocket updates re-enabled',
                  );
                }
              });
            })
            .catchError((error) {
              // On error, also re-enable WebSocket updates with delay
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted && !_disposed) {
                  _isReordering = false;
                  debugPrint(
                    'Reordering error: $error, WebSocket updates re-enabled',
                  );
                }
              });
            });
      },

      itemBuilder: (context, index) {
        // Safety check: bounds validation
        if (index >= _localWatchlist.length) {
          return SizedBox.shrink();
        }
        final item = _localWatchlist[index];
        return GestureDetector(
          key: ValueKey(item.symbolKey),
          onTap: () {
            if (item.symbol != null) {
              context.pushNamed(
                MCXSymbolRecordPage.routeName,
                extra: MCXSymbolParams(
                  symbol: item.symbol.toString(),
                  index: index,
                  symbolKey: item.symbolKey.toString(),
                ),
              );
            }
          },
          child: _buildListItem(item, index),
        );
      },
    );
  }

  Widget _buildListItem(MCXWatchlist item, int index) {
    return Container(
      margin: const EdgeInsets.only(left: 8, right: 8, top: 10),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildItemHeader(item),
          _buildItemControls(item, index),
          _buildItemFooter(item),
          Divider(thickness: 1, color: Colors.grey.shade800),
        ],
      ),
    );
  }

  Widget _buildItemHeader(MCXWatchlist item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.symbolName.toString()).textStyleH1(),
              // SizedBox(height: 4.h),
            ],
          ),
        ),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BlinkingPriceText(
                  assetId: item.symbolKey.toString(),
                  text: "₹${_formatNumber(item.ohlc!.salePrice.toString())}",
                  compareValue: item.ohlc!.lastPrice,
                  currentValue: item.ohlc!.salePrice,
                ),
                SizedBox(width: 10.w),
                BlinkingPriceText(
                  assetId: item.symbolName.toString(),
                  text: "₹${_formatNumber(item.ohlc!.buyPrice.toString())}",
                  compareValue: item.ohlc!.lastPrice,
                  currentValue: item.ohlc!.buyPrice,
                ),
                SizedBox(height: 5.w),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemControls(MCXWatchlist item, int index) {
    // final date = item.expiryDate?.substring(0, 10);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(item.expiryDate ?? '').textStyleH2(),
        IconButton(
          onPressed: () => _removeItem(item, index),
          icon: removingItems.contains(item.symbolKey.toString())
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: zBlack,
                    strokeWidth: 2,
                  ),
                )
              : Image.asset(Assets.assetsImagesCheckbox, width: 34, height: 34),
        ),
      ],
    );
  }

  Widget _buildItemFooter(MCXWatchlist item) {
    final isNegative = item.change.toString().contains('-');
    final changeColor = isNegative ? Colors.red : Colors.green.shade900;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              "Chg: ",
              style: TextStyle(
                color: changeColor,
                fontFamily: FontFamily.globalFontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _formatNumber(item.change ?? 0.0),
              style: TextStyle(
                color: changeColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Text("LTP: ").textStyleH3(),
            Text(_formatNumber(item.ohlc!.lastPrice)).textStyleH3(),
          ],
        ),
        Row(
          children: [
            const Text("H: ").textStyleH3(),
            Text(_formatNumber(item.ohlc!.high)).textStyleH3(),
          ],
        ),
        Row(
          children: [
            const Text("L: ").textStyleH3(),
            Text(_formatNumber(item.ohlc!.low)).textStyleH3(),
          ],
        ),
      ],
    );
  }

  Future<void> _removeItem(MCXWatchlist item, int index) async {
    final symbolKey = item.symbolKey.toString();
    if (!mounted) return;

    setState(() => removingItems.add(symbolKey));

    try {
      final success = await WishlistRepository.removeWatchListSymbols(
        category: 'MCX',
        symbolKey: symbolKey,
      );

      if (success && mounted && !_disposed) {
        setState(() {
          _localWatchlist.removeAt(index);
        });
      }
    } catch (error) {
      if (mounted && !_disposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing item: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted && !_disposed) {
        setState(() => removingItems.remove(symbolKey));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: Column(
        children: [
          const SizedBox(height: 8),
          SearchWidget(
            hint: 'Search & Add',
            isReadOnly: true,
            onTap: () => context.pushNamed(McxHome.routeName),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshWishlistData,
              child: Builder(
                builder: (context) {
                  if (_localWatchlist.isEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 150,
                        child: Center(
                          child: Text(
                            errorMessage ?? 'Data not available',
                            style: const TextStyle(color: zBlack),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }

                  return _buildListView();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
