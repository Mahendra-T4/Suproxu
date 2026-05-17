# Socket Singleton - Visual Architecture

## Application Structure - Before vs After

### ❌ BEFORE (Broken)
```
┌─────────────────────────────────────┐
│         Application                 │
│  ┌─────────────────────────────────┐│
│  │      Navigation Stack           ││
│  │  ┌──────────────┐               ││
│  │  │ Wishlist     │               ││
│  │  │ ┌──────────┐ │               ││
│  │  │ │ Socket 1 │ │               ││
│  │  │ │(Created) │ │               ││
│  │  │ └──────────┘ │               ││
│  │  └──────────────┘               ││
│  │         │ navigate              ││
│  │         ↓                       ││
│  │  ┌──────────────┐               ││
│  │  │ Symbol Dtl   │               ││
│  │  │ ┌──────────┐ │               ││
│  │  │ │ Socket ? │ │ ← Creates new ││
│  │  │ │(Accessed)│ │   or uses old?││
│  │  │ └──────────┘ │               ││
│  │  └──────────────┘               ││
│  │         │ go back               ││
│  │         ↓                       ││
│  │  ┌──────────────┐               ││
│  │  │ Wishlist     │               ││
│  │  │ ┌──────────┐ │               ││
│  │  │ │ Socket 1 │ │ ← DEAD!       ││
│  │  │ │(Dead)    │ │   _isDisposed ││
│  │  │ └──────────┘ │   = true      ││
│  │  └──────────────┘               ││
│  └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

**Problem:** Socket gets disposed when page is destroyed, can't reconnect

---

### ✅ AFTER (Fixed)
```
┌──────────────────────────────────────────────┐
│             Application                      │
│  ┌────────────────────────────────────────┐  │
│  │   Global Services (App Lifetime)       │  │
│  │   ┌──────────────────────────────────┐ │  │
│  │   │ Global Socket Service            │ │  │
│  │   │ ┌────────────────────────────────┤ │  │
│  │   │ │ Created: Once at app start     │ │  │
│  │   │ │ Lives: Until app exit          │ │  │
│  │   │ │ State: Always "Connected"      │ │  │
│  │   │ │ Lifecycle: INDEPENDENT         │ │  │
│  │   │ └────────────────────────────────┤ │  │
│  │   └──────────────────────────────────┘ │  │
│  └────────────────────────────────────────┘  │
│                    │ ↑ │                      │
│     ┌──────────────┘ │ └──────────────┐      │
│     ↓                                 ↓      │
│  ┌──────────────┐              ┌──────────────┐
│  │ Wishlist     │              │ Symbol Dtl   │
│  │ Page 1       │              │ Page 2       │
│  │ ┌──────────┐ │              │ ┌──────────┐ │
│  │ │ Uses     │ │              │ │ Uses     │ │
│  │ │ Global   │ │──navigate───→│ │ Global   │ │
│  │ │ Socket   │ │              │ │ Socket   │ │
│  │ │ (lives)  │ │←──back ─────│ │ (same!)  │ │
│  │ │ Updated! │ │              │ └──────────┘ │
│  │ └──────────┘ │              └──────────────┘
│  └──────────────┘
└──────────────────────────────────────────────┘
```

**Solution:** Socket lives at app level, all pages access the same instance

---

## Initialization Flow - Detailed

### First Page Load
```
App Starts
    │
    ↓
_socketInitialized = false ← Module-level flag
    │
    ↓
McxStockWishlist Page 1 created
    │
    ↓
initState() called
    │
    ↓
Check: _socketInitialized == false? ✓ YES
    │
    ↓
Call: _initializeGlobalSocket()
    │
    ├─→ Create: MCXWishlistWebSocketService(...)
    │
    ├─→ Set Callbacks:
    │  ├─→ onDataReceived: _onSocketDataReceived
    │  ├─→ onError: _onSocketError
    │  ├─→ onConnected: _onSocketConnected
    │  └─→ onDisconnected: _onSocketDisconnected
    │
    └─→ Call: socket.connect()
    │
    ↓
Set: _socketInitialized = true ← LOCK: prevent re-init
    │
    ↓
Emit: "MCX Wishlist WebSocket Connected" (ONCE)
    │
    ↓
Request: _refreshWishlistData()
    │
    ↓
Socket ready, data flows
```

### Subsequent Page Loads
```
McxStockWishlist Page 2 (or 3, 4, ...) created
    │
    ↓
initState() called
    │
    ↓
Check: _socketInitialized == false? ✗ NO (already true)
    │
    ├─→ SKIP: _initializeGlobalSocket()
    │
    └─→ REUSE: _globalSocketService
    │
    ↓
