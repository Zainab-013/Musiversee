import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/song.dart';

class ApiService {
static const String baseUrl = "http://192.168.168.109:8080/api";

  // =====================
  // AUTH
  // =====================
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Invalid email or password");
    }
  }

  // =====================
  // SONGS
  // =====================
  static Future<List<Song>> getAllSongs() async {
    final response = await http.get(Uri.parse("$baseUrl/songs"));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Song.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load songs");
    }
  }

  static Future<List<Song>> getSongsByCategory(String category) async {
    final response =
        await http.get(Uri.parse("$baseUrl/songs/category/$category"));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Song.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load category songs");
    }
  }

  static Future<List<Song>> searchSongs(String query) async {
    final response =
        await http.get(Uri.parse("$baseUrl/songs/search?q=$query"));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Song.fromJson(e)).toList();
    } else {
      throw Exception("Search failed");
    }
  }

  // =====================
  // SONG CRUD (UPLOAD / EDIT / DELETE)
  // =====================
  static Future<void> createSong(Song song) async {
    final response = await http.post(
      Uri.parse("$baseUrl/songs"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(song.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create song");
    }
  }

  static Future<void> updateSong(Song song) async {
    final response = await http.put(
      Uri.parse("$baseUrl/songs/${song.id}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(song.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update song");
    }
  }

  static Future<void> deleteSong(int songId) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/songs/$songId"));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to delete song");
    }
  }

  // =====================
  // LIKES
  // =====================
  static Future<List<Song>> getLikedSongs(int userId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/users/$userId/likes"));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Song.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load liked songs");
    }
  }

  static Future<void> likeSong(int userId, int songId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/users/$userId/likes/$songId"),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to like song");
    }
  }

  static Future<void> unlikeSong(int userId, int songId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/users/$userId/likes/$songId"),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to unlike song");
    }
  }
}
