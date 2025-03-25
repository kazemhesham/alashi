import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../model/vendors_model.dart';

class VendorsService {
  Future<Vendors> getVendor() async {
    final urlpro = Uri.parse(
      'https://alashi.online/backendapi/public/api/vendors',
    );
    final response = await http.get(urlpro);

    if (response.statusCode == 200) {
      final Map<String, dynamic> dataVendor = jsonDecode(response.body);
      return Vendors.fromJson(dataVendor);
    } else {
      throw ('error: ${response.body}');
    }
  }
}

final vendorsServiceProvider = Provider<VendorsService>((ref) {
  return VendorsService();
});

final vendorsListProvider = FutureProvider<Vendors>((ref) async {
  final vendorsService = VendorsService();
  return await vendorsService.getVendor();
});

class VendorNotifier extends StateNotifier<Vendors?> {
  VendorNotifier() : super(null);
  Future<void> addVendor(
    String name,
    String phone,
    String email,
    String adress,
    VendorLang vendorLang,
  ) async {
    final urllogin = Uri.parse(
      'https://alashi.online/backendapi/public/api/addvendor',
    );
    try {
      final response = await http.post(
        urllogin,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'email': email,
          'adress': adress,
          'vendor_lang': vendorLangValues.reverse[vendorLang],
        }),
      );
      // print("Converted vendor_lang: ${vendorLangValues.reverse[vendorLang]}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log("Vendor added successfully: ${data['vendor']}");
        if (data['vendor'] != null) {
          state = Vendors.fromJson(data['vendor']);
          log(
            'Vendor Number Type: ${data['vendor']['vendor_number'].runtimeType}',
          );
        }
      } else {
        log("added failed: ${response.body}");
        state = null;
      }
    } catch (e) {
      log("Exception: $e");
      state = null;
    }
  }

  Future<void> deletVendor(int id) async {
    final urllogin = Uri.parse(
      'https://alashi.online/backendapi/public/api/vendors/$id',
    );
    try {
      final response = await http.delete(urllogin);

      if (response.statusCode == 200 || response.statusCode == 204) {
        log("Vendor deleted successfully.");
      } else {
        log("Deletion failed: ${response.body}");
        throw Exception("Failed to delete Vendor");
      }
    } catch (e) {
      log("Exception: $e");
      throw Exception("Error occurred while deleting Vendor");
    }
  }

  Future<void> editVendor(
    int id,
    String name,
    String phone,
    String email,
    String adress,
    VendorLang vendorLang,
  ) async {
    final urllogin = Uri.parse(
      'https://alashi.online/backendapi/public/api/vendors/$id',
    );
    try {
      final response = await http.put(
        urllogin,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'email': email,
          'adress': adress,
          "vendor_lang": vendorLangValues.reverse[vendorLang],
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        log("Vendor update successfully: ${data['success']}");
        if (data['data'] != null) {
          state = Vendors.fromJson(data['data']);
        }
      } else {
        log("update failed: ${response.body}");
        state = null;
      }
    } catch (e) {
      log("Exception: $e");
      state = null;
    }
  }

  Future<Vendor1> getEditVendor(int id) async {
    final urllogin = Uri.parse(
      'https://alashi.online/backendapi/public/api/vendors/$id/edit',
    );
    final response = await http.get(urllogin);

    if (response.statusCode == 200) {
      final Map<String, dynamic> dataVendor = jsonDecode(response.body);

      // تحقق من وجود بيانات التاجر مباشرة
      if (dataVendor['vendor'] != null) {
        return Vendor1.fromJson(dataVendor['vendor']);
      } else {
        throw Exception('لا يوجد بيانات للمورد');
      }
    } else {
      throw Exception('فشل في جلب البيانات: ${response.statusCode}');
    }
  }

  // Future<void> sendMessageToVendors(
  //   String message,
  //   List<int> selectedVendors,
  // ) async {
  //   final url = Uri.parse(
  //     'https://alashi.online/backendapi/public/api/multiplemessagevendor',
  //   );
  //   final headers = {'Content-Type': 'application/json'};
  //   final body = jsonEncode({
  //     'message': message,
  //     'allSelected': false, // تحديد يدوي
  //     'selectedVendorIds  ': selectedVendors,
  //   });

  //   final response = await http.post(url, headers: headers, body: body);

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     log("Vendor send message successfully: $data");
  //   } else {
  //     log("send message failed: ${response.body}");
  //     state = null;
  //   }
  // }
}

final vendorProvider = StateNotifierProvider<VendorNotifier, Vendors?>((ref) {
  return VendorNotifier();
});
