import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import 'package:file_picker/file_picker.dart';
import '../models/song.dart';

class ApiService {
  // Automatically select host depending on platform (localhost for Web/Desktop, 10.0.2.2 for Android Emulator)
  static String get baseUrl {
    // Set to true to use your production Render backend, or false for local development
    const bool isProduction = true;

    if (isProduction) {
      return "https://musiverse-backend.onrender.com/api";
    }

    if (kIsWeb) {
      return "http://localhost:8080/api";
    } else if (Platform.isAndroid) {
      return "http://10.148.47.109:8080/api";
    } else {
      return "http://localhost:8080/api";
    }
  }

  static const _timeout = Duration(seconds: 15);

  // =====================
  // JWT TOKEN MANAGEMENT
  // =====================
  static String? _token;

  static void setToken(String? token) {
    _token = token;
  }

  static Map<String, String> get _headers => {
        "Content-Type": "application/json",
      };

  static Map<String, String> get _authHeaders => {
        "Content-Type": "application/json",
        if (_token != null) "Authorization": "Bearer $_token",
      };

  // =====================
  // AUTH
  // =====================
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: _headers,
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Store token from response
        if (data['token'] != null) {
          _token = data['token'];
        }
        return data;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Registration failed');
      }
    } on SocketException {
      throw Exception('Cannot connect to server. Please check your connection.');
    }
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: _headers,
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Store token from response
        if (data['token'] != null) {
          _token = data['token'];
        }
        return data;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Invalid email or password');
      }
    } on SocketException {
      throw Exception('Cannot connect to server. Please check your connection.');
    }
  }

  // =====================
  // SONGS
  // =====================
  static Future<List<Song>> getAllSongs() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/songs"),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Song.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load songs");
      }
    } on SocketException {
      throw Exception('Cannot connect to server.');
    }
  }

  static Future<List<Song>> getSongsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/songs/category/$category"),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Song.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load category songs");
      }
    } on SocketException {
      throw Exception('Cannot connect to server.');
    }
  }

  static Future<List<Song>> searchSongs(String query) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/songs/search?q=$query"),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Song.fromJson(e)).toList();
      } else {
        throw Exception("Search failed");
      }
    } on SocketException {
      throw Exception('Cannot connect to server.');
    }
  }

  // =====================
  // SONG CRUD (UPLOAD / EDIT / DELETE) — REQUIRES AUTH
  // =====================
  static Future<void> createSong(Song song, PlatformFile songFile, PlatformFile imageFile) async {
    try {
      final uri = Uri.parse("$baseUrl/songs");
      final request = http.MultipartRequest("POST", uri);

      if (_token != null) {
        request.headers["Authorization"] = "Bearer $_token";
      }

      request.fields["songName"] = song.name;
      request.fields["movie"] = song.movie;
      request.fields["singer"] = song.singer;
      request.fields["actor"] = song.actor ?? "";
      request.fields["actress"] = song.actress ?? "";
      request.fields["composer"] = song.composer;
      request.fields["lyricist"] = song.lyricist;
      request.fields["category"] = song.category;

      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          "songFile",
          songFile.bytes!,
          filename: songFile.name,
        ));
        request.files.add(http.MultipartFile.fromBytes(
          "imageFile",
          imageFile.bytes!,
          filename: imageFile.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          "songFile",
          songFile.path!,
        ));
        request.files.add(await http.MultipartFile.fromPath(
          "imageFile",
          imageFile.path!,
        ));
      }

      final streamedResponse = await request.send().timeout(const Duration(minutes: 5));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorMsg = jsonDecode(response.body)['error'] ?? "Failed to create song";
        throw Exception(errorMsg);
      }
    } on SocketException {
      throw Exception('Cannot connect to server.');
    }
  }

  static Future<void> updateSong(Song song, PlatformFile? songFile, PlatformFile? imageFile) async {
    try {
      final uri = Uri.parse("$baseUrl/songs/${song.id}");
      final request = http.MultipartRequest("PUT", uri);

      if (_token != null) {
        request.headers["Authorization"] = "Bearer $_token";
      }

      request.fields["songName"] = song.name;
      request.fields["movie"] = song.movie;
      request.fields["singer"] = song.singer;
      request.fields["actor"] = song.actor ?? "";
      request.fields["actress"] = song.actress ?? "";
      request.fields["composer"] = song.composer;
      request.fields["lyricist"] = song.lyricist;
      request.fields["category"] = song.category;

      if (songFile != null) {
        if (kIsWeb) {
          request.files.add(http.MultipartFile.fromBytes(
            "songFile",
            songFile.bytes!,
            filename: songFile.name,
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(
            "songFile",
            songFile.path!,
          ));
        }
      }

      if (imageFile != null) {
        if (kIsWeb) {
          request.files.add(http.MultipartFile.fromBytes(
            "imageFile",
            imageFile.bytes!,
            filename: imageFile.name,
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(
            "imageFile",
            imageFile.path!,
          ));
        }
      }

      final streamedResponse = await request.send().timeout(const Duration(minutes: 5));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        final errorMsg = jsonDecode(response.body)['error'] ?? "Failed to update song";
        throw Exception(errorMsg);
      }
    } on SocketException {
      throw Exception('Cannot connect to server.');
    }
  }

  static Future<void> deleteSong(int songId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/songs/$songId"),
        headers: _authHeaders,
      ).timeout(_timeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception("Failed to delete song");
      }
    } on SocketException {
      throw Exception('Cannot connect to server.');
    }
  }

  // =====================
  // LIKES — REQUIRES AUTH
  // =====================
  static Future<List<Song>> getLikedSongs() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/songs/liked"),
        headers: _authHeaders,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Song.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load liked songs");
      }
    } on SocketException {
      throw Exception('Cannot connect to server.');
    }
  }

  static Future<void> likeSong(int songId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/songs/$songId/like"),
        headers: _authHeaders,
      ).timeout(_timeout);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed to like song");
      }
    } on SocketException {
      throw Exception('Cannot connect to server.');
    }
  }

  static Future<void> unlikeSong(int songId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/songs/$songId/unlike"),
        headers: _authHeaders,
      ).timeout(_timeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception("Failed to unlike song");
      }
    } on SocketException {
      throw Exception('Cannot connect to server.');
    }
  }

  // =====================
  // PROFILE UPDATE
  // =====================
  static Future<Map<String, dynamic>> updateProfile(
      String name, String email, String? password) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/auth/profile"),
        headers: _authHeaders,
        body: jsonEncode({
          "name": name,
          "email": email,
          if (password != null && password.isNotEmpty) "password": password,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          _token = data['token'];
        }
        return data;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Profile update failed');
      }
    } on SocketException {
      throw Exception('Cannot connect to server.');
    }
  }

  // =====================
  // HIDDEN SONGS
  // =====================
  static Future<List<Song>> getHiddenSongs() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/songs/hidden"),
        headers: _authHeaders,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Song.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load hidden songs");
      }
    } on SocketException {
      throw Exception('Cannot connect to server.');
    }
  }

  static Future<void> unhideSong(int songId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/songs/$songId/unhide"),
        headers: _authHeaders,
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception("Failed to unhide song");
      }
    } on SocketException {
      throw Exception('Cannot connect to server.');
    }
  }
}
