
// class ApiService {
//   // Update this base URL to match your PHP server
//   static const String baseUrl = 'http://192.168.43.220:8012/mercerie/api';

//   // Headers for API requests
//   static const Map<String, String> headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};

//   // Get all products
//   static Future<List<Product>> getProducts({int? categoryId}) async {
//     try {
//       String url = '$baseUrl/products.php';
//       if (categoryId != null) {
//         url += '?category_id=$categoryId';
//       }

//       final response = await http.get(Uri.parse(url), headers: headers);

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonResponse = json.decode(response.body);

//         if (jsonResponse['success'] == true) {
//           final List<dynamic> jsonData = jsonResponse['data'] ?? [];
//           return jsonData.map((json) => Product.fromJson(json)).toList();
//         } else {
//           throw Exception(jsonResponse['message'] ?? 'Failed to load products');
//         }
//       } else {
//         throw Exception('Failed to load products: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching products: $e');
//     }
//   }

//   // Get all categories
//   static Future<List<Category>> getCategories() async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/categories.php'), headers: headers);

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonResponse = json.decode(response.body);

//         if (jsonResponse['success'] == true) {
//           final List<dynamic> jsonData = jsonResponse['data'] ?? [];
//           return jsonData.map((json) => Category.fromJson(json)).toList();
//         } else {
//           throw Exception(jsonResponse['message'] ?? 'Failed to load categories');
//         }
//       } else {
//         throw Exception('Failed to load categories: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching categories: $e');
//     }
//   }

//   // Search products
//   static Future<List<Product>> searchProducts(String query) async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/products.php?search=$query'), headers: headers);

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonResponse = json.decode(response.body);

//         if (jsonResponse['success'] == true) {
//           final List<dynamic> jsonData = jsonResponse['data'] ?? [];
//           return jsonData.map((json) => Product.fromJson(json)).toList();
//         } else {
//           throw Exception(jsonResponse['message'] ?? 'Failed to search products');
//         }
//       } else {
//         throw Exception('Failed to search products: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error searching products: $e');
//     }
//   }
// }
