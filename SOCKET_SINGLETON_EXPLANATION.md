# Socket Singleton Pattern - MCX Wishlist Fix

## Problem
Socket was disconnecting when user navigated from wishlist to symbol detail page.

**Root Cause:**
- Page lifecycle (initState → deactivate → activate → dispose) was tied to socket lifecycle
- When user navigated, `deactivate()` was called, triggering socket operations
- Socket service's internal `_isDisposed` flag would prevent reconnection
- Previous workarounds (navigation flags, deactivate/activate handling) were insufficient because they didn't address the core issue

## Solution: App-Level Socket Singleton

The socket service is now initialized **ONCE** at the app level and **NEVER** tied to any page's lifecycle.

### How It Works

**Module Level (File Top):**
```dart
late MCXWishlistWebSocketService _globalSocketService;
bool _socketInitialized = false;
```

**Singleton Initialization (First Time Page is Created):**
```dart
void initState() {
  super.initState();
  Future.microtask(() {
    // Only initialize socket ONCE across entire app
    if (!_socketInitialized) {
      _initializeGlobalSocket();
      _socketInitialized = true;  // ← Prevents re-initialization
    }
    _localWatchlist = mcxWishlist.mcxWatchlist ?? [];
    _refreshWishlistData();
  });
}
```

**All Pages Share Same Socket:**
```dart
MCXWishlistWebSocketService get socket => _globalSocketService;
```

### Lifecycle Management Changes

| Lifecycle Method | Old Behavior | New Behavior |
|---|---|---|
| `initState()` | Create new socket instance | Check if global socket exists, reuse it |
| `deactivate()` | Set navigation flag, prepare for disconnect | Do nothing - socket isn't tied to page |
| `activate()` | Try to reconnect socket, reset flags | Just refresh data - socket stayed alive |
| `dispose()` | ❌ Was calling `socket.disconnect()` | ✅ Never disconnect global socket |

### Navigation Flow (Fixed)

```
User at Wishlist Page
         ↓
   (Page 1 created)
   initState() → _socketInitialized = false
   → _initializeGlobalSocket() → socket created
   → _socketInitialized = true ✅
         ↓
User taps symbol → context.pushNamed()
         ↓
   deactivate() → (do nothing, socket lives on)
   activate() → (do nothing, socket still connected)
         ↓
Symbol Detail Page opens
(Socket keeps running in background)
         ↓
User returns from detail page
         ↓
   navigate back → back to Wishlist Page
         ↓
Socket still connected ✅
Data refreshes automatically ✅
```

## Key Differences from Previous Approaches

### ❌ Previous Approach (Navigation Flag)
```dart
onTap: () {
  _isNavigating = true;  // Flag set but socket still had lifecycle issues
  context.pushNamed(...).then((_) {
    _isNavigating = false;
  });
}
```
**Problem:** Flag couldn't stop the socket service's internal `_isDisposed` flag from being set.

### ✅ New Approach (Singleton)
```dart
onTap: () {
  context.pushNamed(...).then((_) {
    _refreshWishlistData();  // Simple refresh, no flags needed
  });
}
```
**Solution:** Socket lifecycle is completely independent of page lifecycle.

## Testing Checklist

- [ ] Navigate to symbol detail page → socket stays connected
- [ ] Return from detail page → data refreshes
- [ ] Navigate away and back multiple times → no disconnections
- [ ] Check console for no error messages
- [ ] Verify real-time price updates continue during navigation

## Files Modified

- `mcx_stock_wishlist_fixed.dart`
  - Added module-level socket singleton
  - Modified state class to reference global socket
  - Updated initState with one-time initialization flag
  - Simplified deactivate/activate/dispose (no socket operations)
  - Removed `_isNavigating` flag and related logic

## Why This Works

1. **Initialization Happens Once:** Module-level `bool _socketInitialized = false` ensures socket is created exactly once
2. **No Page Lifecycle Interference:** Socket isn't created/destroyed by `initState`/`dispose`
3. **All Pages Share Socket:** Any page that needs data gets same socket instance via getter
4. **Navigation Doesn't Affect Connection:** `pushNamed()` doesn't trigger socket events anymore
5. **Auto-Reconnection Still Works:** Socket service's internal reconnection logic continues uninterrupted

## Architecture Pattern

This is the standard pattern for managing WebSocket/long-lived connections in mobile apps:
- Service lives at **app level** (Application root)
- Pages/UI lives at **page level** (Can be destroyed/recreated)
- Service is **independent** of page lifecycle
- Pages **subscribe** to service updates via callbacks
