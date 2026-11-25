import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

/// Indirizzo del server Python.
/// - predefinito: Chrome -> localhost, emulatore Android -> 10.0.2.2
/// - smartphone reale: lo imposti dall'app (icona ingranaggio nella bacheca)
///   e resta salvato sul telefono.
class AppConfig {
  static const _key = 'server_url';
  static String? _custom;

  static String get defaultUrl =>
      kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';

  static String get baseUrl => _custom ?? defaultUrl;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _custom = prefs.getString(_key);
  }

  static Future<void> save(String input) async {
    var url = input.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (url.isEmpty) {
      await reset();
      return;
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    _custom = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, url);
  }

  static Future<void> reset() async {
    _custom = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}