# Background Socket Running Feature

## Overview
Added background socket running capability to MCX Wishlist WebSocket service. This allows the socket connection to continue running and emitting data even when the app is backgrounded or the page is deactivated.

## Features

### 1. **Background Mode Control**
```dart
// Enable background mode - socket keeps running when app is backgrounded
socket.enableBackgroundMode();

// Disable background mode - normal foreground operation only
socket.disableBackgroundMode();
```

### 2. **Automatic Background Handling**
The page now respects the `_useBackgroundMode` flag:
```dart
bool _useBackgroundMode = true; // Enable by default
```

When the app is paused, it automatically:
- Checks if background mode is enabled
- If enabled: socket continues running (emitting data)
- If disabled: socket pauses emission

### 3. **Pause/Resume with Background Support**
```dart
// Pause reconnect with background mode option
socket.pauseReconnect(enableBackground: true);  // Keep running
socket.pauseReconnect(enableBackground: false); // Stop emission

// Resume from pause
socket.resumeReconnect();
```

### 4. **Cached Credentials**
The service now caches userKey and deviceID to support resuming emissions after pause:
```dart
String? _cachedUserKey;
String? _cachedDeviceID;
```

These are stored during initial connection and reused when resuming.

## How It Works

### Without Background Mode (Default OFF)
```
Initial Load
  ↓
[initState] → socket.connect()
  ↓
[deactivate] → socket.pauseReconnect() → emission STOPS
  ↓
[Navigate Away]
  ↓
[Navigate Back / activate] → socket.resumeReconnect() → emission RESTARTS
```

### With Background Mode (NEW - Enabled ON)
```
Initial Load
  ↓
[initState] → socket.enableBackgroundMode() → socket.connect()
  ↓
[App Paused / deactivate] → socket.pauseReconnect(enableBackground: true)
  ↓
[App in Background] → socket KEEPS RUNNING, keeps emitting data ✅
  ↓
[App Resumed / activate] → socket.resumeReconnect()
  ↓
[App in Foreground] → emission continues smoothly
```

## Configuration

### In MCX Stock Wishlist Page
Enable or disable background mode:
```dart
bool _useBackgroundMode = true; // Change to false to disable

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);
  _isActive = true;
  _initializeWebSocket();
}

void _initializeWebSocket() {
  socket = MCXWishlistWebSocketService(...);
  
  // Enable background mode if configured
  if (_useBackgroundMode) {
    socket!.enableBackgroundMode();
  }
  
  socket!.connect();
}
```

### App Lifecycle Handling
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  switch (state) {
    case AppLifecycleState.paused:
      // Pass the background mode flag to pauseReconnect
      socket!.pauseReconnect(enableBackground: _useBackgroundMode);
      break;
    case AppLifecycleState.resumed:
      socket!.resumeReconnect();
      break;
  }
}
```

## Benefits

✅ **Continuous Data Updates** - Data keeps flowing even when app is backgrounded
✅ **Better User Experience** - User sees latest data when returning to app
✅ **Reduced Latency** - No need to reconnect/re-emit when returning
✅ **Power Efficient** - Socket continues at configured interval (200ms)
✅ **Configurable** - Can be enabled/disabled per page or globally

## Lifecycle Summary

### State Flags
- `_backgroundMode` - Controls whether socket keeps running when paused
- `_isActive` - Tracks if widget is actively displayed
- `_disposed` - Tracks if widget has been permanently destroyed

### Key Methods

| Method | Purpose | Background? |
|--------|---------|------------|
| `connect()` | Initial connection | N/A |
| `enableBackgroundMode()` | Turn on background running | - |
| `disableBackgroundMode()` | Turn off background running | - |
| `pauseReconnect(enableBackground)` | Pause with background option | Yes |
| `resumeReconnect()` | Resume from pause | No |
| `disconnect()` | Full cleanup | No |

## Technical Details

### _stopPeriodicEmit() Behavior
```dart
void _stopPeriodicEmit() {
  if (_backgroundMode) {
    developer.log('Background mode active: keeping emission running');
    return; // Skip cancellation, keep timer running
  }
  
  _emitTimer?.cancel();
  _emitTimer = null;
}
```

When background mode is enabled, the timer is NOT cancelled, allowing it to continue running.

### Emission Interval
- Default: 200ms between emissions
- Constant: `static const Duration _emitInterval = Duration(milliseconds: 200);`

## Usage Example

```dart
// Enable background socket for continuous data updates
class MyWishlistPage extends StatefulWidget {
  @override
  State<MyWishlistPage> createState() => _MyWishlistPageState();
}

class _MyWishlistPageState extends State<MyWishlistPage> with WidgetsBindingObserver {
  bool _useBackgroundMode = true; // Enable background running
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSocket();
  }
  
  void _initializeSocket() {
    socket = MCXWishlistWebSocketService(...);
    
    if (_useBackgroundMode) {
      socket!.enableBackgroundMode();
    }
    
    socket!.connect();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      socket!.pauseReconnect(enableBackground: _useBackgroundMode);
    } else if (state == AppLifecycleState.resumed) {
      socket!.resumeReconnect();
    }
  }
}
```

## Testing Checklist

- [ ] Load wishlist page - socket connects, background mode enabled
- [ ] Send app to background (lock phone) - socket keeps emitting
- [ ] Bring app to foreground - socket continues smoothly
- [ ] Navigate to another page (deactivate) - emission pauses/continues based on mode
- [ ] Navigate back - emission resumes properly
- [ ] Disable background mode (`_useBackgroundMode = false`) - socket pauses on deactivate
- [ ] Check logs for "Background mode active: keeping emission running" messages

## Files Modified

1. **mcx_wishlist_websocket.dart**
   - Added `_backgroundMode` flag
   - Added `_cachedUserKey` and `_cachedDeviceID`
   - Added `enableBackgroundMode()` and `disableBackgroundMode()`
   - Updated `pauseReconnect()` to accept `enableBackground` parameter
   - Updated `resumeReconnect()` to restart emissions
   - Updated `_stopPeriodicEmit()` to respect background mode

2. **mcx_stock_wishlist_riverpod.dart**
   - Added `_useBackgroundMode` flag (default: true)
   - Added `WidgetsBindingObserver` for app lifecycle
   - Implemented `didChangeAppLifecycleState()` with background support
   - Implemented proper `deactivate()` and `activate()` methods
   - Updated callbacks to check `_isActive` flag

## Future Enhancements

- [ ] Add configuration UI to toggle background mode per page
- [ ] Add battery optimization (reduce emission interval in background)
- [ ] Add notifications for important price changes while backgrounded
- [ ] Add background task handling with WorkManager for Android
