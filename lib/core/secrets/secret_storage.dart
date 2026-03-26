import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secrets_type.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Generic set method
  static Future<void> setValue(StorageKey key, String value) async {
    await _storage.write(key: key.key, value: value);
  }

  // Generic get method
  static Future<String?> getValue(StorageKey key) async {
    return await _storage.read(key: key.key);
  }

  // Generic delete method
  static Future<void> deleteValue(StorageKey key) async {
    await _storage.delete(key: key.key);
  }

  // Clear all user data
  static Future<void> clearUserData() async {
    for (StorageKey key in StorageKey.values) {
      await deleteValue(key);
    }
  }

  // Get all data (for debugging)
  static Future<Map<String, String>> getAllData() async {
    return await _storage.readAll();
  }

  // Check if key exists
  static Future<bool> hasValue(StorageKey key) async {
    return await _storage.containsKey(key: key.key);
  }

  // Clear everything
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

/*
! Set values
await SecureStorageService.setValue(StorageKey.email, "user@example.com");
await SecureStorageService.setValue(StorageKey.token, "jwt_token");


! Get values
final email = await SecureStorageService.getValue(StorageKey.email);
final token = await SecureStorageService.getToken();

*/
