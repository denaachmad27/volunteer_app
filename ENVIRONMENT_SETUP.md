# Environment Configuration Setup

## Menggunakan flutter_dotenv untuk Manage Environment Variables

Sesuai dengan best practice Flutter, aplikasi ini menggunakan **flutter_dotenv** untuk manage environment-specific configuration seperti API URLs. Ini memudahkan switching antara development dan production environments.

---

## Struktur File

```
volunteer_app/
├── .env.production          # Production environment
├── .env.development         # Development environment
├── lib/
│   ├── main.dart           # Load dotenv saat startup
│   └── services/
│       └── api_service.dart # Baca environment variables
├── pubspec.yaml            # Declare dotenv package
├── build_production.bat    # Build script untuk Windows
└── build_production.sh     # Build script untuk Linux/Mac
```

---

## File Environment Variables

### `.env.production`
```env
# Production Environment Configuration
# Server IP: 103.150.197.76

API_BASE_URL=http://103.150.197.76/api
STORAGE_BASE_URL=http://103.150.197.76/storage
```

### `.env.development`
```env
# Development Environment Configuration
# Android Emulator menggunakan 10.0.2.2 untuk localhost

API_BASE_URL=http://10.0.2.2:8000/api
STORAGE_BASE_URL=http://10.0.2.2:8000/storage
```

---

## Cara Kerja

### 1. Load Environment pada Startup

File: `lib/main.dart`

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
    // Try to load production env first
    await dotenv.load(fileName: ".env.production");
    debugPrint('✅ Loaded .env.production');
  } catch (e) {
    // Fallback to development env
    try {
      await dotenv.load(fileName: ".env.development");
      debugPrint('✅ Loaded .env.development');
    } catch (e) {
      debugPrint('⚠️ No .env file found, using default values');
    }
  }

  runApp(VolunteerApp());
}
```

### 2. Baca Environment Variables

File: `lib/services/api_service.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String get baseUrl {
    // Priority 1: Dari .env file
    if (dotenv.env['API_BASE_URL'] != null) {
      return dotenv.env['API_BASE_URL']!;
    }
    // Priority 2: Dari dart-define (optional fallback)
    const buildTimeUrl = String.fromEnvironment('API_BASE_URL');
    if (buildTimeUrl.isNotEmpty) {
      return buildTimeUrl;
    }
    // Priority 3: Default development
    return 'http://10.0.2.2:8000/api';
  }

  static String get storageUrl {
    // Same pattern as baseUrl
    if (dotenv.env['STORAGE_BASE_URL'] != null) {
      return dotenv.env['STORAGE_BASE_URL']!;
    }
    const buildTimeUrl = String.fromEnvironment('STORAGE_BASE_URL');
    if (buildTimeUrl.isNotEmpty) {
      return buildTimeUrl;
    }
    return 'http://10.0.2.2:8000/storage';
  }
}
```

---

## Build Commands

### Production Build

**Windows:**
```bash
cd volunteer_app
build_production.bat
```

**Linux/Mac:**
```bash
cd volunteer_app
chmod +x build_production.sh
./build_production.sh
```

Build script akan:
1. Clean build cache
2. Get dependencies
3. Verify `.env.production` exists
4. Build APK release dengan production configuration
5. Show APK location dan size

### Development Build (Hot Reload)

```bash
flutter run
```

Akan otomatis load `.env.development` (fallback jika `.env.production` tidak ada).

### Manual Build Commands

**Production:**
```bash
flutter pub get
flutter build apk --release
```

**Development:**
```bash
flutter pub get
flutter run
```

---

## Keuntungan Menggunakan flutter_dotenv

### ✅ Best Practice
- Sesuai dengan dokumentasi Flutter
- Digunakan oleh banyak aplikasi production
- Mudah di-maintain

### ✅ Flexible
- Mudah switch environment (development/staging/production)
- Tidak perlu rebuild untuk ganti API URL
- Support multiple environments

### ✅ Secure
- Tidak hardcode credentials di source code
- `.env` files bisa di-gitignore untuk secrets
- Easy to rotate keys/URLs

### ✅ Clean Code
- Centralized configuration
- Single source of truth
- Easy to understand dan debug

---

## Troubleshooting

### Issue: "Unable to load asset .env.production"

**Penyebab:** File `.env.production` tidak ada atau tidak registered di `pubspec.yaml`

**Solusi:**
1. Pastikan file `.env.production` ada di root folder `volunteer_app/`
2. Check `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - .env.production
       - .env.development
   ```
3. Run `flutter pub get`
4. Clean dan rebuild: `flutter clean && flutter build apk --release`

### Issue: API masih connect ke localhost

**Penyebab:** App masih menggunakan old build atau .env tidak terload

**Solusi:**
1. Uninstall app lama: `adb uninstall com.example.volunteer_app`
2. Verify `.env.production` content:
   ```bash
   cat .env.production
   ```
3. Rebuild dengan script: `build_production.bat`
4. Install APK baru
5. Check logs saat startup untuk konfirmasi environment loaded:
   ```bash
   adb logcat | grep "Loaded .env"
   ```

### Issue: Blank screen atau app crash saat startup

**Penyebab:** Error saat load dotenv

**Solusi:**
1. Check logs:
   ```bash
   adb logcat | grep -i "flutter\|error"
   ```
2. Pastikan `WidgetsFlutterBinding.ensureInitialized()` dipanggil sebelum `dotenv.load()`
3. Verify .env file format (no trailing spaces, correct format)

### Issue: Environment variables null

**Penyebab:** dotenv tidak terload atau typo di key name

**Solusi:**
1. Check .env file format:
   ```env
   API_BASE_URL=http://103.150.197.76/api
   STORAGE_BASE_URL=http://103.150.197.76/storage
   ```
   - No spaces around `=`
   - No quotes (unless you want quotes in the value)
   - No trailing spaces
2. Check key name consistency:
   - .env file: `API_BASE_URL`
   - Code: `dotenv.env['API_BASE_URL']`

---

## Testing

### Test Environment Loading

Add debug prints di `main.dart`:

```dart
await dotenv.load(fileName: ".env.production");
debugPrint('✅ Loaded .env.production');
debugPrint('API_BASE_URL: ${dotenv.env['API_BASE_URL']}');
debugPrint('STORAGE_BASE_URL: ${dotenv.env['STORAGE_BASE_URL']}');
```

Run app dan check logs:
```bash
flutter run
# atau
adb logcat | grep "Loaded .env"
```

### Test API Connection

1. Build production APK
2. Install ke device
3. Open app
4. Try login
5. Monitor backend logs untuk confirm request dari IP yang benar

---

## Migration dari dart-define

Jika sebelumnya menggunakan `--dart-define`, sekarang tidak perlu lagi!

**Sebelum (old way):**
```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=http://103.150.197.76/api \
  --dart-define=STORAGE_BASE_URL=http://103.150.197.76/storage
