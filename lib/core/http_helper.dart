import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage.dart';
import 'package:flutter/foundation.dart';

class HttpHelper {
  HttpHelper(this._storage, {this.debug = false});
  final SecureStorage _storage;
  final bool debug;

  Future<http.Response> get(Uri uri) async {
    final t = await _storage.readToken();
    final headers = _headers(t);
    if (debug) {
      debugPrint('➡️ GET $uri');
      debugPrint('➡️ Headers: $headers');
    }
    final res = await http.get(uri, headers: headers);
    if (debug) _logResponse(res);
    return res;
  }

  Future<http.Response> postJson(Uri uri, Map<String, dynamic> body) async {
    final t = await _storage.readToken();
    final headers = _headers(t);
    if (debug) {
      debugPrint('➡️ POST(JSON) $uri');
      debugPrint('➡️ Headers: $headers');
      debugPrint('➡️ Body: ${jsonEncode(body)}');
    }
    final res = await http.post(uri, headers: headers, body: jsonEncode(body));
    if (debug) _logResponse(res);
    return res;
  }

  Future<http.Response> postForm(Uri uri, Map<String, String> body) async {
    final t = await _storage.readToken();
    final headers = _headers(t, form: true);
    if (debug) {
      debugPrint('➡️ POST(FORM) $uri');
      debugPrint('➡️ Headers: $headers');
      debugPrint('➡️ Body(form): $body');
    }
    final res = await http.post(uri, headers: headers, body: body);
    if (debug) _logResponse(res);
    return res;
  }

  Map<String, String> _headers(String? token, {bool form = false}) => {
    'Accept': 'application/json',
    if (form)
      'Content-Type': 'application/x-www-form-urlencoded'
    else
      'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  void _logResponse(http.Response res) {
    final preview = () {
      final t = utf8.decode(res.bodyBytes);
      return t.length > 1000
          ? '${t.substring(0, 1000)}...(+${t.length - 1000})'
          : t;
    }();
    debugPrint('⬅️ Status: ${res.statusCode}');
    debugPrint('⬅️ RespHeaders: ${res.headers}');
    debugPrint('⬅️ Body: $preview');
  }
}
