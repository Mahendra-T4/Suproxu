import 'package:flutter/material.dart';
import 'package:suproxu/Assets/font_family.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/service/Auth/user_validation.dart';
import 'package:suproxu/features/navbar/home/nse-future/widgets/searchbar_widget.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:suproxu/features/navbar/home/websocket/nfo_websocket.dart';
import '../widgets/nfo_list_item.dart';
import 'package:suproxu/features/navbar/home/model/nfo_entity.dart';

class NseFuture extends StatefulWidget {
  const NseFuture({super.key});

  static const String routeName = '/nse-future-page';

  @override
  State<NseFuture> createState() => _NseFutureState();
}

class _NseFutureState extends State<NseFuture> {
  final TextEditingController _searchController = TextEditingController();
  late final NFOWebSocket nfoWebSocket;
  NFODataEntity nfoData = NFODataEntity();
  NFODataEntity filteredNFO = NFODataEntity();
  String? errorMessage;
  String _currentSearchQuery = '';
  Timer? _validationTimer;
  StreamSubscription<void>? _logoutSub;

  @override
  void initState() {
    super.initState();
    // Start periodic validation timer (every 10 seconds)
    _validationTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) async {
      if (!mounted) return;
      try {
        await AuthService().validateAndLogout(context);
      } catch (e) {
        developer.log('NseFuture auth validation error: $e');
      }
    });
    // Subscribe to global logout events to cleanup immediately
    _logoutSub = AuthService().onLogout.listen((_) {
      _validationTimer?.cancel();
      try {
        nfoWebSocket.dispose();
      } catch (_) {}
      developer.log('NseFuture: handled global logout cleanup');
    });

    nfoWebSocket = NFOWebSocket(
      keyword: _searchController.text,
      onDataReceived: (data) {
        if (!mounted) return;
        setState(() {
          nfoData = data;
          _performSearch(_searchController.text);
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          errorMessage = error;
        });
      },
      onConnected: () {
        developer.log('NFO WebSocket connected');
      },
      onDisconnected: () {
        developer.log('NFO WebSocket disconnected');
      },
    );

    nfoWebSocket.connect();

    _searchController.addListener(() {
      _performSearch(_searchController.text);
    });

     Timer.periodic(const Duration(seconds:1), (timer) {
      if (mounted) {
        _refreshNFOData();
      }
    });
  }

  Future<void> _refreshNFOData() async {
    debugPrint('Refreshing NFO Data');

    if (!mounted) return;

    try {
      nfoWebSocket.connect();
    } catch (e) {
      developer.log('Error refreshing NFO data: $e');
    }
  }

  void _performSearch(String query) {
    _currentSearchQuery = query.toLowerCase().trim();

    if (_currentSearchQuery.isEmpty) {
      if (!mounted) return;
      setState(() {
        filteredNFO = nfoData;
      });
    } else {
      final filteredList =
          nfoData.response?.where((stock) {
            final symbol = (stock.symbol ?? '').toLowerCase();
            final symbolName = (stock.symbolName ?? '').toLowerCase();
            final symbolKey = (stock.symbolKey ?? '').toLowerCase();
            final category = (stock.category ?? '').toLowerCase();
            return symbol.contains(_currentSearchQuery) ||
                symbolName.contains(_currentSearchQuery) ||
                symbolKey.contains(_currentSearchQuery) ||
                category.contains(_currentSearchQuery);
          }).toList() ??
          [];

      if (!mounted) return;
      setState(() {
        filteredNFO = NFODataEntity(
          status: nfoData.status,
          response: filteredList,
          message: _currentSearchQuery.isEmpty
              ? nfoData.message
              : 'Found ${filteredList.length} result(s)',
        );
      });
    }
  }

  @override
  void dispose() {
    _validationTimer?.cancel();
    _logoutSub?.cancel();
    nfoWebSocket.dispose();
    super.dispose();
  }

  @override
  void activate() {
    super.activate();
    // Reconnect socket when the page comes back into focus
    developer.log('NseFuture: Page activated - reconnecting websocket');
    try {
      nfoWebSocket.connect();
    } catch (e) {
      developer.log('Error reconnecting NFO websocket on activate: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshNFOData,
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
                              style: const TextStyle(
                                color: Colors.red,
                                fontFamily: FontFamily.globalFontFamily,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  errorMessage = null;
                                });
                                // Just reconnect without disconnecting
                                // (socket is shared with other pages)
                                nfoWebSocket.connect();
                              },
                              child: const Text(
                                'Retry Connection',
                                style: TextStyle(
                                  fontFamily: FontFamily.globalFontFamily,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (nfoData.response == null) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Connecting to server...',
                              style: TextStyle(
                                fontFamily: FontFamily.globalFontFamily,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final displayData = _currentSearchQuery.isEmpty
                        ? nfoData
                        : filteredNFO;

                    return displayData.status != 1
                        ? Center(child: Text(displayData.message.toString()))
                        : ListView.builder(
                            itemCount: displayData.response!.length,
                            itemBuilder: (context, index) => NFOListItem(
                              itemData: displayData.response![index],
                              index: index,
                              onWishlistChanged: () {
                                setState(() {
                                  displayData.response![index].watchlist =
                                      displayData.response![index].watchlist ==
                                          1
                                      ? 0
                                      : 1;
                                });
                              },
                            ),
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
