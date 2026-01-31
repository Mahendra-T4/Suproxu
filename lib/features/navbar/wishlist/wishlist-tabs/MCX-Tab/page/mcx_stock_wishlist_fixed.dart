import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:suproxu/Assets/font_family.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/extensions/color_blinker.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
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
  String? errorMessage;
  bool _disposed = false;
  final Set<String> removingItems = {};
  List<MCXWatchlist> _localWatchlist = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        _initializeWebSocket();
        _localWatchlist = mcxWishlist.mcxWatchlist ?? [];
      }
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

        _safeSetState(() {
          mcxWishlist = data;
          _localWatchlist = mcxWishlist.mcxWatchlist ?? [];
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
        // Refresh data on connection
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

  Future<void> _refreshWishlistData() async {
    debugPrint('Refreshing MCX Wishlist Data');

    if (!_disposed && mounted) {
      if (socket.isConnected) {
        // Socket is connected, request fresh data
        // The socket will automatically emit when it receives data
        debugPrint('Socket connected - data will auto-refresh');
      } else {
        // If not connected, reconnect first
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
  void dispose() {
    _disposed = true;
    try {
      socket.disconnect();
    } catch (e) {
      debugPrint('Error disconnecting socket: $e');
    }
    super.dispose();
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
      // Socket is still alive from deactivate, just reconnect if needed
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'An error occurred',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() => errorMessage = null);
              socket.connect();
            },
            child: const Text('Retry Connection'),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ReorderableListView.builder(
      itemCount: mcxWishlist.mcxWatchlist?.length ?? 0,
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
        );
      },

      itemBuilder: (context, index) {
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
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
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
        Expanded(flex: 3, child: Text(item.symbolName ?? '').textStyleH1()),
        Row(
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
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  width: 20,
                  height: 20,
                  child: Icon(Icons.check, size: 16, color: Colors.green),
                ),
        ),
      ],
    );
  }

  Widget _buildItemFooter(MCXWatchlist item) {
    final isNegative = item.change.toString().contains('-');
    final changeColor = isNegative ? Colors.red : Colors.green;

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
