import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:suproxu/features/navbar/wishlist/model/mcx_wishlist_entity.dart';
import 'package:suproxu/features/navbar/wishlist/websocket/mcx_wishlist_websocket.dart';
import 'package:suproxu/features/navbar/wishlist/wishlist-tabs/MCX-Tab/page/mxc_watchlist_main.dart';

abstract class McxWatchListMainBuilder extends State<MCMxcWatchListMain> {
  late MCXWishlistWebSocketService socket;
  MCXWishlistEntity mcxWishlist = MCXWishlistEntity();
  String? errorMessage;
  bool disposed = false;
  final Set<String> removingItems = {};
  List<MCXWatchlist> localWatchlist = [];

  void safeSetState(VoidCallback fn) {
    if (!disposed && mounted) {
      setState(fn);
    }
  }

  void initializeWebSocket() {
    if (disposed) return;

    socket = MCXWishlistWebSocketService(
      onDataReceived: (data) {
        debugPrint('\n=========== MCX Wishlist Response ===========');
        debugPrint('Status: ${data.status}');
        debugPrint('Message: ${data.message}');
        log('Number of Watchlist Items: ${data.toString()}');

        debugPrint('==========================================\n');

        safeSetState(() {
          mcxWishlist = data;
          localWatchlist = mcxWishlist.mcxWatchlist ?? [];
        });
      },
      keyword: '',
      onError: (error) {
        safeSetState(() {
          errorMessage = error;
        });
        if (!disposed && mounted) {
          Future.delayed(const Duration(milliseconds: 100), () {
            socket.connect();
          });
        }
      },
      onConnected: () {
        debugPrint('MCX Wishlist WebSocket Connected');
        // Refresh data on connection
        // _refreshWishlistData();
      },
      onDisconnected: () {
        debugPrint('MCX Wishlist WebSocket Disconnected');
        if (!disposed && mounted) {
          Future.delayed(const Duration(milliseconds: 100), () {
            socket.connect();
          });
        }
      },
    );

    if (!disposed && mounted) {
      socket.connect();
    }
  }
}
