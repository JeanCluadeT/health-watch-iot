@echo off
REM Network Connectivity Test Script for HealthGuard
REM Your IP: 192.168.34.9
REM Port: 5000

setlocal enabledelayedexpansion

echo.
echo ========================================
echo HealthGuard Network Test
echo ========================================
echo.

REM Test 1: Check if this machine can be reached
echo [TEST 1] Checking local network interface...
ipconfig /all | findstr /C:"192.168.34.9" >nul
if %errorlevel% equ 0 (
    echo ✓ Found IP: 192.168.34.9
) else (
    echo ✗ IP 192.168.34.9 not found locally
    echo   Run 'ipconfig' to find your actual IP
)

REM Test 2: Check if backend port is open
echo.
echo [TEST 2] Checking if backend is running on 192.168.34.9:5000...
netstat -ano | findstr ":5000" >nul
if %errorlevel% equ 0 (
    echo ✓ Port 5000 is OPEN
) else (
    echo ✗ Port 5000 is NOT open
    echo   Make sure Node.js backend is running: npm run dev
)

REM Test 3: Try to connect to backend
echo.
echo [TEST 3] Testing backend connectivity...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://192.168.34.9:5000/api' -UseBasicParsing -TimeoutSec 5; if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 404) { Write-Host '✓ Backend is ACCESSIBLE'; exit 0 } else { Write-Host '✗ Backend returned error'; exit 1 } } catch { Write-Host '✗ Cannot reach backend'; Write-Host '  Error: '$_.Exception.Message; exit 1 }"

REM Test 4: Test from loopback
echo.
echo [TEST 4] Testing localhost:5000...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:5000/api' -UseBasicParsing -TimeoutSec 5; Write-Host '✓ Localhost is reachable'; exit 0 } catch { Write-Host '✗ Localhost backend not running'; exit 1 }"

REM Test 5: Show network range
echo.
echo [TEST 5] Your Network Configuration:
echo   IP Address: 192.168.34.9
echo   Subnet Mask: 255.255.0.0
echo   Network Range: 192.168.0.1 - 192.168.255.254
echo   Gateway: 192.168.30.254
echo.
echo   Devices on your network should use: http://192.168.34.9:5000/api

REM Test 6: Check Flutter is ready
echo.
echo [TEST 6] Checking Flutter setup...
flutter doctor | findstr "Flutter\|Dart\|Connected device" 
echo.

REM Final Summary
echo ========================================
echo INSTRUCTIONS:
echo ========================================
echo.
echo 1. Make sure Node.js backend is running:
echo    npm run dev  (at port 5000)
echo.
echo 2. On other devices on your network, run:
echo    flutter run
echo.
echo 3. The app will use: http://192.168.34.9:5000/api
echo.
echo 4. If connection fails:
echo    - Check firewall allows port 5000
echo    - Verify both devices are on 192.168.x.x network
echo    - Restart WiFi on client device
echo.
echo ========================================
echo Test completed!
echo ========================================

pause
