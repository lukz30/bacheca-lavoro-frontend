import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'models.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// Unico punto di contatto con il server + gestione della sessione azienda.
class Api {
  static String? _token;
  static String? companyName;

  static bool get isLoggedIn => _token != null;

  // ---------- sessione (persistente) ----------
  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    companyName = prefs.getString('company_name');
  }

  static Future<void> _saveSession(String token, String name) async {
    _token = token;
    companyName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('company_name', name);
  }

  static Future<void> _clearSession() async {
    _token = null;
    companyName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('company_name');
  }

  // ---------- helper HTTP ----------
  static Uri _u(String path) => Uri.parse('${AppConfig.baseUrl}$path');

  static Map<String, String> get _authHeaders =>
      {if (_token != null) 'Authorization': 'Bearer $_token'};

  static Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      return await call().timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw ApiException('Il server non risponde. Riprova.');
    } catch (_) {
      throw ApiException(
          'Impossibile contattare il server. Controlla che sia avviato e che '
          "l'indirizzo in config.dart sia corretto.");
    }
  }

  static dynamic _decode(http.Response r) {
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return r.body.isEmpty ? null : jsonDecode(utf8.decode(r.bodyBytes));
    }
    String msg = 'Errore del server (${r.statusCode})';
    try {
      final body = jsonDecode(utf8.decode(r.bodyBytes));
      if (body is Map && body['detail'] is String) {
        msg = body['detail'] as String;
      } else if (r.statusCode == 422) {
        msg = 'Dati non validi';
      }
    } catch (_) {}
    throw ApiException(msg);
  }

  static Map<String, String> get _jsonHeaders =>
      {'Content-Type': 'application/json'};

  // ---------- account azienda (R1, R2, R3) ----------
  static Future<void> register(String name, String email, String password) async {
    final r = await _send(() => http.post(_u('/auth/register'),
        headers: _jsonHeaders,
        body: jsonEncode({'name': name, 'email': email, 'password': password})));
    _decode(r);
  }

  static Future<void> login(String email, String password) async {
    final r = await _send(() => http.post(_u('/auth/login'),
        headers: _jsonHeaders,
        body: jsonEncode({'email': email, 'password': password})));
    final data = _decode(r) as Map<String, dynamic>;
    await _saveSession(data['token'] as String, data['company_name'] as String);
  }

  static Future<void> logout() async {
    try {
      await _send(() => http.post(_u('/auth/logout'), headers: _authHeaders));
    } catch (_) {
      // anche se il server non risponde, la sessione locale va chiusa
    }
    await _clearSession();
  }

  // ---------- bacheca pubblica (R5) ----------
  static Future<List<Job>> getJobs() async {
    final r = await _send(() => http.get(_u('/jobs')));
    final list = _decode(r) as List<dynamic>;
    return list.map((e) => Job.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ---------- candidatura (R6) ----------
  static Future<void> apply({
    required int jobId,
    required String firstName,
    required String lastName,
    required String email,
    required List<int> cvBytes,
    required String cvName,
  }) async {
    final req = http.MultipartRequest('POST', _u('/jobs/$jobId/apply'))
      ..fields['first_name'] = firstName
      ..fields['last_name'] = lastName
      ..fields['email'] = email
      ..files.add(http.MultipartFile.fromBytes('cv', cvBytes, filename: cvName));
    final r = await _send(() async => http.Response.fromStream(await req.send()));
    _decode(r);
  }

  // ---------- area azienda (R4, R7) ----------
  static Future<void> createJob(String title, String description) async {
    final r = await _send(() => http.post(_u('/jobs'),
        headers: {..._jsonHeaders, ..._authHeaders},
        body: jsonEncode({'title': title, 'description': description})));
    _decode(r);
  }

  static Future<List<Job>> myJobs() async {
    final r = await _send(() => http.get(_u('/my/jobs'), headers: _authHeaders));
    final list = _decode(r) as List<dynamic>;
    return list.map((e) => Job.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<Application>> getApplications(int jobId) async {
    final r = await _send(
        () => http.get(_u('/jobs/$jobId/applications'), headers: _authHeaders));
    final list = _decode(r) as List<dynamic>;
    return list
        .map((e) => Application.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Scarica il PDF in una cartella temporanea e restituisce il percorso.
  static Future<String> downloadCv(Application a) async {
    final r = await _send(
        () => http.get(_u('/applications/${a.id}/cv'), headers: _authHeaders));
    if (r.statusCode != 200) {
      _decode(r); // lancia l'errore del server
      throw ApiException('Impossibile scaricare il curriculum');
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/cv_${a.id}.pdf');
    await file.writeAsBytes(r.bodyBytes);
    return file.path;
  }
}
