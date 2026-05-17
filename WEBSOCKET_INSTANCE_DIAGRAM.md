# WebSocket Instances - Wishlist vs Symbol Page

**Quick Explanation**

---

## 🔌 Two Independent Socket Instances

```
┌─────────────────────────────────────────────────────────────┐
│                      Your App                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Wishlist Page (Active)          Symbol Page (Inactive)    │
│  ┌────────────────────┐          ┌────────────────────┐    │
│  │ socket =           │          │ webSocket =        │    │
│  │ MCXWishlist        │          │ MCXSymbol          │    │
│  │ WebSocketService() │          │ WebSocketService() │    │
│  │                    │          │                    │    │
│  │ Status: CONNECTED  │          │ Status: NONE       │    │
│  │ Data: FLOWING ✅   │          │ Data: N/A          │    │
│  │                    │          │                    │    │
│  └────────────────────┘          └────────────────────┘    │
│         ↓                                ↓                   │
│      Has own                         Has own                │
│      socket instance                 socket instance        │
│      Separate from                   Separate from          │
│      symbol page                     wishlist page          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎬 When You Navigate

### Step 1: Navigate from Wishlist to Symbol
```
Wishlist Page                        Symbol Page
┌──────────────────┐                ┌──────────────────┐
│ socket ✅        │                │ webSocket        │
│ Connected        │    Navigate    │ Creating...      │
│ FLOWING ✅       │ ─────────→     │                  │
│                  │                │ (new instance)   │
└──────────────────┘                └──────────────────┘

Wishlist: deactivate() called
  └─ socket STAYS ALIVE (not disconnected) ✅

Symbol: initState() called
  └─ webSocket = new instance (independent)
```

### Step 2: While on Symbol Page
```
Wishlist Page (deactivated)          Symbol Page (active)
┌──────────────────┐                ┌──────────────────┐
│ socket ✅        │                │ webSocket ✅     │
│ Sleeping         │                │ Connected        │
│ (not killed)     │                │ FLOWING ✅       │
│                  │                │                  │
└──────────────────┘                └──────────────────┘

Two separate sockets, working independently
```

### Step 3: Return to Wishlist
```
Wishlist Page (back active)          Symbol Page (destroyed)
┌──────────────────┐                ┌──────────────────┐
│ socket ✅        │                │ webSocket        │
│ Reconnecting     │   Back         │ Disconnecting... │
│ (reactivating)   │ ←───────       │ dispose() called │
│                  │                │                  │
└──────────────────┘                └──────────────────┘

Symbol: dispose() called
  └─ webSocket.disconnect()  ← Symbol's socket dies (normal)
  
Wishlist: activate() called
  └─ socket.reset() + socket.connect()  ← Wishlist's socket reconnects ✅
     (independent process, NOT affected by symbol's disconnect)
```

---

## 💡 The Key Insight

```
WISHLIST SOCKET          SYMBOL SOCKET
     ↓                        ↓
┌──────────┐             ┌──────────┐
│ Instance │             │ Instance │
│    #1    │             │    #2    │
│          │             │          │
│ Separate │             │ Separate │
│lifecycle │             │lifecycle │
└──────────┘             └──────────┘
     ↑                        ↑
  Controls                Controls
  Wishlist              Symbol Page
  Data                  Data

When symbol disconnects → Symbol socket dies ✅
Wishlist socket → Still alive, reconnects ✅
```

---

## ✅ What You'll See in Logs

### During Navigation

```
1. You tap item
   [Log] Page deactivated - socket stays alive
   
2. Symbol loads
   [Log] [MCX WebSocket] Connected: symbol-socket-id
   
3. You go back
   [Log] [MCX WebSocket] Disconnecting Symbol MCX WebSocket...  ← Symbol only!
   [Log] Page activated - reconnecting socket
   [Log] [MCX WebSocket] Connected: wishlist-socket-id  ← Wishlist's socket!
   
Data flows ✅
```

---

## 🎯 Bottom Line

| Item | Wishlist | Symbol |
|------|----------|--------|
| **Socket Instance** | MCXWishlistWebSocketService | MCXSymbolWebSocketService |
| **When Active** | Page shown | Page shown |
| **When Inactive** | Stays alive | Killed |
| **Disconnect Effect** | N/A (doesn't disconnect) | Only symbol page affected |
| **Data** | Flows when active | Flows when active |
| **Independence** | ✅ Yes | ✅ Yes |

---

## ❓ Simple Answer to Your Question

> "Why does symbol page WebSocket disconnect affect this page?"

**It doesn't.** They're separate sockets.

- Symbol socket dying = Symbol page loses data
- Wishlist socket = Completely independent
- Wishlist reconnects automatically ✅

---

**Think of it like:**
```
Two different WiFi connections on two devices:
- Turn off device B's WiFi → Device A still works
- Exactly the same principle here with WebSockets
```

---

**Status**: Explained ✅
