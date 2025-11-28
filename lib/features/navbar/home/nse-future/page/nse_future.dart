import 'package:flutter/material.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/features/navbar/home/nse-future/widgets/searchbar_widget.dart';
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

  @override
  void initState() {
    super.initState();
    nfoWebSocket = NFOWebSocket(
      keyword: _searchController.text,
      onNFODataReceived: (data) {
        setState(() {
          nfoData = data;
          _performSearch(_searchController.text);
        });
      },
      onError: (error) {
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
    nfoWebSocket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: zBlack,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Implement refresh logic if needed
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
                                nfoWebSocket.dispose();
                                initState();
                              },
                              child: const Text('Retry Connection'),
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
                            Text('Connecting to server...'),
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
