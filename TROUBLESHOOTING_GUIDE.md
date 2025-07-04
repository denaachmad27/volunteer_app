# Bantuan Sosial Mobile App - Troubleshooting Guide

## 🐛 Masalah yang Diperbaiki

### 1. ✅ Error: NoSuchMethodError pada syarat_bantuan.map()

**Masalah**: 
```
NoSuchMethodError: Class 'String' has no instance method 'map'. 
Receiver: "KTP, KK, Proposal usaha, SKTM, Surat Jaminan" 
tried calling: map<Widget>(Closure: (dynamic) => Padding)
```

**Penyebab**: 
- Field `syarat_bantuan` dari API berupa String (comma-separated) atau JSON String
- Kode sebelumnya mengasumsikan data berupa List

**Solusi yang Diterapkan**:
1. **Dibuat helper method `_getSyaratBantuanWidgets()`**:
   ```dart
   List<Widget> _getSyaratBantuanWidgets(dynamic syaratBantuan) {
     // Handle multiple data types: String, JSON String, List, null
     // Convert to List<String> then map to Widgets
   }
   ```

2. **Parsing Multi-format**:
   - Null/Empty → Default message
   - JSON String → Parse JSON ke List
   - Comma-separated String → Split by comma
   - List → Direct cast to List<String>

3. **Error Boundary**: Try-catch untuk menangani parsing errors

---

### 2. ✅ Data Tidak Lengkap dari Admin Panel

**Masalah**: 
- Mobile app tidak menampilkan semua program yang ada di admin panel
- Data kuota tidak sesuai

**Penyebab**:
- Limit API terlalu kecil (10 items)
- Parsing data kuota tidak robust
- Filtering kategori terlalu ketat

**Solusi yang Diterapkan**:

1. **Increase API Limit**:
   ```dart
   // Dari limit: 10 menjadi limit: 50
   static Future<Map<String, dynamic>> getAllPrograms({
     int limit = 50, // Increased from 10
   })
   ```

2. **Robust Data Parsing**:
   ```dart
   static int _parseIntValue(dynamic value) {
     if (value == null) return 0;
     if (value is int) return value;
     if (value is String) return int.tryParse(value) ?? 0;
     return 0;
   }
   ```

3. **Enhanced Debugging**:
   - Added comprehensive logging
   - API response structure debugging
   - Data type validation

---

## 🔍 Debugging Tools yang Ditambahkan

### 1. Comprehensive Logging
- API request/response logging
- Data structure analysis
- Error tracking dengan context

### 2. Debug Prints dalam Development
```dart
print('=== Programs loaded successfully ===');
print('Total programs received: ${result['data'].length}');
print('Program keys: ${programs[0].keys}');
print('syarat_bantuan type: ${program['syarat_bantuan'].runtimeType}');
```

### 3. Error Boundary Implementation
- Try-catch pada setiap API call
- Graceful fallback untuk data parsing
- User-friendly error messages

---

## 🚨 Masalah Umum & Solusi

### Problem 1: "Tidak ada program bantuan tersedia"

**Kemungkinan Penyebab**:
1. Laravel backend tidak running
2. API endpoint tidak sesuai
3. Data kosong di database
4. Network connection issues

**Cara Debug**:
1. Check console logs untuk API errors
2. Verify Laravel backend running di `localhost:8000`
3. Test API endpoint di browser: `http://localhost:8000/api/bantuan-sosial`
4. Check database apakah ada data program

**Solusi**:
```bash
# Start Laravel backend
cd /mnt/c/Projects/volunteer/admin-panel-bantuan-sosial
php artisan serve

# Seed database jika kosong
php artisan db:seed
```

### Problem 2: "Connection refused, errno = 111"

**Penyebab**: API Service tidak bisa connect ke backend

**Solusi**:
1. **Check API URL Configuration**:
   ```dart
   // Di api_service.dart
   static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
   // atau
   static const String baseUrl = 'http://127.0.0.1:8000/api'; // iOS simulator
   ```

