import 'dart:convert';
import 'dart:io';
import 'package:warranti_app/constants.dart';
import 'package:warranti_app/service/token_service.dart';
import 'package:http/http.dart' as http;
import 'package:warranti_app/util/logger.dart';

class WarrantiesService {
  static final log = getLogger('WarrantiesService');

  // Gets all warranties
  static Future<List<dynamic>> fetchWarranties() async {
    try {
      String? token = await TokenService.getToken();

      if (token == null) {
        log.i('No token found');
        return [];
      }

      final response = await http.get(
        Uri.parse('$backendUri/warranty/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        log.d("Response body: ${response.body}");
        try {
          final decodedResponse = jsonDecode(response.body);
          if (decodedResponse is Map<String, dynamic> &&
              decodedResponse.containsKey('warranties')) {
            final List<dynamic> warranties = decodedResponse['warranties'];
            return warranties;
          } else {
            log.d('Unexpected response format: $decodedResponse');
            return [];
          }
        } catch (e) {
          log.e('Error decoding response: $e');
          return [];
        }
      } else {
        log.i('Failed to fetch warranties: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log.e('Error fetching warranties: $e');
      return [];
    }
  }

  // Gets warranty by Id
  static Future<dynamic> fetchWarranty(String id) async {
    try {
      String? token = await TokenService.getToken();

      if (token == null) {
        log.i('No token found');
        return [];
      }
      final response = await http.get(
        Uri.parse('$backendUri/warranty/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        log.d("Response body: ${response.body}");
        try {
          final decodedResponse = jsonDecode(response.body);
          if (decodedResponse is Map<String, dynamic> &&
              decodedResponse.containsKey('warranty')) {
            final dynamic warranty = decodedResponse['warranty'];
            return warranty;
          } else {
            log.d('Unexpected response format: $decodedResponse');
            return [];
          }
        } catch (e) {
          log.e('Error decoding response: $e');
          return [];
        }
      } else {
        log.i('Failed to fetch warranty: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log.e('Error fetching warranty: $e');
      return [];
    }
  }

  // Creates new warranty
  static Future<bool> createWarranty({
    required String productName,
    required String purchaseDate,
    required String warrantyDuration,
    required String warrantyDurationUnit,
    File? productPhoto,
    File? warrantyCardPhoto,
    File? receiptPhoto,
  }) async {
    try {
      String? token = await TokenService.getToken();
      if (token == null) {
        log.i('No token found');
        return false;
      }

      final url = Uri.parse('$backendUri/warranty/create');
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll({'Authorization': token})
        ..fields['productName'] = productName
        ..fields['purchaseDate'] = purchaseDate
        ..fields['warrantyDuration'] = warrantyDuration
        ..fields['warrantyDurationUnit'] = warrantyDurationUnit;

      if (productPhoto != null) {
        request.files.add(
            await http.MultipartFile.fromPath('product', productPhoto.path));
      }
      if (warrantyCardPhoto != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'warrantyCard', warrantyCardPhoto.path));
      }
      if (receiptPhoto != null) {
        request.files.add(
            await http.MultipartFile.fromPath('receipt', receiptPhoto.path));
      }

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        log.i('Warranty created successfully');
        return true;
      } else {
        log.e('Error: ${response.statusCode}');
        log.d('Response Body: ${responseBody.body}');
        return false;
      }
    } catch (e) {
      log.e('Error creating warranty: $e');
      return false;
    }
  }

  // Delete warranty
  static Future<dynamic> deleteWarranty(String id) async {
    try {
      String? token = await TokenService.getToken();

      if (token == null) {
        log.i('No token found');
        return [];
      }
      final response = await http.delete(
        Uri.parse('$backendUri/warranty/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        log.i('Warranty deleted successfully');
      }
    } catch (e) {
      log.e('Error deleting warranty: $e');
    }
  }
}
