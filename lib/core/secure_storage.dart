import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _s = const FlutterSecureStorage();

  Future<void> saveToken(String token) => _s.write(key: 'token', value: token);
  Future<String?> readToken() => _s.read(key: 'token');
  Future<void> clear() => _s.deleteAll();
}
