import 'dart:convert';
import 'package:warranti_app/constants.dart';
import 'package:warranti_app/service/token_service.dart';
import 'package:http/http.dart' as http;

class WarrantiesService {
  /// Gets all warranties
  static Future<List<dynamic>> fetchWarranties() async {
    try {
      String? token = await getToken();

      if (token == null) {
        print('No token found');
        return [];
      }

      final response = await http.get(
        Uri.parse('$backend_uri/warranty/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        print("Response body: ${response.body}");
        try {
          final decodedResponse = jsonDecode(response.body);
          if (decodedResponse is Map<String, dynamic> &&
              decodedResponse.containsKey('warranties')) {
            final List<dynamic> warranties = decodedResponse['warranties'];
            return warranties;
          } else {
            print('Unexpected response format: $decodedResponse');
            return [];
          }
        } catch (e) {
          print('Error decoding response: $e');
          return [];
        }
      } else {
        print('Failed to fetch warranties: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching warranties: $e');
      return [];
    }
  }

  /// Gets warranty by Id
  static Future<dynamic> fetchWarranty(String id) async {
    try {
      String? token = await getToken();

      if (token == null) {
        print('No token found');
        return [];
      }
      final response = await http.get(
        Uri.parse('$backend_uri/warranty/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        print("Response body: ${response.body}");
        try {
          final decodedResponse = jsonDecode(response.body);
          if (decodedResponse is Map<String, dynamic> &&
              decodedResponse.containsKey('warranty')) {
            final dynamic warranty = decodedResponse['warranty'];
            return warranty;
          } else {
            print('Unexpected response format: $decodedResponse');
            return [];
          }
        } catch (e) {
          print('Error decoding response: $e');
          return [];
        }
      } else {
        print('Failed to fetch warranty: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching warranty: $e');
      return [];
    }
  }
}
