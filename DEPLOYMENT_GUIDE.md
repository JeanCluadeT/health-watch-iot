# 🚀 HealthGuard Multi-Device Deployment Guide

## ✅ Your Setup Status

**Configured for:** 192.168.34.9 (Your WiFi IP)

```
Network Configuration:
├─ Your IP: 192.168.34.9
├─ Network Range: 192.168.0.0/16 
├─ Subnet: 255.255.0.0
├─ Gateway: 192.168.30.254
└─ Backend Port: 5000 (LISTENING)
```

---

## 📱 Deploy to Any Device on Your Network

### **Option 1: Android Phone/Tablet**

#### Using Android Debug Bridge (ADB):
```bash
# 1. Connect Android device via USB
# 2. Enable USB Debugging on device
# 3. Build app for Android:
flutter build apk --release

# 4. Install on device:
adb install build/app/outputs/apk/release/app-release.apk

# 5. Run on device:
adb shell am start -n com.healthguard/com.healthguard.MainActivity
```

#### Using APK Transfer:
```bash
# 1. Build APK:
flutter build apk --release

# 2. Find file: build/app/outputs/apk/release/app-release.apk

# 3. Transfer to Android device via:
#    - Email
#    - Cloud storage (Google Drive, Dropbox)
#    - Direct file transfer
#    - USB cable

# 4. On Android: Open file manager, tap APK, install
```

#### Using Flutter Run (WiFi):
```bash
# 1. Connect Android on same WiFi (192.168.x.x)
# 2. Get device IP: adb shell ip addr show
# 3. Connect wirelessly:
adb connect <DEVICE_IP>:5555

# 4. Run:
flutter run
```

---

### **Option 2: iPhone/iPad**

#### Using TestFlight:
```bash
# 1. Build iOS:
flutter build ios --release

# 2. Archive in Xcode:
open ios/Runner.xcworkspace

# 3. Product → Archive → Build Version → Upload TestFlight

# 4. Invite testers via TestFlight
# 5. Testers install from App Store TestFlight (same WiFi)
```

#### Using Physical Inspector:
```bash
# 1. Build for device:
flutter build ios --release

# 2. Connect via Xcode with provisioning profile

# 3. Build and run:
flutter run
```

---

### **Option 3: Windows PC on Same Network**

```bash
# 1. Clone project on other Windows PC on 192.168.x.x network
git clone <your-repo>

# 2. Update .env (same as yours):
API_HOST=192.168.34.9
API_PORT=5000

# 3. Get dependencies:
flutter pub get

# 4. Run:
flutter run -d windows
```

---

### **Option 4: Web Browser (Over Network)**

To access app from web browser on same network:

```bash
# 1. Build web version:
flutter build web

# 2. Serve on network:
python -m http.server 8000 --directory build/web
# Or using Node.js:
npx http-server build/web

# 3. On other device browser, visit:
http://192.168.34.9:8000
```

---

## 🔧 Configuration Details

### Current .env Setup:
```env
API_PROTOCOL=http
API_HOST=192.168.34.9
API_PORT=5000
API_BASE_URL=http://192.168.34.9:5000/api
```

### If Backend Moves to Different IP:
1. Edit `.env`:
```bash
nano .env
# Change: API_HOST=<NEW_IP>
```

2. Rebuild:
```bash
flutter clean
flutter pub get
flutter run
```

---

## 🛠️ Backend Configuration for Network Access

Your Node.js backend MUST listen on all interfaces:

### Check Your Server Code (server.js or main backend file):
```javascript
// ✓ CORRECT - Listens on all interfaces
app.listen(5000, '0.0.0.0', () => {
  console.log('Server running on http://0.0.0.0:5000');
});

// ✓ ALSO CORRECT
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

// ✗ WRONG - Only localhost
app.listen(5000, 'localhost', () => {
  console.log('Server running on localhost only');
});
```

### Enable CORS for Network Access:
```javascript
const cors = require('cors');

app.use(cors({
  origin: function(origin, callback) {
    // Allow all origins for development
    callback(null, true);
  },
  credentials: true
}));
```

---

## 📊 Network Testing Commands

### Test from Your PC:
```bash
# Test if backend is accessible:
curl http://192.168.34.9:5000/api
```

### Test from Another Device:
```bash
# Android/iOS shell:
curl http://192.168.34.9:5000/api

# Or PowerShell on Windows:
Invoke-WebRequest -Uri "http://192.168.34.9:5000/api"
```

### Check Active Connections:
```bash
# On your PC:
netstat -ano | findstr ":5000"

# Shows:
# TCP  0.0.0.0:5000     0.0.0.0:0     LISTENING    [PID]
# ✓ Means it's accessible from network
```

---

## 🚨 Troubleshooting

### Issue: "Connection refused" on client device
**Solution:**
```bash
# 1. Verify backend is running on your PC:
netstat -ano | findstr ":5000"

# 2. Check firewall allows port 5000:
# Settings → Firewall → Allow app through firewall
# Add: Node.js or your backend .exe

# 3. Restart backend:
npm run dev
```

### Issue: "Network unreachable"
**Solution:**
```bash
# 1. Verify same WiFi:
- Your PC: ipconfig | find "192.168"
- Client: Open WiFi settings → Check SSID is same

# 2. Ping test:
ping 192.168.34.9  # Should get responses

# 3. Check subnet:
- Both should have 255.255.0.0 subnet
```

### Issue: Timeout or Slow Connection
**Solution:**
```bash
# 1. Check WiFi signal:
netsh wlan show interfaces

# 2. Restart router/WiFi:
- Unplug router for 30 seconds
- Plug back in

# 3. Change WiFi channel (if many nearby):
- Router admin panel
- Change from Auto to fixed channel (1, 6, or 11)
```

---

## 📋 Deployment Checklist

- [ ] Backend running on 192.168.34.9:5000
- [ ] Port 5000 open in firewall
- [ ] .env configured with correct IP
- [ ] CORS enabled in backend
- [ ] Both devices on same WiFi
- [ ] Flutter app built/ready to deploy
- [ ] Other device can ping 192.168.34.9
- [ ] Test device on 192.168.x.x network

---

## 📞 Quick Commands Reference

```bash
# Check your IP:
ipconfig

# Verify backend running:
netstat -ano | findstr ":5000"

# Build for Android:
flutter build apk --release

# Build for iOS:
flutter build ios --release

# Build for Windows:
flutter build windows --release

# Build for Web:
flutter build web

# Run on connected device:
flutter run

# Clean and rebuild:
flutter clean && flutter pub get && flutter run
```

---

## ✨ Next Steps

1. **Verify Backend:** `curl http://192.168.34.9:5000/api`
2. **Test on Another Device:** Have a friend try to access your IP
3. **Build for Target Platform:**
   - Android: `flutter build apk --release`
   - iOS: `flutter build ios --release`
4. **Deploy APK/IPA to test devices**
5. **Monitor logs on each device for errors**

---

**Setup Date:** February 26, 2026  
**Your IP:** 192.168.34.9  
**Status:** ✅ Ready for Multi-Device Network Deployment
