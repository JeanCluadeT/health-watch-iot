# HealthGuard Network Configuration Guide

## 📱 Running on Different Network Devices

Your HealthGuard app now supports running on any device on the same network by configuring the backend server IP address through the `.env` file.

---

## 🔧 Configuration Setup

### Step 1: Find Your Backend Server IP Address

Before running the app, you need to know your backend server's IP address on the network.

**On Windows (cmd or PowerShell):**
```powershell
ipconfig
```
Look for your IPv4 address (e.g., `192.168.x.x` or `10.0.x.x`)

**On Mac/Linux (terminal):**
```bash
ifconfig
```
Look for `inet` address

### Step 2: Update the .env File

Open the `.env` file in the project root and modify the `API_HOST` value:

```
API_PROTOCOL=http
API_HOST=192.168.1.100    # ← Change this to your server's IP
API_PORT=5000
```

### Step 3: Rebuild and Run

```bash
flutter clean
flutter pub get
flutter run
```

---

## 📍 Common Configuration Examples

### Local Development (Same Machine)
```env
API_PROTOCOL=http
API_HOST=localhost
API_PORT=5000
```

### Android Emulator (Connecting to Host Machine)
```env
API_PROTOCOL=http
API_HOST=10.0.2.2
API_PORT=5000
```
*Note: 10.0.2.2 is a special Android emulator alias for the host machine*

### Real Device on Home Network
```env
API_PROTOCOL=http
API_HOST=192.168.1.100
API_PORT=5000
```
*Replace 192.168.1.100 with your actual server IP*

### Real Device on Corporate/Public Network
```env
API_PROTOCOL=http
API_HOST=10.0.50.25
API_PORT=5000
```
*Replace with your corporate network IP*

### Using HTTPS (Production)
```env
API_PROTOCOL=https
API_HOST=yourserver.com
API_PORT=443
```

---

## 🔐 Security Notes

- ✅ The `.env` file is already in `.gitignore` (not committed to git)
- ✅ Use `https` protocol in production
- ✅ Keep your `.env` file private and don't share it
- ✅ Use `.env.example` as a template for other developers

---

## 🚀 How It Works

1. When the app starts, `main.dart` loads the `.env` file
2. The API service reads values from environment variables:
   - `API_PROTOCOL`: http or https
   - `API_HOST`: Server IP or hostname
   - `API_PORT`: Server port number
3. All API calls use the configured URL dynamically

---

## ✅ Verification

To verify your configuration is working:

1. **Check API Service Logs:**
   The app prints the API base URL when making requests. Look for messages like:
   ```
   Attempting to register patient to: http://192.168.1.100:5000/api/auth/register/patient
   ```

2. **Test Network Connectivity:**
   Make sure your device can ping the server:
   ```bash
   ping 192.168.1.100
   ```

3. **Check Backend Server:**
   Ensure your Node.js backend is running and accessible on the configured IP/port

---

## 🆘 Troubleshooting

### Issue: "Connection refused" or "Network error"
- ✓ Verify the IP address is correct: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
- ✓ Check backend server is running: `npm run dev` or `npm start`
- ✓ Verify both devices are on same network (WiFi)
- ✓ Check firewall isn't blocking port 5000

### Issue: "Empty result set" or "No data"
- ✓ Make sure backend API is running
- ✓ Check database connections
- ✓ Verify API routes are implemented

### Issue: "Invalid certificate" (HTTPS errors)
- ✓ In development, use `http` instead of `https`
- ✓ In production, ensure valid SSL certificate

---

## 📝 Environment Variables Reference

| Variable | Default | Description |
|----------|---------|-------------|
| `API_PROTOCOL` | `http` | Protocol (http or https) |
| `API_HOST` | `localhost` | Server IP or hostname |
| `API_PORT` | `5000` | Server port number |
| `API_BASE_URL` | (constructed) | Full API URL (for reference) |

---

## 🔄 Quick Reference

**For each new device setup, just modify `.env`:**

```env
API_HOST=<your-server-ip>
```

That's it! No need to rebuild the code, just restart the app.

---

Need help? Check:
- [ ] Server IP address is correct
- [ ] Both devices on same network
- [ ] Backend server is running
- [ ] Port 5000 is accessible
- [ ] Firewall allows the connection