2. **Verify Laravel Backend**:
   ```bash
   php artisan serve --host=0.0.0.0 --port=8000
   ```

### Problem 3: "syarat_bantuan" Data Corruption

**Penyebab**: Inconsistent data format dari database

**Solusi**: Updated helper method handles multiple formats:
- JSON Array: `["KTP", "KK", "SKTM"]`
- Comma-separated: `"KTP, KK, SKTM"`
- Plain string: `"KTP KK SKTM"`

### Problem 4: Quota Calculation Errors

**Penyebab**: Mixed data types (String vs Integer)

**Solusi**: Robust parsing dengan `_parseIntValue()`:
```dart
final kuota = _parseIntValue(program['kuota']);
final kuotaTerpakai = _parseIntValue(program['kuota_terpakai'] ?? 0);
```

---

## 📱 Testing Checklist

### Pre-Test Setup
- [ ] Laravel backend running (`php artisan serve`)
- [ ] Database seeded dengan data program
- [ ] Mobile app compiled without errors
- [ ] Network connectivity available

### Test Scenarios

#### ✅ Program Loading
- [ ] Load programs successfully
- [ ] Handle empty data gracefully
- [ ] Show loading states
- [ ] Display error messages for network issues

#### ✅ Category Filtering  
- [ ] Filter by "Semua" shows all programs
- [ ] Filter by specific category works
- [ ] Category change triggers refresh
- [ ] No data state handled properly

#### ✅ Program Details
- [ ] Modal opens without errors
- [ ] syarat_bantuan displays correctly
- [ ] All program information visible
- [ ] Currency formatting correct

#### ✅ Application Submission
- [ ] Form opens successfully
- [ ] Input validation works
- [ ] Submission shows loading state
- [ ] Success/error feedback displayed
- [ ] Tab switches after successful submission

#### ✅ Application Tracking
- [ ] User applications load correctly
- [ ] Status badges show proper colors
- [ ] Date formatting is readable
- [ ] Admin notes display when available
- [ ] Empty state shows call-to-action

---

## 🔧 Development Tools

### Debug Mode Enabling
Add debug prints in development:
```dart
// In BantuanSosialService
print('=== API Request ===');
print('Endpoint: $endpoint');
print('Response: ${response.body}');
```

### Network Debugging
Use Charles Proxy atau similar untuk monitor HTTP requests:
1. Proxy: `127.0.0.1:8888`
2. Monitor requests ke `10.0.2.2:8000`
3. Check request/response headers dan body

### Database Debugging
```sql
-- Check programs data
SELECT id, nama_bantuan, jenis_bantuan, syarat_bantuan, kuota, kuota_terpakai 
FROM bantuan_sosials WHERE status = 'Aktif';

-- Check data types
DESCRIBE bantuan_sosials;
```

---

## 🎯 Performance Optimizations

### 1. Pagination Implementation
```dart
// Load data in chunks
limit: 50, // Reasonable chunk size
page: currentPage, // Track current page
```

### 2. Caching Strategy
- Cache API responses locally
- Implement pull-to-refresh
- Smart loading states

### 3. Error Recovery
- Automatic retry mechanisms
- Graceful degradation
- Offline capability (future enhancement)

---

## 📞 Support & Contact

Jika masih mengalami masalah:

1. **Check Logs**: Look for detailed error messages in debug console
2. **Verify Backend**: Ensure Laravel API is accessible
3. **Test API**: Use Postman/curl to test endpoints directly
4. **Data Validation**: Check database for data consistency

**Common Commands**:
```bash
# Laravel backend
php artisan serve --host=0.0.0.0

# Flutter rebuild
flutter clean && flutter pub get && flutter run

# API testing
curl -X GET "http://127.0.0.1:8000/api/bantuan-sosial"
```

---

**Status**: ✅ **MAJOR ISSUES RESOLVED**  
**Last Updated**: Today  
**Version**: Mobile App v2.0 with Enhanced API Integration