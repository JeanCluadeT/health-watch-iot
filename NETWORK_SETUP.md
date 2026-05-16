# 🌐 Network Setup Checklist - Your Configuration

## Your Network Details ✓
- **Your Machine IP**: 192.168.34.9
- **Subnet Mask**: 255.255.0.0
- **Default Gateway**: 192.168.30.254
- **Usable Network Range**: 192.168.0.1 - 192.168.255.254

## ✅ Pre-Deployment Checklist

### Step 1: Ensure Backend Server is Running
```bash
# On your machine (192.168.34.9), start the Node.js backend:
npm run dev
# or
npm start
```
Backend should be accessible at: `http://192.168.34.9:5000`

### Step 2: Verify Connectivity on Your Machine
```bash
# Test if backend is responding (run on your machine):
curl http://192.168.34.9:5000/api
# or in PowerShell:
Invoke-WebRequest -Uri "http://192.168.34.9:5000/api"
```

### Step 3: Test from Another Device on Same Network
```bash
# On any other device on your WiFi (192.168.34.x):
ping 192.168.34.9
# Should response: pings should succeed

# Test backend access:
curl http://192.168.34.9:5000/api
# Should return: API response (not timeout)
```

## 🚀 Deploy to Other Devices

### For Android Device/Emulator on Same WiFi:
1. Build APK:
   ```bash
   flutter build apk
   ```
2. Transfer APK to device or install via USB
3. App will automatically connect to `http://192.168.34.9:5000/api`

### For iOS Device on Same WiFi:
1. Build iOS:
   ```bash
   flutter build ios
   ```
2. Install via TestFlight or physical build
3. App will connect to `http://192.168.34.9:5000/api`

### For Windows Machine on Same Network:
1. Clone project on other machine
2. Update `.env` with `API_HOST=192.168.34.9`
3. Run:
   ```bash
   flutter run -d windows
   ```

## 🔍 Troubleshooting Connection Issues

### Issue: "Connection refused" or "Network error"
```bash
# 1. Check if backend is running:
curl http://192.168.34.9:5000

# 2. Check firewall allows port 5000:
# Windows Defender Firewall > Advanced Settings > Inbound Rules
# Create rule: Allow TCP 5000

# 3. Check devices are on same network:
ipconfig  # Verify IPv4 starts with 192.168
```

### Issue: Device can't find 192.168.34.9
```bash
# 1. Ping the IP to verify it's reachable:
ping 192.168.34.9

# 2. Restart WiFi:
# Disconnect and reconnect to WiFi

# 3. Check if multiple networks are active:
ipconfig  # Should see 192.168.34.9 in WiFi adapter section
```

### Issue: Timeout or Slow Connection
```bash
# 1. Check network speed:
speedtest-cli

# 2. Check if port 5000 is open:
# On your machine: netstat -ano | findstr :5000

# 3. Restart backend server:
# Stop: Ctrl+C
# Start: npm run dev
```

## 📋 Current Configuration

**File**: `.env`
```
API_PROTOCOL=http
API_HOST=192.168.34.9
API_PORT=5000
API_BASE_URL=http://192.168.34.9:5000/api
```

## 🔄 To Change Configuration Later

If your machine IP changes or you need to test on a different host:
1. Edit `.env` file
2. Change `API_HOST` to new IP
3. Run: `flutter clean && flutter pub get`
4. Rebuild and deploy

## 📱 Device-Specific Instructions

### Android Device (Real):
- Must be on same WiFi: 192.168.x.x network ✓
- App will auto-connect to your backend ✓

### iPhone/iPad (Real):
- Must be on same WiFi: 192.168.x.x network ✓
- App will auto-connect to your backend ✓

### Android Emulator (on Windows/Mac):
- Android emulator has special IP: `10.0.2.2`
- Change `.env`: `API_HOST=10.0.2.2`
- This alias routes to your host machine's localhost

### Web (Browser):
- Requires CORS headers in backend
- Add to Node.js:
```javascript
app.use(cors({
  origin: 'http://192.168.34.9:5000'
}));
```

## ✨ Quick Commands

```bash
# Build for Android
flutter build apk --release

# Build for iOS  
flutter build ios --release

# Run on connected device
flutter run

# Run with verbose logging
flutter run -v

# Check connected devices
flutter devices

# Test backend connectivity
curl http://192.168.34.9:5000/api
```

## 📞 Support

If connection fails:
1. ✓ Check backend is running on 192.168.34.9:5000
2. ✓ Verify firewall allows port 5000
3. ✓ Ping 192.168.34.9 from test device
4. ✓ Check `.env` has correct IP_HOST
5. ✓ Restart app after .env changes

---

**Setup Date**: Feb 26, 2026  
**Network**: 192.168.34.9 /16 (Class B)  
**Status**: ✅ Ready for Multi-Device Deployment
