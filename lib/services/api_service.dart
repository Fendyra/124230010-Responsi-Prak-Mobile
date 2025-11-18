import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:responsi_prak_mobile/models/product_model.dart';

class ApiService {
  final String baseUrl = 'https://fakestoreapi.com/products';

  Future<List<Product>> fetchTopProduct({String? type}) async {
    String url = baseUrl;

    if (type != null && type.isNotEmpty) {
      url = '$baseUrl?limit=20';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load top products');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final allProducts = data.map((json) => Product.fromJson(json)).toList();
      
      final searchQuery = query.toLowerCase();
      return allProducts.where((product) {
        return product.title.toLowerCase().contains(searchQuery) ||
               product.description.toLowerCase().contains(searchQuery);
      }).toList();
    } else {
      throw Exception('Failed to search products');
    }
  }
}