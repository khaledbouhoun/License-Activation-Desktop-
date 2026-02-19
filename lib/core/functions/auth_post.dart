import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:softel_control/linkapi.dart';

/// Sends an authenticated POST request to the given URL.
/// Adds Authorization header with Bearer token and X-DESKTOP-APP-KEY.
Future<http.Response> authPost(String url, Map<String, dynamic> body) async {
  print("AuthPost Request to: $url");

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-DESKTOP-APP-KEY': AppLink.desktopAppKey,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      // Token expired or invalid
      print("AuthPost 401 Unauthorized. Access denied.");
    }

    return response;
  } catch (e) {
    print("AuthPost Exception: $e");
    rethrow;
  }
}

// Auth Get
Future<http.Response> authGet(String url) async {
  print("AuthGet Request to: $url");

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-DESKTOP-APP-KEY': AppLink.desktopAppKey,
      },
    );
    print("AuthGet Request to: $url");
    print("AuthGet Headers: ${response.headers}");
    print("AuthGet Status Code: ${response.statusCode}");
    print("AuthGet Response: ${response.body}");

    if (response.statusCode == 401) {
      print("AuthGet 401 Unauthorized.");
    }

    return response;
  } catch (e) {
    print("AuthGet Exception: $e");
    rethrow;
  }
}

// Auth Put
Future<http.Response> authPut(String url, Map<String, dynamic> body) async {
  print("AuthPut Request to: $url");

  try {
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-DESKTOP-APP-KEY': AppLink.desktopAppKey,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      print("AuthPut 401 Unauthorized.");
    }

    return response;
  } catch (e) {
    print("AuthPut Exception: $e");
    rethrow;
  }
}

// Auth Delete
Future<http.Response> authDelete(String url, Map<String, dynamic> body) async {
  print("AuthDelete Request to: $url");

  try {
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-DESKTOP-APP-KEY': AppLink.desktopAppKey,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      print("AuthDelete 401 Unauthorized.");
    }

    return response;
  } catch (e) {
    print("AuthDelete Exception: $e");
    rethrow;
  }
}