```

**Sekarang (new way):**
```bash
# Just build, .env.production will be loaded automatically
flutter build apk --release
```

Lebih simple, lebih clean! 🎉

---

## Best Practices

### 1. Don't Commit Secrets
```gitignore
# .gitignore
.env.local
.env.*.local
.env.secrets
```

### 2. Use Different Files for Different Environments
```
.env.development    # Local development
.env.staging        # Staging server
.env.production     # Production server
```

### 3. Document All Environment Variables
Create `.env.example`:
```env
# API Configuration
API_BASE_URL=http://your-server.com/api
STORAGE_BASE_URL=http://your-server.com/storage

# Optional
API_KEY=your_api_key_here
```

### 4. Validate Environment Variables
```dart
static String get baseUrl {
  final url = dotenv.env['API_BASE_URL'];
  if (url == null || url.isEmpty) {
    throw Exception('API_BASE_URL not configured in .env file');
  }
  return url;
}
```

---

## Summary

✅ **Implemented:** flutter_dotenv untuk environment management
✅ **Files:** `.env.production` dan `.env.development`
✅ **Updated:** `main.dart`, `api_service.dart`, `pubspec.yaml`
✅ **Build Scripts:** Updated untuk auto-detect environment

**Next Steps:**
1. Run `flutter pub get` untuk install flutter_dotenv
2. Run `build_production.bat` untuk build production APK
3. Install APK dan test login ke server produksi

**Production Server:**
- API: http://103.150.197.76/api
- Storage: http://103.150.197.76/storage
