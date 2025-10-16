#!/bin/bash

# ========================================
# Build Script untuk Production APK
# Volunteer Management App
# ========================================
# Menggunakan flutter_dotenv untuk load .env.production
# Server: https://volunteer-bansos.duckdns.org
# ========================================

echo "========================================"
echo "Building Production APK"
echo "Environment: PRODUCTION"
echo "Server: https://volunteer-bansos.duckdns.org"
echo "========================================"
echo ""

# Clean build cache
echo "[1/4] Cleaning build cache..."
flutter clean
echo ""

# Get dependencies
echo "[2/4] Getting dependencies..."
flutter pub get
echo ""

# Verify .env.production exists
echo "[3/4] Verifying environment files..."
if [ ! -f ".env.production" ]; then
    echo "ERROR: .env.production not found!"
    echo "Please create .env.production file first."
    exit 1
fi
echo "✓ Found .env.production"
cat .env.production
echo ""

# Build release APK
echo "[4/4] Building release APK..."
echo "Using .env.production configuration"
flutter build apk --release
echo ""

# Show build info
echo "========================================"
echo "Build Complete!"
echo "========================================"
echo ""
echo "APK Location:"
echo "build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "APK Size:"
ls -lh build/app/outputs/flutter-apk/app-release.apk | awk '{print $5}'
echo ""
echo "Install Commands:"
echo "  Via ADB:  adb install build/app/outputs/flutter-apk/app-release.apk"
echo "  Via USB:  Copy APK to phone and install manually"
echo ""
echo "========================================"
echo "Environment Configuration:"
echo "  API_BASE_URL: https://volunteer-bansos.duckdns.org/api"
echo "  STORAGE_BASE_URL: https://volunteer-bansos.duckdns.org/storage"
echo "========================================"
echo ""
