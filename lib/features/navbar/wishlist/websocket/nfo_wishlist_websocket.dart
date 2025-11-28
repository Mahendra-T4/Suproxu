// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:trading_app/features/navbar/wishlist/model/wishlist_entity.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import '../model/nfo_wishlist_entity.dart';

// class NFOWishlistWebSocketService {
//   final Function(NFOWishlistEntity) onDataReceived;
//   final Function(String) onError;
//   final Function() onConnected;
//   final Function() onDisconnected;
//   final String? keyword;
//   WebSocketChannel? _channel;
//   Timer? _pingTimer;
//   bool _isDisposed = false;

//   NFOWishlistWebSocketService({
//     required this.onDataReceived,
//     required this.onError,
//     required this.onConnected,
//     required this.onDisconnected,
//     this.keyword,
//   });

//   void connect() {
//     try {
//       final uri = Uri.parse('wss://your-websocket-url.com/ws/nfo-wishlist');
//       _channel = WebSocketChannel.connect(uri);

//       _channel?.stream.listen(
//         (data) {
//           try {
//             final decodedData = json.decode(data);
//             final nfoData = NFOWishlistEntity.fromJson(decodedData);
//             if (!_isDisposed) {
//               onDataReceived(nfoData);
//             }
//           } catch (e) {
//             debugPrint('Error processing data: $e');
//             if (!_isDisposed) {
//               onError('Failed to process data: $e');
//             }
//           }
//         },
//         onError: (error) {
//           debugPrint('WebSocket error: $error');
//           if (!_isDisposed) {
//             onError('Connection error: $error');
//             _cleanup();
//           }
//         },
//         onDone: () {
//           debugPrint('WebSocket connection closed');
//           if (!_isDisposed) {
//             onDisconnected();
//             _cleanup();
//           }
//         },
//       );

//       onConnected();
//       _startPingTimer();
//     } catch (e) {
//       debugPrint('Connection error: $e');
//       if (!_isDisposed) {
//         onError('Failed to establish connection: $e');
//       }
//     }
//   }

//   void _startPingTimer() {
//     _pingTimer?.cancel();
//     _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
//       _channel?.sink.add('ping');
//     });
//   }

//   void _cleanup() {
//     _pingTimer?.cancel();
//     _pingTimer = null;
//     _channel?.sink.close();
//     _channel = null;
//   }

//   void disconnect() {
//     _isDisposed = true;
//     _cleanup();
//   }

//   void reconnect() {
//     disconnect();
//     if (!_isDisposed) {
//       connect();
//     }
//   }
// }
