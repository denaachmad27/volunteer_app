# Verification Guide - Memastikan APK Pointing ke Production

## ✅ Build Berhasil!

APK Location:
```
c:\Projects\volunteer\volunteer_app\build\app\outputs\flutter-apk\app-release.apk
```

APK Size: **52-53 MB**

---

## 📋 Cara Memastikan APK Sudah Pointing ke Server Produksi

### Method 1: Check Logs Saat App Startup (RECOMMENDED)

#### Step 1: Install APK
```cmd
adb devices
adb uninstall com.example.volunteer_app
adb install build\app\outputs\flutter-apk\app-release.apk
```

#### Step 2: Monitor Logs
Buka terminal baru dan jalankan:
```cmd
adb logcat -c
adb logcat | findstr "Loaded .env"
```

#### Step 3: Buka App di Phone
Launch app dari device.

#### Step 4: Check Output
Output yang **BENAR** (Production):
```
✅ Loaded .env.production
API_BASE_URL: http://103.150.197.76/api
STORAGE_BASE_URL: http://103.150.197.76/storage
```

Output yang **SALAH** (Development):
```
✅ Loaded .env.development
API_BASE_URL: http://10.0.2.2:8000/api
```

**Jika muncul .env.production = SUCCESS!** 🎉

---

### Method 2: Test Login Langsung

#### Step 1: Install APK
```cmd
adb install build\app\outputs\flutter-apk\app-release.apk
```

#### Step 2: Buka App dan Coba Login

**Pastikan:**
- Device terhubung ke internet (WiFi/Data)
- Server produksi (103.150.197.76) sudah running
- Backend sudah dikonfigurasi dengan benar

#### Step 3: Monitor Request di Server

SSH ke server dan monitor logs:
```bash
ssh root@103.150.197.76
tail -f /var/www/volunteer/volunteer-management-backend/storage/logs/laravel.log
```

Atau check nginx access logs:
```bash
tail -f /var/log/nginx/access.log | grep volunteer
```

**Jika muncul request dari IP device = SUCCESS!** 🎉

---

### Method 3: Check dengan Network Inspector

#### Step 1: Enable Developer Options di Android
1. Settings > About Phone
2. Tap "Build Number" 7 kali
3. Developer Options akan muncul

#### Step 2: Enable USB Debugging
1. Settings > Developer Options
2. Enable "USB Debugging"

#### Step 3: Connect ke Chrome DevTools
1. Buka Chrome di PC
2. Go to: `chrome://inspect/#devices`
3. Connect phone via USB
4. Launch app
5. Click "Inspect" pada app

#### Step 4: Check Network Tab
1. Open Network tab
2. Try login
3. Check request URL

**URL yang BENAR:**
```
http://103.150.197.76/api/auth/login
```

**URL yang SALAH:**
```
http://10.0.2.2:8000/api/auth/login
```

---

## 🔧 Troubleshooting

### Issue: Logs menunjukkan "Loaded .env.development"

**Penyebab:**
- `.env.production` tidak ter-include dalam build
- `main.dart` fallback ke development

**Solusi:**
1. Verify `.env.production` exists:
   ```cmd
   type .env.production
   ```

2. Check `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - .env.production
       - .env.development
   ```

