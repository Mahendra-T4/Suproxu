# Socket Singleton Implementation - Verification Guide

## ✅ Implementation Checklist

### 1. Module-Level Socket Singleton
- [x] Global socket variable declared at file top
- [x] Initialization flag declared at file top
- [x] Both are `late`/`bool` appropriately

**Location:** Lines 17-18
```dart
late MCXWishlistWebSocketService _globalSocketService;
bool _socketInitialized = false;
```

### 2. State Class Socket Access
- [x] Removed instance variable `late MCXWishlistWebSocketService socket;`
- [x] Added getter that returns global socket
- [x] All socket references use this getter

**Location:** Line 36
```dart
MCXWishlistWebSocketService get socket => _globalSocketService;
```

### 3. One-Time Initialization
- [x] initState checks `_socketInitialized` flag
- [x] Only initializes if flag is false
- [x] Sets flag to true after initialization
- [x] Initialization moved to separate method `_initializeGlobalSocket()`

**Location:** Lines 41-56
```dart
void initState() {
  super.initState();
  Future.microtask(() {
    if (!mounted || _disposed) return;
    
    // Initialize global socket only once
    if (!_socketInitialized) {
      _initializeGlobalSocket();
      _socketInitialized = true;
    }
    ...
  });
}
```

### 4. Socket Initialization Method
- [x] Creates socket service with callbacks
- [x] Calls `socket.connect()`
- [x] Separate from initState (clean separation of concerns)

**Location:** Lines 57-65
```dart
void _initializeGlobalSocket() {
  _globalSocketService = MCXWishlistWebSocketService(
    onDataReceived: _onSocketDataReceived,
    onError: _onSocketError,
    onConnected: _onSocketConnected,
    onDisconnected: _onSocketDisconnected,
    keyword: '',
  );
  _globalSocketService.connect();
}
```

### 5. Callback Methods
- [x] `_onSocketDataReceived()` - updates UI when data arrives
- [x] `_onSocketError()` - handles errors
- [x] `_onSocketConnected()` - refreshes data on connection
- [x] `_onSocketDisconnected()` - logs disconnection
- [x] All use `if (mounted && !_disposed)` guards

**Location:** Lines 66-105

### 6. Lifecycle Methods Simplified
- [x] `deactivate()` - does nothing socket-related
- [x] `activate()` - just refreshes data, no reconnection attempts
- [x] `dispose()` - does NOT call socket.disconnect()

**Location:** Lines 176-191
```dart
@override
void dispose() {
  _disposed = true;
  // NEVER disconnect global socket - it's app-level resource
  super.dispose();
}

@override
void deactivate() {
  // Don't do anything - let socket stay alive
  super.deactivate();
}

@override
void activate() {
  if (!_disposed && mounted) {
    _refreshWishlistData();
  }
  super.activate();
}
```

### 7. Navigation Handler Simplified
- [x] Removed `_isNavigating = true` before navigation
- [x] Removed `setState(() => _isNavigating = false)` in callback
- [x] Just calls `_refreshWishlistData()` when returning
- [x] No socket flags or checks

**Location:** Lines 245-259
```dart
if (item.symbol != null) {
  context
      .pushNamed(
        MCXSymbolRecordPage.routeName,
        extra: MCXSymbolParams(...),
      )
      .then((_) {
        if (mounted && !_disposed) {
          debugPrint('Returned from symbol page - refreshing data');
          _refreshWishlistData();
        }
      });
}
```

### 8. Removed Code
- [x] Removed `bool _isNavigating = false;` from state variables
- [x] Removed all `_isNavigating` flag checks
- [x] Removed socket reconnection logic from `activate()`
- [x] Removed socket disconnect logic from `dispose()`

## 🧪 Testing Instructions

### Test 1: Single Navigation
1. Open app
2. Navigate to MCX Wishlist
3. Tap a stock symbol
4. Verify socket stays connected (check debug output)
5. Verify detail page loads correctly
6. Go back
7. Verify prices still updating

**Expected Result:** No socket errors, prices update in real-time

### Test 2: Multiple Navigations
1. Open app
2. Tap symbol 1 → detail page → back
3. Tap symbol 2 → detail page → back
4. Tap symbol 3 → detail page → back
5. Check debug output for "Disconnected" messages

**Expected Result:** No disconnection logs, socket stays connected

### Test 3: Rapid Navigation
1. Tap symbol
2. Press back immediately (before detail page fully loads)
3. Repeat 3-4 times rapidly

**Expected Result:** No crashes, no socket errors

### Test 4: Data Integrity
1. Note a stock price on wishlist
2. Navigate to detail page
3. Return to wishlist
4. Verify price is up-to-date (matches detail page)

**Expected Result:** Data matches across pages

## 🐛 Debugging Tips

### Check Initialization
Look for this in console:
```
I/flutter ( ####): MCX Wishlist WebSocket Connected
I/flutter ( ####): Refreshing MCX Wishlist Data
```
Should appear only ONCE when page first loads.

### Check Navigation
When navigating, you should NOT see:
```
E/flutter ( ####): MCX Wishlist WebSocket Disconnected
```

You SHOULD see:
```
I/flutter ( ####): Page deactivated
I/flutter ( ####): Page activated - refreshing data
I/flutter ( ####): Returned from symbol page - refreshing data
```

### Common Issues

**Issue:** "Socket disconnected after navigation"
- Check that `_socketInitialized` is a module-level variable (not state variable)
- Verify `dispose()` is NOT calling `socket.disconnect()`
- Check MCXWishlistWebSocketService isn't setting `_isDisposed = true`

**Issue:** "Prices not updating after returning"
- Make sure `activate()` calls `_refreshWishlistData()`
- Verify socket is still connected (check `socket.isConnected`)

**Issue:** "Multiple socket connections being created"
- Verify `_socketInitialized` flag is properly set to true
- Check that multiple page instances aren't being created
- Look for "MCX Wishlist WebSocket Connected" appearing multiple times

## 📊 Key Metrics to Track

After implementing this fix, verify:

- ✅ Socket connection count = 1 (only created once)
- ✅ Navigation count without disconnection = unlimited
- ✅ Time socket stays connected = app lifetime
- ✅ Memory leaks = 0 (socket isn't recreated per page)
- ✅ Data refresh latency = <100ms

## 📝 Code References

| Component | File | Lines |
|---|---|---|
| Module-level socket | mcx_stock_wishlist_fixed.dart | 17-18 |
| Socket getter | mcx_stock_wishlist_fixed.dart | 36 |
| initState with flag check | mcx_stock_wishlist_fixed.dart | 41-56 |
| Socket initialization | mcx_stock_wishlist_fixed.dart | 57-65 |
| Callbacks | mcx_stock_wishlist_fixed.dart | 66-105 |
| Lifecycle methods | mcx_stock_wishlist_fixed.dart | 176-191 |
| Navigation handler | mcx_stock_wishlist_fixed.dart | 245-259 |

