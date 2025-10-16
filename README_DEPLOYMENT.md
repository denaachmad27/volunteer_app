# 📱 Flutter App - Deployment Guide

Panduan untuk build dan deploy aplikasi Flutter Volunteer Management ke production.

---

## 🌐 **Server Configuration**

**Production Server:**
- **IP**: http://103.150.197.76
- **API**: http://103.150.197.76/api
- **Storage**: http://103.150.197.76/storage

---

## 🔧 **Environment Configuration**

Aplikasi menggunakan `--dart-define` untuk konfigurasi environment:

### **Development (Local):**
- `API_BASE_URL`: `http://10.0.2.2:8000/api` (Android Emulator)
- `STORAGE_BASE_URL`: `http://10.0.2.2:8000/storage`

### **Production:**
- `API_BASE_URL`: `http://103.150.197.76/api`
- `STORAGE_BASE_URL`: `http://103.150.197.76/storage`

---

## 🚀 **Build Production APK**

### **Opsi 1: Menggunakan Build Script (Recommended)**

#### Windows:
```cmd
build_production.bat
```

#### Mac/Linux:
```bash
chmod +x build_production.sh
./build_production.sh
```

### **Opsi 2: Manual Command**

```bash
# Clean previous build
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release \
  --dart-define=API_BASE_URL=http://103.150.197.76/api \
  --dart-define=STORAGE_BASE_URL=http://103.150.197.76/storage
```

---

## 📦 **Build Output**

APK file akan tersimpan di:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📲 **Install APK ke Device**

### **Via ADB (Android Debug Bridge):**

```bash
# Install ke device yang terhubung
adb install build/app/outputs/flutter-apk/app-release.apk

# Install dengan replace app lama
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### **Via File Transfer:**
1. Copy file `app-release.apk` ke Android device
2. Buka file di device
3. Install (allow "Install from Unknown Sources" jika diminta)

---

## 🧪 **Testing**

### **Test di Development (Emulator):**
```bash
flutter run
```

### **Test di Development dengan Production Server:**
```bash
flutter run \
  --dart-define=API_BASE_URL=http://103.150.197.76/api \
  --dart-define=STORAGE_BASE_URL=http://103.150.197.76/storage
```

---

## 🔐 **Login Credentials (Testing)**

**Admin:**
- Email: `admin@volunteer.com`
- Password: `password123`

**Super Administrator:**
- Email: `superadmin@volunteer.com`
- Password: `SuperAdmin123!`

---

## ⚙️ **Build Variants**

### **Debug APK (Faster build, larger size):**
```bash
flutter build apk --debug \
  --dart-define=API_BASE_URL=http://103.150.197.76/api \
  --dart-define=STORAGE_BASE_URL=http://103.150.197.76/storage
```

### **Profile APK (Performance profiling):**
```bash
flutter build apk --profile \
  --dart-define=API_BASE_URL=http://103.150.197.76/api \
  --dart-define=STORAGE_BASE_URL=http://103.150.197.76/storage
```

### **Release APK (Production, optimized):**
```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=http://103.150.197.76/api \
  --dart-define=STORAGE_BASE_URL=http://103.150.197.76/storage
```

---

## 📱 **App Bundle (untuk Google Play Store)**

Jika ingin publish ke Google Play Store, build App Bundle:

```bash
flutter build appbundle --release \
  --dart-define=API_BASE_URL=http://103.150.197.76/api \
  --dart-define=STORAGE_BASE_URL=http://103.150.197.76/storage
```

Output: `build/app/outputs/bundle/release/app-release.aab`

---

## 🔍 **Troubleshooting**

### **1. Build gagal - Dependencies error**
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### **2. Build gagal - SDK version**
Pastikan Flutter SDK up-to-date:
```bash
flutter upgrade
flutter doctor
```

### **3. App tidak connect ke server**

**Cek:**
- Server running: `curl http://103.150.197.76/api`
- Internet connection di device
- Firewall tidak block port 80

**Debug:**
```bash
# Enable network logging di api_service.dart
const bool kEnableNetworkLogging = true;  # line 52, 99, 134, 169, 199
```

### **4. CORS Error**

Update di server `.env`:
```env
CORS_ALLOWED_ORIGINS=*
```

Restart server:
```bash
sudo systemctl restart php8.3-fpm nginx
```

---

## 📊 **Build Size Optimization**

### **Split APK by ABI (Reduce size):**
```bash
flutter build apk --split-per-abi --release \
  --dart-define=API_BASE_URL=http://103.150.197.76/api \
  --dart-define=STORAGE_BASE_URL=http://103.150.197.76/storage
```

Output:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM - most modern devices)
- `app-x86_64-release.apk` (x86 64-bit)

---

## 🔄 **Update Server URL**

Jika server berubah, edit dan rebuild:

### **Update .env.production:**
```
API_BASE_URL=http://NEW_SERVER_IP/api
STORAGE_BASE_URL=http://NEW_SERVER_IP/storage
```

### **Rebuild:**
```bash
./build_production.bat  # atau build_production.sh
```

---

## 📝 **Checklist Deployment**

- [ ] Server production running (http://103.150.197.76)
- [ ] API accessible (test: `curl http://103.150.197.76/api`)
- [ ] Environment variables configured
- [ ] Dependencies updated (`flutter pub get`)
- [ ] Build script executed successfully
- [ ] APK generated (`app-release.apk` exists)
- [ ] APK installed to test device
- [ ] Login tested
- [ ] All features tested
- [ ] APK distributed to users

---

## 📞 **Support**

Jika ada masalah:
1. Cek `flutter doctor` untuk Flutter environment
2. Cek server status: `curl http://103.150.197.76/api`
3. Enable network logging di `api_service.dart`
4. Cek logcat: `adb logcat | grep -i flutter`

---

**Happy deploying! 🚀**
