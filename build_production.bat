@echo off
REM ========================================
REM Build Script untuk Production APK
REM Volunteer Management App
REM ========================================
REM Menggunakan flutter_dotenv untuk load .env.production
REM Server: http://103.150.197.76
REM ========================================

echo ========================================
echo Building Production APK
echo Environment: PRODUCTION
echo Server: http://103.150.197.76
echo ========================================
echo.

REM Clean build cache
echo [1/4] Cleaning build cache...
flutter clean
echo.

REM Get dependencies
echo [2/4] Getting dependencies...
flutter pub get
echo.

REM Verify .env.production exists
echo [3/4] Verifying environment files...
if not exist ".env.production" (
    echo ERROR: .env.production not found!
    echo Please create .env.production file first.
    pause
    exit /b 1
)
echo ✓ Found .env.production
type .env.production
echo.

REM Build release APK
echo [4/4] Building release APK...
echo Using .env.production configuration
flutter build apk --release
echo.

REM Show build info
echo ========================================
echo Build Complete!
echo ========================================
echo.
echo APK Location:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo APK Size:
for %%A in ("build\app\outputs\flutter-apk\app-release.apk") do echo %%~zA bytes
echo.
echo Install Commands:
echo   Via ADB:  adb install build\app\outputs\flutter-apk\app-release.apk
echo   Via USB:  Copy APK to phone and install manually
echo.
echo ========================================
echo Environment Configuration:
echo   API_BASE_URL: http://103.150.197.76/api
echo   STORAGE_BASE_URL: http://103.150.197.76/storage
echo ========================================
echo.

pause