Call: _refreshWishlistData()
    │
    ↓
Socket still connected, fresh data received
```

---

## Navigation Flow - Step by Step

### User Taps Symbol
```
User Action
    │
    ├─→ onTap() handler
    │
    ├─→ context.pushNamed()
    │
    └─→ Navigator animation starts
         │
         ↓
    Current page: deactivate() called
         │
         ├─→ Does nothing socket-wise
         │   (OLD: set _isNavigating=true) ← REMOVED
         │
         └─→ Page paused
             │
             ↓
         Detail page: initState() called
             │
             ├─→ Check _socketInitialized
             │
             ├─→ (already true, skip init)
             │
             └─→ Socket still running! ✅
                 │
                 ↓
             Detail page: build()
                 │
                 └─→ Shows with real-time data
```

### User Goes Back
```
User Action: Press Back
    │
    ├─→ Pop Navigator
    │
    ├─→ Detail page: dispose() called
    │   ├─→ _disposed = true
    │   └─→ Does NOT touch socket
    │
    ├─→ Detail page: deactivate() called
    │   └─→ Does nothing
    │
    └─→ Navigator animation returns to Wishlist
         │
         ↓
    Wishlist page: activate() called
         │
         ├─→ Check: _disposed? ✗ NO
         │
         └─→ Call: _refreshWishlistData()
             │
             ↓
         Socket still connected ✅
             │
             ↓
         Fresh data received
             │
             ↓
         UI updates with latest prices ✅
```

---

## Data Flow - Real-time Updates

### During Navigation
```
Socket Connected (at global level)
         │
         ├─→ Receives price update for NIFTY
         │
         ├─→ Call onDataReceived() callback
         │
         └─→ Check: mounted && !_disposed? ✓
             │
             └─→ Update UI with new price
                 │
                 ↓
            Wishlist Page:
            [Price: 23456.50] ← Updates in real-time
            
            Symbol Detail Page:
            [Price: 23456.50] ← Same data
```

### Multiple Updates
```
Second 0: User navigates (Wishlist → Detail)
          Socket: Still connected ✅
          
Second 1: Price updates arrive
          Socket: Processes and sends callbacks ✅
          
Second 2: Callback checks: mounted && !_disposed
          Wishlist: Not in view, skipped
          Detail: In view, updates ✅
          
Second 3: User goes back (Detail → Wishlist)
          Socket: Still connected ✅
          Wishlist: Refreshes with latest data ✅
```

---

## Memory Model - Object Lifecycle

### Before (Problem)
```
RAM
├─ McxStockWishlist Page 1
│  └─ _McxStockWishlistState
│     ├─ socket = MCXWishlistWebSocketService instance A
│     │  └─ _isDisposed = false
│     └─ listeners...
│
├─ Navigate to Detail Page
│  ├─ Page 1 → deactivate()
│  ├─ Page 1 → dispose()
│  │  └─ socket.disconnect() ← CALLED
│  │     └─ service A: _isDisposed = true ❌
│  │
│  └─ Service A: Marked for garbage collection
│
└─ Return to Wishlist Page
   └─ McxStockWishlist Page 1 (new instance)
      └─ _McxStockWishlistState
         ├─ socket = MCXWishlistWebSocketService instance B (NEW!)
         │  └─ _isDisposed = false
         │  └─ RECONNECTS (2-3 second delay) ⏱
         └─ listeners...
```

### After (Fixed)
```
RAM
├─ Global Module Level
│  └─ _globalSocketService = MCXWishlistWebSocketService instance A
│     ├─ _isDisposed = false (NEVER changes)
│     ├─ Connected = true (STAYS connected)
│     └─ _socketInitialized = true
│
├─ McxStockWishlist Page 1
│  └─ _McxStockWishlistState
│     ├─ socket getter → _globalSocketService (A)
│     └─ listeners...
│
├─ Navigate to Detail Page
│  ├─ Page 1 → deactivate() (does nothing)
│  │
│  ├─ Service A: Still connected ✅ (no changes)
│  │
│  └─ Symbol Detail Page
│     └─ Uses same service A
│
└─ Return to Wishlist Page
   └─ McxStockWishlist Page 1 (new instance)
      ├─ initState() → _socketInitialized already true
      ├─ socket getter → _globalSocketService (A)
      │
      └─ Service A: Still connected ✅ (no disconnect/reconnect)
