import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Request storage permission
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  // Check if camera permission is granted
  static Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  // Check if storage permission is granted
  static Future<bool> isStoragePermissionGranted() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  // Request all permissions needed for image picker
  static Future<bool> requestImagePickerPermissions() async {
    final cameraPermission = await requestCameraPermission();
    final storagePermission = await requestStoragePermission();
    
    return cameraPermission && storagePermission;
  }

  // Check if all permissions are granted
  static Future<bool> hasImagePickerPermissions() async {
    final cameraGranted = await isCameraPermissionGranted();
    final storageGranted = await isStoragePermissionGranted();
    
    return cameraGranted && storageGranted;
  }
}