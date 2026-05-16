@echo off
title HealthGuard Build & Deploy Manager
color 0A

:menu
cls
echo.
echo ========================================
echo   HealthGuard Build & Deploy Manager
echo ========================================
echo.
echo   Network: 192.168.34.9:5000
echo   Status: Ready for Multi-Device Deployment
echo.
echo   Choose an option:
echo.
echo   1. Build APK (Android Release)
echo   2. Build iOS (Mac required)
echo   3. Build Windows Release
echo   4. Build Web Version
echo   5. Run on Connected Device
echo   6. Clean Project
echo   7. Check Network Status
echo   8. Show Network Configuration
echo   9. Exit
echo.
set /p choice="Enter choice (1-9): "

if "%choice%"=="1" goto build_apk
if "%choice%"=="2" goto build_ios
if "%choice%"=="3" goto build_windows
if "%choice%"=="4" goto build_web
if "%choice%"=="5" goto run_device
if "%choice%"=="6" goto clean_project
if "%choice%"=="7" goto network_status
if "%choice%"=="8" goto show_config
if "%choice%"=="9" goto exit_script

echo Invalid choice. Please try again.
pause
goto menu

:build_apk
cls
echo.
echo Building Android APK...
echo.
flutter build apk --release
echo.
echo ✓ APK built successfully!
echo   Location: build\app\outputs\apk\release\app-release.apk
echo.
echo   Next steps:
echo   1. Transfer APK to Android device
echo   2. Install on device
echo   3. Open app - it will connect to 192.168.34.9:5000
echo.
pause
goto menu

:build_ios
cls
echo.
echo Building iOS App...
echo.
echo Note: iOS build requires macOS with Xcode
echo.
flutter build ios --release
echo.
echo ✓ iOS build complete!
echo   Location: build\ios\iphoneos\
echo.
echo   Next steps:
echo   1. Open ios/Runner.xcworkspace in Xcode
echo   2. Archive and upload to TestFlight
echo   3. Distribute to testers on same WiFi
echo.
pause
goto menu

:build_windows
cls
echo.
echo Building Windows Release...
echo.
flutter build windows --release
echo.
echo ✓ Windows build complete!
echo   Location: build\windows\runner\Release\
echo.
echo   Next steps:
echo   1. Distribute .exe to other Windows PCs
echo   2. PCs must be on 192.168.34.x network
echo   3. App will auto-connect to 192.168.34.9:5000
echo.
pause
goto menu

:build_web
cls
echo.
echo Building Web Version...
echo.
flutter build web --release
echo.
echo ✓ Web build complete!
echo   Location: build\web\
echo.
echo   To deploy:
echo   1. Use: python -m http.server 8000 --directory build\web
echo   2. Access from any device: http://192.168.34.9:8000
echo.
pause
goto menu

:run_device
cls
echo.
echo Preparing to run on connected device...
echo.
echo Connected devices:
flutter devices
echo.
flutter run
pause
goto menu

:clean_project
cls
echo.
echo Cleaning project...
echo.
flutter clean
flutter pub get
echo.
echo ✓ Project cleaned and dependencies updated!
echo.
pause
goto menu

:network_status
cls
echo.
echo ========== NETWORK STATUS ==========
echo.
echo Your IP Configuration:
ipconfig | findstr /C:"192.168.34.9" -C:"255.255.0.0" -C:"192.168.30.254"
echo.
echo Backend Port Status:
netstat -ano | findstr ":5000" | find "LISTENING" >nul && (
    echo ✓ Port 5000: LISTENING (Backend is running)
) || (
    echo ✗ Port 5000: NOT LISTENING (Start backend: npm run dev)
)
echo.
echo Available Network Range: 192.168.0.0/16
echo Gateway: 192.168.30.254
echo.
pause
goto menu

:show_config
cls
echo.
echo ========== CONFIGURATION ==========
echo.
echo API Configuration (.env):
echo   API_PROTOCOL = http
echo   API_HOST = 192.168.34.9
echo   API_PORT = 5000
echo   API_BASE_URL = http://192.168.34.9:5000/api
echo.
echo To change IP in future:
echo   1. Edit .env file
echo   2. Set API_HOST to new IP
echo   3. Run: flutter clean ^&^& flutter pub get
echo   4. Rebuild and deploy
echo.
echo Network Details:
echo   Your Machine: 192.168.34.9
echo   Subnet Mask: 255.255.0.0
echo   Network Range: 192.168.0.1 - 192.168.255.254
echo   Default Gateway: 192.168.30.254
echo.
pause
goto menu

:exit_script
cls
echo.
echo Goodbye!
echo.
echo For more info, see:
echo   - CONFIG_GUIDE.md
echo   - NETWORK_SETUP.md
echo   - DEPLOYMENT_GUIDE.md
echo.
timeout /t 3
exit /b

pause
