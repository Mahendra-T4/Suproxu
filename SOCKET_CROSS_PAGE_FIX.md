# Socket Disconnection Fix - MCX Pages

## Problem
When navigating to the MCX Symbol page, the websocket connections from MCX Home and MCX Wishlist pages were being disconnected. This was causing data to stop flowing on those pages.

## Root Cause
Each page (MCXHome, MCXSymbol, MCXWishlist) was creating its own independent socket connection using `IO.io()`. However, `socket_io_client` reuses socket connections when connecting to the same server with the same URL. This meant all three pages were actually sharing the same underlying socket instance.

When one page's `dispose()` method called `socket.disconnect()`, it would disconnect the entire shared socket, affecting all other pages using the same connection.

**Example:**
1. User opens MCXHome → creates socket connection (reference count: 1)
2. User navigates to MCXSymbol → reuses same socket (reference count: 2)
3. User leaves MCXSymbol → calls disconnect() → **kills the entire socket** (also breaks MCXHome)

## Solution
Implemented a **Singleton WebSocket Manager** with **Reference Counting** to properly manage the shared socket lifecycle.

### Architecture Changes

#### 1. **New Global Socket Manager** (`websocket_manager.dart`)
```dart
class MCXWebSocketManager {
  static final MCXWebSocketManager _instance = MCXWebSocketManager._internal();
  
  int _referenceCount = 0;
  
  Future<void> connect() {
    // Only creates socket once, increments reference count
    _referenceCount++;
  }
  
  void disconnect() {
    // Decrements reference count
    _referenceCount--;
    // Only fully disconnects when referenceCount == 0
  }
}
```

#### 2. **Updated WebSocket Services** to use the manager:
- `MCXSymbolWebSocketService` - for symbol detail pages
- `SocketService` - for MCX home list page  
- `MCXWishlistWebSocketService` - for MCX wishlist page

All now:
- Use the singleton manager instead of creating their own sockets
- Register as listeners with the manager
- Call `manager.disconnect()` instead of socket.disconnect() on dispose
- Unsubscribe their listeners when disposed

### How It Works

**Connection Flow:**
```
MCXHome.initState()
  ↓
MCXWebSocketManager.connect()
  ↓ _referenceCount = 1, socket created
  
User navigates to MCXSymbol.initState()
  ↓
MCXWebSocketManager.connect()
  ↓ _referenceCount = 2, reuses socket
  
MCXHome still running, MCXSymbol still running
Both receiving data on same socket
```

**Disconnection Flow:**
```
User leaves MCXSymbol.dispose()
  ↓
MCXWebSocketManager.disconnect()
  ↓ _referenceCount = 1, socket stays alive
  
MCXHome still works! ✓

User leaves MCXHome.dispose()
  ↓
MCXWebSocketManager.disconnect()
  ↓ _referenceCount = 0, socket finally disconnects
```

## Files Modified

1. **Created:**
   - `/lib/core/service/websocket/websocket_manager.dart` - Singleton manager with reference counting

2. **Updated:**
   - `/lib/features/navbar/home/websocket/mcx_symbol_websocket.dart`
   - `/lib/features/navbar/home/websocket/mcx_websocket_service.dart`
   - `/lib/features/navbar/wishlist/websocket/mcx_wishlist_websocket.dart`

## Key Benefits

✅ **No More Cross-Page Disconnections** - Leaving one page doesn't kill sockets on other pages
✅ **Single Socket Connection** - All MCX pages share one efficient socket
✅ **Proper Resource Cleanup** - Socket only disconnects when last page closes
✅ **Listener Pattern** - Each page only receives data it subscribes to
✅ **Activity Filtering** - Multiple listeners ensure no cross-contamination of data

## Testing Checklist

- [ ] Open MCX Home → data flows
- [ ] Navigate to MCX Symbol page → both pages receive data
- [ ] Navigate to MCX Wishlist → all three pages receive data  
- [ ] Go back from Symbol page → MCX Home still receives data
- [ ] Go back from Wishlist page → MCX Home still receives data
- [ ] Logout or close all pages → socket properly disconnects
