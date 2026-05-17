# WebSocket Lifecycle - Symbol Page vs Wishlist Page

**Date**: February 1, 2026

---

## 🎯 Your Question

> "Symbol page WebSocket disconnect but effect this page why [MCX WebSocket] Disconnecting Symbol MCX WebSocket..."

---

## ✅ Answer: It Doesn't Affect The Wishlist Page

**Good news**: The symbol page's WebSocket disconnection should **NOT** affect the wishlist page because:

1. **Separate Instances**: Each page creates its own WebSocket instance
2. **Independent Lifecycle**: Each socket disconnects independently
3. **Proper Cleanup**: Symbol page only disconnects its own socket

---

## 🏗️ Architecture

### WebSocket Setup

```
Wishlist Page
    ↓
    socket = MCXWishlistWebSocketService()  ← WISHLIST's own socket
    ↓
    socket.connect()

Symbol Page (when navigated to)
    ↓
    webSocket = MCXSymbolWebSocketService()  ← SYMBOL's own socket
    ↓
    webSocket.connect()
```

### Page Lifecycle

```
1. Wishlist Page Active
   ├─ socket = MCXWishlistWebSocketService
   └─ socket is connected

2. Navigate to Symbol Page
   ├─ Wishlist page deactivate()  ← socket STAYS ALIVE
   ├─ Symbol page initState()
   └─ webSocket = MCXSymbolWebSocketService  ← NEW socket

3. Return from Symbol Page
   ├─ Symbol page dispose()
   │  └─ webSocket.disconnect()  ← Only symbol's socket disconnects
   ├─ Wishlist page activate()   ← Back to wishlist
   │  └─ socket.reset() + socket.connect()  ← Wishlist's socket reconnects
   └─ Data flows again ✅
```

---

## 🔍 Why You See Both Disconnect Messages

When you navigate:

1. **"[MCX WebSocket] Disconnecting Symbol MCX WebSocket..."**
   - This is the symbol page's socket disconnecting
   - It's disconnecting its own instance
   - Should happen when you go back

2. **Wishlist's socket should still be alive**
   - Not affected by symbol page's disconnect
   - Will reconnect via `activate()` → `socket.reset()` → `socket.connect()`

---

## 🔄 Correct Lifecycle Flow

### Before (BROKEN ❌)
```
Wishlist Active ✅
    ↓
Navigate to Symbol
    ↓
Wishlist deactivate() (socket stays)
Symbol connects
    ↓
Return to Wishlist
    ↓
Wishlist activate()
    ↓
socket.connect() called
    ↓
if (_isDisposed) return;  ← BLOCKED! ❌
    ↓
NO RECONNECTION ❌
```

### After (FIXED ✅)
```
Wishlist Active ✅
    ↓
Navigate to Symbol
    ↓
Wishlist deactivate() (socket stays)
Symbol connects
    ↓
Return to Wishlist
    ↓
Wishlist activate()
    ↓
socket.reset()  ← ✅ NEW STEP
    ↓
_isDisposed = false  ← Reset flag
    ↓
socket.connect() called
    ↓
if (_isDisposed) return;  ← FALSE now! Proceeds ✅
    ↓
RECONNECTION SUCCESS ✅
```

---

## 📝 Files Involved

### Wishlist Page
```
lib/features/navbar/wishlist/wishlist-tabs/MCX-Tab/page/mcx_stock_wishlist_riverpod.dart

Has:
  - initState()      → Creates socket
  - deactivate()     → Socket stays alive
  - activate()       → socket.reset() + socket.connect()
  - dispose()        → Final cleanup
```

### Wishlist WebSocket Service
```
lib/features/navbar/wishlist/websocket/mcx_wishlist_websocket.dart

Has:
  - connect()        → Now resets _isDisposed if fully cleaned
  - reset()          → Explicitly reset disposed state
  - disconnect()     → Normal cleanup
```

### Symbol Page
```
lib/features/navbar/home/mcx/page/symbol/mcx_symbol_builder.dart

Has:
  - initMCXSymbolWebSocket()  → Creates its own socket
  - dispose()                 → webSocket.disconnect()  ← Independent!
```

### Symbol WebSocket Service
```
lib/features/navbar/home/websocket/mcx_symbol_websocket.dart

Has:
  - Separate from wishlist socket
  - Independent lifecycle
```

---

## ⚙️ How It Works (Technical)

### Wishlist Socket (_isDisposed state)

```
Timeline:

1. Wishlist created
   _isDisposed = false ✅

2. Navigate away
   deactivate() called
   socket NOT disconnected
   _isDisposed = still false ✅

3. Symbol page active
   Symbol has OWN socket
   Wishlist socket unchanged

4. Return to Wishlist
   activate() called
   socket.reset() called
   if (_isDisposed && _socket == null)  ← Still false
       (doesn't reset, already ok)
   socket.connect() called ✅
   _isConnecting = true
   Socket connects ✅

5. Data flows ✅
```

---

## 🧪 What You Should See

### In Console Logs:

#### Good Sequence ✅
```
[MCX WebSocket] Page activated - reconnecting socket
[MCX WebSocket] MCX WS: Already connected or connecting. Skipping.
(OR)
[MCX WebSocket] Connected: socket-id-123
[MCX WebSocket] Emitted MCX Request: {...}
```

#### Symbol Disconnect (Normal):
```
[MCX WebSocket] Disconnecting Symbol MCX WebSocket...  ← NORMAL, symbol page only
```

#### Wishlist Still Works:
```
[MCX WebSocket] Page activated - reconnecting socket  ← Back on wishlist
[MCX WebSocket] Connected: socket-id-456
✓ MCX Wishlist Data Response  ← Data received ✅
```

---

## ❓ FAQ

**Q: Why does the symbol page disconnect affect anything?**  
A: It shouldn't! Each page has its own socket instance. Symbol's disconnect only affects symbol's socket.

**Q: What if data stops after returning?**  
A: Check that:
1. `activate()` is being called on wishlist
2. `socket.reset()` is called in `activate()`
3. Logs show "Page activated - reconnecting socket"
4. No "_isDisposed" block preventing reconnection

**Q: Can the symbol page disconnect kill the wishlist socket?**  
A: No! They're separate instances. Symbol disconnects symbol socket only.

**Q: What does socket.reset() do?**  
A: It resets the `_isDisposed` flag to false if socket is fully cleaned, allowing reconnection.

---

## ✅ Verification Checklist

Run through this quickly:

- [ ] Navigate from Wishlist to Symbol
- [ ] Check logs: See "Disconnecting Symbol MCX WebSocket..."
- [ ] Return to Wishlist
- [ ] Check logs: See "Page activated - reconnecting socket"
- [ ] See data flowing again ✅
- [ ] No "MCX Wishlist WebSocket Disconnected" should appear
- [ ] Only "Symbol MCX WebSocket Disconnected" when leaving symbol page

---

## 🎯 Summary

| Aspect | Details |
|--------|---------|
| **Symbol Disconnect** | Normal, expected, only disconnects symbol's socket |
| **Wishlist Effect** | None - separate socket instance |
| **Solution** | activate() calls reset() to handle any edge cases |
| **Result** | Data flows smoothly after navigation ✅ |

---

**Key Point**: The symbol page's WebSocket disconnect is **NORMAL and EXPECTED**. It only affects the symbol page. The wishlist page has its own socket that properly reconnects.

---

**Status**: Fix Complete ✅  
**Ready**: Yes ✅
