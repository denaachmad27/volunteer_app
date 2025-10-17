# Panduan Fix Google Sign-In Error

## Masalah
Error: `PlatformException(sign_in_failed, com.google.android.gms.common.api.j: 10:, null, null)`

## Penyebab
File `google-services.json` tidak memiliki OAuth Client ID untuk Android (client_type 1). Hanya ada Web Client (client_type 3).

## Solusi

### Step 1: Tambahkan SHA-1 Fingerprint ke Firebase Console

1. Buka **Firebase Console**: https://console.firebase.google.com/
2. Pilih project: **loginwith-bad4d**
3. Masuk ke **Project Settings** (ikon gear di kiri atas)
4. Scroll ke bagian **Your apps** → pilih app Android **com.example.volunteer_app**
5. Klik **Add fingerprint**
6. Tambahkan SHA-1 fingerprint ini:
   ```
   60:4D:26:55:63:46:B1:83:BC:27:39:BD:19:27:96:27:A4:25:8F:49
   ```
7. (Opsional) Tambahkan juga SHA-256:
   ```
   1C:A8:46:9A:74:91:03:91:FE:32:F0:99:10:3F:CE:7D:80:A5:9C:33:51:76:5A:3E:60:27:50:20:DA:E0:DB:23
   ```

### Step 2: Download google-services.json Terbaru

1. Setelah menambahkan SHA-1, klik **Download google-services.json**
2. Replace file `android/app/google-services.json` dengan file yang baru didownload
3. File baru seharusnya memiliki `oauth_client` dengan `client_type: 1` (Android)

### Step 3: Verifikasi google-services.json

File baru harus memiliki struktur seperti ini:

```json
{
  "client": [
    {
      "oauth_client": [
        {
          "client_id": "xxx-xxx.apps.googleusercontent.com",
          "client_type": 1    // <- INI YANG PENTING! (Android)
        },
        {
          "client_id": "xxx-xxx.apps.googleusercontent.com",
          "client_type": 3    // Web
        }
      ]
    }
  ]
}
```

### Step 4: Rebuild Aplikasi

```bash
cd volunteer_app
flutter clean
flutter pub get
flutter build apk
```

### Step 5: Install dan Test

1. Uninstall aplikasi lama
2. Install APK baru
3. Test Google Sign-In

## Fingerprint Info

- **Debug Keystore Path**: `C:\Users\denaa\.android\debug.keystore`
- **Alias**: AndroidDebugKey
- **SHA-1**: `60:4D:26:55:63:46:B1:83:BC:27:39:BD:19:27:96:27:A4:25:8F:49`
- **SHA-256**: `1C:A8:46:9A:74:91:03:91:FE:32:F0:99:10:3F:CE:7D:80:A5:9C:33:51:76:5A:3E:60:27:50:20:DA:E0:DB:23`
- **Valid Until**: Saturday, May 15, 2055

## Catatan Penting

### Untuk Production/Release Build:
Jika nanti mau release production APK dengan signing key sendiri:
1. Generate SHA-1 dari release keystore
2. Tambahkan SHA-1 tersebut ke Firebase Console
3. Download google-services.json baru lagi

### Cara Generate SHA-1 dari Release Keystore:
```bash
keytool -list -v -keystore path/to/your-release-key.keystore -alias your-key-alias
```

## Troubleshooting

Jika masih error setelah mengikuti panduan:
1. Pastikan package name di `build.gradle.kts` sama dengan di Firebase: `com.example.volunteer_app`
2. Pastikan google-services.json sudah ter-replace dengan yang baru
3. Pastikan SHA-1 sudah terdaftar di Firebase Console
4. Clean & rebuild: `flutter clean && flutter pub get && flutter build apk`
5. Uninstall aplikasi lama sebelum install yang baru
