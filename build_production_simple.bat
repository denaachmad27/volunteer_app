@echo off
echo ========================================
echo Building Production APK
echo Environment: PRODUCTION
echo Server: http://103.150.197.76
echo ========================================
echo.

echo [1/4] Cleaning build cache...
call flutter clean
if %ERRORLEVEL% NEQ 0 (
    echo Error during flutter clean
    pause
    exit /b %ERRORLEVEL%
)
echo.

echo [2/4] Getting dependencies...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo Error during flutter pub get
    pause
    exit /b %ERRORLEVEL%
)
echo.

echo [3/4] Verifying environment files...
if not exist ".env.production" (
    echo ERROR: .env.production not found!
    echo Please create .env.production file first.
    pause
    exit /b 1
)
echo Found .env.production
type .env.production
echo.

echo [4/4] Building release APK...
call flutter build apk --release
if %ERRORLEVEL% NEQ 0 (
    echo Error during flutter build
    pause
    exit /b %ERRORLEVEL%
)
echo.

echo ========================================
echo Build Complete!
echo ========================================
echo.
echo APK Location:
echo build\app\outputs\flutter-apk\app-release.apk
echo.

pause
