import 'dart:convert';
import 'package:softel_control/core/services/services.dart';
import 'package:softel_control/core/functions/checkinternet.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class Crud {
  MyServices myServices = Get.find<MyServices>();

  /// POST request for Laravel API (application/json)
  Future<Response> post(String linkurl, Map<String, dynamic> data) async {
    if (await checkInternet()) {
      try {
        var response = await http.post(
          Uri.parse(linkurl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(data),
        );
        print("Response status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        print("Request URL: $linkurl");

        return Response(
          statusCode: response.statusCode,
          body: jsonDecode(response.body),
        );
      } catch (e) {
        print("Error in POST request: $e");
        throw Exception('Server exception: $e');
      }
    } else {
      print("No internet connection");
      throw Exception('No internet connection');
    }
  }

  /// GET request for Laravel API (application/json)
  Future<Response> get(String linkurl) async {
    if (await checkInternet()) {
      try {
        // Convert data map to query parameters
        var response = await http.get(
          Uri.parse(linkurl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        print("Response status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        print("Request URL: $linkurl");

        return Response(
          statusCode: response.statusCode,
          body: jsonDecode(response.body),
        );
      } catch (e) {
        print("Error in Get request: $e");
        throw Exception('Server exception: $e');
      }
    } else {
      print("No internet connection");
      throw Exception('No internet connection');
    }
  }

  /// DELETE request for Laravel API (application/json)

  Future<Response> delete(String linkurl, Map<String, dynamic> data) async {
    if (await checkInternet()) {
      try {
        var response = await http.delete(
          Uri.parse(linkurl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(data),
        );
        print("Response status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        print("Request URL: $linkurl");

        return Response(
          statusCode: response.statusCode,
          body: jsonDecode(response.body),
        );
      } catch (e) {
        print("Error in DELETE request: $e");
        throw Exception('Server exception: $e');
      }
    } else {
      print("No internet connection");
      throw Exception('No internet connection');
    }
  }

  /// POST request for Laravel API (application/json)
  /// put

  Future<Response> put(String linkurl, Map<String, dynamic> data) async {
    if (await checkInternet()) {
      try {
        var response = await http.put(
          Uri.parse(linkurl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(data),
        );
        print("Response status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        print("Request URL: $linkurl");

        return Response(
          statusCode: response.statusCode,
          body: jsonDecode(response.body),
        );
      } catch (e) {
        print("Error in PUT request: $e");
        throw Exception('Server exception: $e');
      }
    } else {
      print("No internet connection");
      throw Exception('No internet connection');
    }
  }
}