3. Rebuild:
   ```cmd
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

4. Reinstall:
   ```cmd
   adb uninstall com.example.volunteer_app
   adb install build\app\outputs\flutter-apk\app-release.apk
   ```

---

### Issue: App crash saat startup

**Penyebab:**
- Error saat load dotenv
- .env file format salah

**Solusi:**
1. Check logs:
   ```cmd
   adb logcat | findstr "flutter"
   ```

2. Verify .env format (no trailing spaces, correct syntax):
   ```env
   API_BASE_URL=http://103.150.197.76/api
   STORAGE_BASE_URL=http://103.150.197.76/storage
   ```

3. Rebuild dengan clean:
   ```cmd
   flutter clean
   flutter build apk --release
   ```

---

### Issue: Login berhasil tapi tidak ada data

**Penyebab:**
- Server produksi belum dikonfigurasi
- Database kosong
- CORS issue

**Solusi:**

1. **Check backend .env di server:**
   ```bash
   ssh root@103.150.197.76
   cd /var/www/volunteer/volunteer-management-backend
   cat .env
   ```

   Pastikan:
   ```env
   APP_URL=http://103.150.197.76
   CORS_ALLOWED_ORIGINS=*
   DB_DATABASE=volunteer_management
   ```

2. **Check database:**
   ```bash
   php artisan migrate:status
   ```

3. **Check user exists:**
   ```bash
   php artisan tinker
   >>> App\Models\User::count()
   ```

   Jika 0, run seeder:
   ```bash
   php artisan db:seed --class=UsersTableSeeder
   ```

4. **Test API manually:**
   ```bash
   curl -X POST http://103.150.197.76/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email":"admin@example.com","password":"password"}'
   ```

---

## ✅ Checklist Verification

Gunakan checklist ini untuk memastikan semuanya OK:

### Pre-Install Checks:
- [ ] APK file exists: `build\app\outputs\flutter-apk\app-release.apk`
- [ ] APK size ~52MB (bukan 20MB atau kurang)
- [ ] `.env.production` exists dan isinya benar
- [ ] `pubspec.yaml` include `.env` files di assets

### Post-Install Checks:
- [ ] App berhasil di-install tanpa error
- [ ] App bisa dibuka tanpa crash
- [ ] Logs menunjukkan "Loaded .env.production"
- [ ] API URL di logs adalah `http://103.150.197.76/api`
- [ ] Login screen muncul dengan benar

### Functional Checks:
- [ ] Bisa login dengan credentials production
- [ ] Dashboard muncul setelah login
- [ ] Data muncul dengan benar (news, complaints, etc)
- [ ] Upload image berhasil
- [ ] Logout berhasil

### Backend Checks:
- [ ] Server produksi (103.150.197.76) accessible
- [ ] Backend API responding: `curl http://103.150.197.76/api`
- [ ] Database connected
- [ ] User data exists
- [ ] CORS configured properly

---

## 📊 Expected Behavior

### Saat App Startup:
```
I/flutter (12345): ✅ Loaded .env.production
I/flutter (12345): API_BASE_URL: http://103.150.197.76/api
I/flutter (12345): STORAGE_BASE_URL: http://103.150.197.76/storage
```

### Saat Login:
```
I/flutter (12345): POST http://103.150.197.76/api/auth/login
I/flutter (12345): Response: 200 OK
```

### Saat Load Data:
```
I/flutter (12345): GET http://103.150.197.76/api/news
I/flutter (12345): GET http://103.150.197.76/api/complaints
```

---

## 🎯 Quick Test Commands

Copy-paste untuk quick verification:

### 1. Install APK:
```cmd
adb uninstall com.example.volunteer_app && adb install build\app\outputs\flutter-apk\app-release.apk
```

### 2. Monitor Logs:
```cmd
adb logcat -c && adb logcat | findstr "Loaded .env"
```

### 3. Check Backend:
```bash
curl http://103.150.197.76/api/auth/login -X POST -H "Content-Type: application/json" -d "{\"email\":\"admin@example.com\",\"password\":\"password\"}"
```

---

## 🎉 Success Indicators

**APK is correctly pointing to production if:**

✅ Logs show: `Loaded .env.production`
✅ API URL is: `http://103.150.197.76/api`
✅ Login attempts hit production server (check server logs)
✅ Images load from: `http://103.150.197.76/storage`
✅ No errors about `10.0.2.2` or `localhost`

**Jika semua indicator di atas ✅, maka APK sudah 100% pointing ke production!**

---

## 📞 Next Steps Jika Verification OK:

1. ✅ **Distribute APK** ke users/testers
2. ✅ **Monitor server logs** untuk track usage
3. ✅ **Setup backend monitoring** (optional)
4. ✅ **Prepare for Play Store** (optional, butuh signing)

## 📞 Next Steps Jika Ada Masalah:

1. ❌ Check dokumentasi: [TROUBLESHOOTING_LOGIN_PRODUCTION.md](../TROUBLESHOOTING_LOGIN_PRODUCTION.md)
2. ❌ Rebuild dengan: `flutter clean && flutter build apk --release`
3. ❌ Verify backend configuration
4. ❌ Check server logs: `tail -f laravel.log`
