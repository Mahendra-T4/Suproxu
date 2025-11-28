
// class SocketService {
//   late IO.Socket socket;
//   Function(MCXDataEntity)? onDataReceived; // Callback for handling received data

//   SocketService({this.onDataReceived});

//   void connect() {
//     // Initialize socket connection
//     socket = IO.Socket('https://www.thesupertrade.com', <String, dynamic>{
//       'path': '/socket.io/',
//       'auth': {
//         'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE1MywiaWF0IjoxNzYwNTIwOTE2fQ.7qY8PkhxKVlomSxsUISKP-VvlzPpDsM2-qgSHxMUapo'
//       },
//       'transports': ['websocket'],
//     });

//     // Handle connection
//     socket.onConnect((_) {
//       print('Connected: ${socket.id}');
      
//       // Emit activity event
//       socket.emit('activity', {
//         'activity': 'get-stock-list',
//         'userKey': 'd51b46e5ddadba21f003c04a67d637cc',
//         'deviceID': 'BE2A.250530.026.D1',
//         'dataRelatedTo': 'MCX',
//         'keyword': ''
//       });
//     });

//     // Handle response
//     socket.on('response', (data) {
//       print('Response received: $data');
//       try {
//         // Parse the response data into MCXDataEntity
//         final mcxData = MCXDataEntity.fromJson(data as Map<String, dynamic>);
//         // Call the callback function with the parsed data
//         onDataReceived?.call(mcxData);
//       } catch (e) {
//         print('Error parsing response: $e');
//       }
//     });

//     // Handle connection error
//     socket.onConnectError((err) {
//       print('Connect error: $err');
//     });

//     // Connect to the server
//     socket.connect();
//   }

//   void disconnect() {
//     socket.disconnect();
//   }
// }