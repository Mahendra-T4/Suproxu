# MCX Wishlist Data Overlapping Fix Guide

## Problem Analysis
Data overlapping occurs when switching between tabs in the WishList page because:
1. Multiple socket instances were being created without proper cleanup
2. Old sockets remained connected while new ones were created
3. Data from multiple socket instances accumulated in the UI
4. No deduplication mechanism existed

## Solution Implemented

### 1. **WebSocket Service Improvements** 
**File**: `mcx_wishlist_websocket.dart`

#### Added Connection Guard
```dart
bool _connectionAttempted = false;

Future<void> connect() async {
  // Prevent duplicate connection attempts
  if (_connectionAttempted) {
    log('Connection already attempted, skipping...');
    return;
  }
  _connectionAttempted = true;
  // ... rest of connection logic
}
```
**Purpose**: Prevents multiple connection attempts from creating duplicate sockets

#### Improved Disconnect Logic
```dart
void disconnect() {
  _emitTimer?.cancel();
  _connectionAttempted = false;  // Reset flag on disconnect
  // ... cleanup logic
}
```
**Purpose**: Allows proper reconnection after disconnect

#### Enhanced Data Validation
The `_handleResponseData` method now includes three guards:

**Guard 1**: Market validation (MCX vs other markets)
**Guard 2**: Symbol-level response rejection (prevents individual stock data from polluting wishlist)
**Guard 3**: Empty watchlist rejection (only processes non-empty responses)

### 2. **UI State Management Fixes**
**File**: `mcx_stock_wishlist_riverpod.dart`

#### Added Lifecycle Management
```dart
@override
void deactivate() {
  // Disconnect socket when tab is deactivated to prevent data overlap
  debugPrint('MCX Tab deactivated - disconnecting socket');
  try {
    socket.disconnect();
  } catch (e) {
    debugPrint('Error disconnecting socket on deactivate: $e');
  }
  super.deactivate();
}

@override
void activate() {
  // Reconnect socket when tab is activated again
  debugPrint('MCX Tab activated - reconnecting socket');
  if (!_disposed && mounted) {
    _initializeWebSocket();
  }
  super.activate();
}
```
**Purpose**: 
- Cleanly disconnects socket when user switches away from MCX tab
- Reconnects when user switches back to MCX tab
- Prevents data accumulation from orphaned sockets

#### Added Data Deduplication Tracker
```dart
final Set<String> _processedSymbolKeys = {}; // Track processed data

// In onDataReceived callback:
_processedSymbolKeys.clear();
for (var item in _localWatchlist) {
  _processedSymbolKeys.add(item.symbolKey.toString());
}
```
**Purpose**: Tracks which symbols have been processed to detect duplicates

### 3. **Key Changes Summary**

| Component | Change | Benefit |
|-----------|--------|---------|
| Socket Connection | Added `_connectionAttempted` flag | Prevents duplicate connections |
| Socket Disconnect | Reset flag on disconnect | Allows clean reconnection |
| Tab Lifecycle | Implement `deactivate()` | Disconnects when tab is hidden |
| Tab Lifecycle | Implement `activate()` | Reconnects when tab is shown |
| Data Handling | Added `_processedSymbolKeys` tracker | Enables deduplication |
| Response Handler | Three-layer validation guards | Filters out invalid data early |

## Testing Checklist

- [x] Switch from MCX tab to NFO tab and back
- [x] Verify no duplicate data appears
- [x] Check logs for "MCX Tab deactivated" and "MCX Tab activated" messages
- [x] Verify socket reconnects properly
- [x] Test with multiple rapid tab switches

## How It Works

1. **User switches to MCX tab**:
   - `activate()` called → `_initializeWebSocket()` → socket connects

2. **User switches away from MCX tab**:
   - `deactivate()` called → `socket.disconnect()` → old socket cleaned up

3. **User switches back to MCX tab**:
   - `activate()` called → new socket instance created and connected
   - `_processedSymbolKeys` reset → ready for new data

4. **Socket receives data**:
   - Guard 1: Validates market category (MCX)
   - Guard 2: Rejects individual stock responses
   - Guard 3: Rejects empty watchlists
   - Only valid data reaches UI

## Debugging

Enable verbose logging to monitor socket lifecycle:
```
MCX Tab activated - reconnecting socket
MCX Wishlist Connected: [socket-id]
✓ MCX Wishlist Data Parsed: N items
MCX Tab deactivated - disconnecting socket
```

## Future Recommendations

1. Consider using a singleton pattern with reference counting for socket management
2. Implement automatic retry with exponential backoff
3. Add metrics tracking for data overlap incidents
4. Consider Riverpod providers for better state management
