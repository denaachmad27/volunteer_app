# Build Instructions - Production APK

## Masalah: build_production.bat Force Close

Jika `build_production.bat` langsung force close, gunakan cara manual di bawah ini:

---

## Cara 1: Build Manual Step-by-Step (RECOMMENDED)

Buka **Command Prompt** atau **PowerShell** di folder `volunteer_app`:

### Step 1: Clean Build Cache
```cmd
flutter clean
```

### Step 2: Get Dependencies
```cmd
flutter pub get
```

### Step 3: Verify .env.production
```cmd
type .env.production
```

Output yang benar:
```
# Production Environment Configuration
# Server IP: 103.150.197.76

API_BASE_URL=http://103.150.197.76/api
STORAGE_BASE_URL=http://103.150.197.76/storage
```

### Step 4: Build APK Release
```cmd
flutter build apk --release
```

Proses build akan memakan waktu **3-5 menit**. Tunggu sampai selesai.

### Step 5: Check APK Location
```cmd
dir build\app\outputs\flutter-apk\app-release.apk
```

---

## Cara 2: Build dengan Script Simple

Gunakan script yang lebih simple:

```cmd
build_production_simple.bat
```

Script ini menggunakan `call` command yang lebih kompatibel dengan Windows.

---

## Cara 3: Build via VSCode

1. Buka folder `volunteer_app` di VSCode
2. Open Terminal (Ctrl + `)
3. Run commands manual (sama seperti Cara 1)

---

## Troubleshooting

### Issue: "flutter is not recognized"

**Solusi:**
```cmd
set PATH=%PATH%;C:\flutter\bin
flutter doctor
```

### Issue: Build gagal dengan error Gradle

**Solusi:**
```cmd
cd android
gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

### Issue: Out of memory saat build

**Solusi:**

Edit file `android/gradle.properties` dan tambahkan:
```properties
org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m
```

Lalu build ulang:
```cmd
flutter clean
flutter build apk --release
```

### Issue: .env.production not found

**Solusi:**

Pastikan file `.env.production` ada di root folder `volunteer_app/`:

```cmd
cd c:\Projects\volunteer\volunteer_app
type .env.production
```

Jika tidak ada, buat file dengan content:
```env
# Production Environment Configuration
# Server IP: 103.150.197.76

API_BASE_URL=http://103.150.197.76/api
STORAGE_BASE_URL=http://103.150.197.76/storage
```

---

## Expected Build Output

Saat build berhasil, Anda akan melihat:
```
✓ Built build\app\outputs\flutter-apk\app-release.apk (XX.X MB)
```

APK location:
```
c:\Projects\volunteer\volunteer_app\build\app\outputs\flutter-apk\app-release.apk
```

---

## Install APK ke Device

### Via ADB (USB Debugging):
```cmd
adb devices
adb uninstall com.example.volunteer_app
adb install build\app\outputs\flutter-apk\app-release.apk
```

### Via File Transfer:
1. Copy file `build\app\outputs\flutter-apk\app-release.apk`
2. Transfer ke phone via USB/Email/Drive
3. Install manual dari phone (allow unknown sources)

---

## Verify APK Configuration

Setelah install, buka app dan check logs:

```cmd
adb logcat | findstr "Loaded .env"
```

Output yang benar:
```
✅ Loaded .env.production
API_BASE_URL: http://103.150.197.76/api
STORAGE_BASE_URL: http://103.150.197.76/storage
```

Jika masih muncul `10.0.2.2`, berarti APK belum ter-build dengan benar.

---

## Alternative: Build via Android Studio

1. Buka folder `volunteer_app/android` di Android Studio
2. Wait for Gradle sync
3. Build > Build Bundle(s) / APK(s) > Build APK(s)
4. APK akan ada di `build/app/outputs/flutter-apk/`

---

## Quick Commands (Copy-Paste)

Buka Command Prompt di `c:\Projects\volunteer\volunteer_app` dan paste:

```cmd
flutter clean && flutter pub get && flutter build apk --release
```

One-liner untuk build langsung! ✨

Tunggu 3-5 menit sampai selesai.

---

## Kesimpulan

**Jika batch file force close:**
1. ✅ Gunakan command manual (paling aman)
2. ✅ Atau gunakan `build_production_simple.bat`
3. ✅ Atau gunakan one-liner command

**Build time:** 3-5 menit (tergantung spek PC)

**APK size:** ~20-30 MB

**Output:** `build\app\outputs\flutter-apk\app-release.apk`
