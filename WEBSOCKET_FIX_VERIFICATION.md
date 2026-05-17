# WebSocket Navigation Fix - Verification Checklist

**Test Date**: _______________  
**Tester**: _______________

---

## ✅ Test Cases

### 1. Basic Navigation Test
- [ ] Open MCX Wishlist tab
- [ ] Wait for WebSocket to connect (should see data)
- [ ] Tap on any wishlist item to navigate to symbol page
- [ ] Verify symbol page loads and displays data
- [ ] Navigate back to wishlist (tap back button)
- [ ] **Expected**: WebSocket reconnects, data updates resume
- [ ] **Actual**: _____________________

### 2. Multiple Navigation Test
- [ ] Start on MCX Wishlist
- [ ] Navigate to symbol page (item 1)
- [ ] Go back to wishlist
- [ ] Navigate to symbol page (item 2)
- [ ] Go back to wishlist
- [ ] **Expected**: All navigations work, socket stays responsive
- [ ] **Actual**: _____________________

### 3. Price Update Test
- [ ] Open MCX Wishlist
- [ ] Observe price updates (blinking/changing)
- [ ] Navigate to symbol page
- [ ] Wait 5 seconds
- [ ] Navigate back
- [ ] **Expected**: Price updates resume immediately
- [ ] **Actual**: _____________________

### 4. Connection Status Test
- [ ] Check Debug Console for logs
- [ ] Look for pattern:
  - `"[MCX WebSocket] Disconnecting MCX WebSocket..."`
  - `"[MCX WebSocket] Reconnecting..."` ✅ (SHOULD APPEAR)
  - `"[MCX WebSocket] Connected"`
- [ ] **Expected**: Full reconnection sequence
- [ ] **Actual**: _____________________

### 5. Error Recovery Test
- [ ] Disable network connection
- [ ] Observe WebSocket disconnect
- [ ] Re-enable network connection
- [ ] **Expected**: WebSocket reconnects automatically
- [ ] **Actual**: _____________________

### 6. NFO Tab Navigation Test
- [ ] Switch to NFO Tab
- [ ] Navigate to symbol page
- [ ] Return to NFO Tab
- [ ] **Expected**: Data continues flowing
- [ ] **Actual**: _____________________

---

## 🔍 Log Verification

Check debug console for these messages:

### ✅ Expected Log Sequence
```
[MCX WebSocket] Page activated - reconnecting socket
[MCX WebSocket] Resetting disposed state for reconnection
[MCX WebSocket] Already connected or connecting. Skipping.
(OR)
[MCX WebSocket] Connected: [socket-id]
[MCX WebSocket] Emitted MCX Request: {...}
```

### ❌ Problem Indicators
```
[MCX WebSocket] Disconnecting MCX WebSocket...
(then nothing - means socket isn't reconnecting)

OR

Connection error messages without recovery
```

---

## 📋 Checklist Summary

| Test | Status | Notes |
|------|--------|-------|
| Basic Navigation | ☐ Pass ☐ Fail | |
| Multiple Navigation | ☐ Pass ☐ Fail | |
| Price Updates | ☐ Pass ☐ Fail | |
| Connection Logs | ☐ Pass ☐ Fail | |
| Error Recovery | ☐ Pass ☐ Fail | |
| NFO Tab | ☐ Pass ☐ Fail | |

---

## 🐛 Issue Report Template

If you encounter issues, document them here:

**Issue Title**: _______________________________________________

**Steps to Reproduce**:
1. _____________________
2. _____________________
3. _____________________

**Expected Behavior**: _____________________

**Actual Behavior**: _____________________

**Log Output**: 
```
[Paste relevant debug logs here]
```

**Device Info**:
- Device: _____________________
- OS Version: _____________________
- App Version: _____________________

---

## ✅ Sign-Off

- [ ] All tests passed
- [ ] No new issues introduced
- [ ] Ready for production

**Tester Signature**: ___________________  
**Date**: ___________________

---

**Reference**: WEBSOCKET_NAVIGATION_FIX.md