```

---

## Timeline - Socket Lifecycle

### Before (Broken - Socket Recreated)
```
Time    Event                           Socket Status
────────────────────────────────────────────────────────
0:00    App starts                      Not initialized
0:02    Wishlist page opens             Create & Connect ✅
0:05    Real-time prices updating       Connected ✅
0:15    User taps symbol                
0:16    deactivate() called             Still connected
0:17    navigate completed              Dispose called
        socket.disconnect()             ❌ DISCONNECTED
0:18    Detail page fully shown         [2 second delay]
0:19    Reconnecting...                 Reconnecting 🔄
0:21    Detail page has prices          Reconnected ✅
        (after 2-3 second delay)
0:25    User goes back                  
0:26    activate() called               Trying to connect
0:27    Back to Wishlist                Still reconnecting...
0:30    Prices finally update           Connected ✅
        [Total delay: 15 seconds!]
```

### After (Fixed - Socket Persistent)
```
Time    Event                           Socket Status
────────────────────────────────────────────────────────
0:00    App starts                      Not initialized
0:02    Wishlist page opens             Create & Connect ✅
0:05    Real-time prices updating       Connected ✅
0:15    User taps symbol                Connected ✅
0:16    deactivate() called             Connected ✅
0:17    navigate completed              Connected ✅
0:18    Detail page fully shown         Connected ✅
        (No delay!)
0:19    Real-time prices updating       Connected ✅
0:25    User goes back                  Connected ✅
0:26    activate() called               Connected ✅
0:27    Back to Wishlist                Connected ✅
        (Immediate! No delay)
0:28    Prices updating                 Connected ✅
        [Total delay: 0 seconds!]
```

---

## State Machine - Socket Connection

### Before
```
         ┌─────────────┐
         │   Created   │
         │             │
         └──────┬──────┘
                │ initState()
                ↓
         ┌─────────────┐
    ┌───→│ Connecting  │
    │    │             │
    │    └──────┬──────┘
    │           │ .connect()
    │           ↓
    │    ┌─────────────┐
    │    │ Connected   │ ← Real-time updates
    │    │             │
    │    └──────┬──────┘
    │           │ deactivate/dispose
    │           ↓
    │    ┌─────────────┐
    │    │ Disconnecting
    │    │ _isDisposed=true
    │    └──────┬──────┘
    │           │
    │           ↓
    │    ┌─────────────┐
    │    │ Disconnected│ ← STUCK HERE
    │    │ Can't reset │
    │    └─────────────┘
    │
    └─ activate() tries to reconnect
       (Usually fails until hard reset)
```

### After
```
         ┌─────────────┐
         │   Created   │
         │ (once only) │
         └──────┬──────┘
                │ initState() on Page 1
                ↓
         ┌─────────────┐
         │ Connecting  │
         │             │
         └──────┬──────┘
                │ .connect()
                ↓
         ┌─────────────┐
    ┌───→│ Connected   │ ← STAYS HERE
    │    │ FOREVER     │ ← Real-time updates
    │    │             │ ← All pages use this
    │    └──────┬──────┘
    │           │
    │ initState() on Page 2,3,4...
    │ (reuses connection)
    │
    └─ activate() just refreshes data
       (connection still active)
```

---

## Code Execution Timeline

### Page Navigation Sequence

```
BEFORE NAVIGATION:
Wishlist Page running
  → initState() ✓ executed
  → build() ✓ rendering
  → Socket listening to updates ✓

USER TAPS SYMBOL:
onTap() handler
  → context.pushNamed() called
  → Navigator starts transition

DURING TRANSITION:
Wishlist Page
  → deactivate() called
  → activate() called (prepared to pause)
  
Symbol Detail Page
  → initState() called
  → build() started
  → Still waiting for socket connection...
     (BROKEN: socket might be disconnected)
     (FIXED: socket always connected)

AFTER TRANSITION COMPLETE:
Symbol Detail Page
  → render with data
  
USER GOES BACK:
Navigator.pop() called

DURING POP:
Symbol Detail Page
  → deactivate() called
  → dispose() called
  
Wishlist Page
  → activate() called
  → build() called

AFTER POP COMPLETE:
Wishlist Page
  → Rendered with latest data
     (BROKEN: waiting for reconnection)
     (FIXED: data already fresh)
```

---

## Summary Visual

```
❌ BEFORE (Broken)
Socket Lifecycle = Page Lifecycle
   ├─ New page = New socket
   ├─ Navigate = Disconnect & reconnect
   └─ Result: Data lag, errors, complexity

✅ AFTER (Fixed)
Socket Lifecycle = App Lifetime
   ├─ One socket for entire app
   ├─ Navigate = Seamless, no disconnect
   └─ Result: Smooth, fast, simple
```

