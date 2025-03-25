import 'dart:convert';
import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import '../model/prodact_model.dart';

class ProdactService {
  Future<AllPrdact> getProdact() async {
    final url = Uri.parse(
      'https://alashi.online/backendapi/public/api/products',
    );
    final response = await http.get(url);
    final data = jsonDecode(response.body);
    // log("Login successful11: ${data}");

    if (response.statusCode == 200) {
      // log("Login successful: ${data}");

      return AllPrdact.fromJson(data);
    } else {
      throw Exception('Error fetching products: ${response.body}');
    }
  }
}

final prodactServiceProvider = Provider<ProdactService>((ref) {
  return ProdactService();
});

final prodactListProvider = FutureProvider<AllPrdact>((ref) async {
  final prodactService = ref.watch(prodactServiceProvider);
  return await prodactService.getProdact();
});

class ProdactNotifier extends StateNotifier<Product?> {
  ProdactNotifier() : super(null);

  Future<void> addProduct(
    int dealerId,
    String quantity,
    String fiQuantity,
    String type,
    DateTime receivingDate,
    int paidAmount,
    int remainingaamount, // تعديل الاسم ليطابق API
    int totalAmount,
    int invoiceValue,
    String deliveryAddress,
    String recipient,
    String remarks,
    String cmp,
    int vendorId,
    int skipNotifications,
  ) async {
    final url = Uri.parse(
      'https://alashi.online/backendapi/public/api/addproduct',
    );

    try {
      // log("🚀 إرسال الطلب إلى السيرفر...");

      final Map<String, dynamic> requestBody = {
        'dealer_id': dealerId,
        'Quantity': quantity,
        'fi_Quantity':
            fiQuantity.isNotEmpty ? fiQuantity : "غير محدد", // معالجة `null`
        'Type': type,
        'ReceivingDate': DateFormat('yyyy-MM-dd').format(receivingDate),
        'paidamount': paidAmount,
        'remainingaamount': remainingaamount, // استخدام الاسم الصحيح
        'totalamount': totalAmount,
        'InvoiceValue': invoiceValue,
        'Deliveryaddress':
            deliveryAddress.isNotEmpty
                ? deliveryAddress
                : "غير متوفر", // معالجة `null`
        'Recipient':
            recipient.isNotEmpty ? recipient : "غير محدد", // معالجة `null`
        'Remarks': remarks.isNotEmpty ? remarks : "لا يوجد", // معالجة `null`
        'cmp': cmp.isNotEmpty ? cmp : "0",
        'vendor_id': vendorId,
        'skip_notifications': skipNotifications,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // log("📥 استجابة السيرفر: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 201) {
        log("✅ المنتج تمت إضافته بنجاح!");
      } else {
        log("❌ فشل الإضافة: ${response.statusCode} - ${response.body}");
        throw Exception("فشل الإضافة: ${response.body}");
      }
    } catch (e) {
      log("❌ خطأ أثناء الإضافة: $e");
      throw Exception("خطأ أثناء الإضافة: $e");
    }
  }

  Future<void> deleteProduct(int id) async {
    final url = Uri.parse(
      'https://alashi.online/backendapi/public/api/products/$id',
    );

    final response = await http.delete(url);

    if (response.statusCode == 200 || response.statusCode == 204) {
      log("Product deleted successfully.");
      state = null;
    } else {
      log("Error deleting product: ${response.body}");
      throw Exception("Failed to delete Product");
    }
  }

  Future<void> editProduct(
    int productId,
    int dealerId,
    String quantity,
    String fiQuantity,
    String type,
    DateTime receivingDate,
    int paidAmount,
    int remainingAmount,
    int invoiceValue,
    String deliveryAddress,
    String remarks,
    String cmp,
    int vendorId,
  ) async {
    final url = Uri.parse(
      'https://alashi.online/backendapi/public/api/products/$productId',
    );

    try {
      log("🚀 إرسال الطلب لتعديل المنتج...");

      final Map<String, dynamic> requestBody = {
        'dealer_id': dealerId,
        'Quantity': quantity,
        'fi_Quantity': fiQuantity.isNotEmpty ? fiQuantity : "غير محدد",
        'Type': type,
        'ReceivingDate': DateFormat('yyyy-MM-dd').format(receivingDate),
        'paidamount': paidAmount,
        'remainingaamount': remainingAmount,
        'InvoiceValue': invoiceValue,
        'Deliveryaddress':
            deliveryAddress.isNotEmpty ? deliveryAddress : "غير متوفر",
        'Remarks': remarks.isNotEmpty ? remarks : "لا يوجد",
        'cmp': cmp.isNotEmpty ? cmp : "0",
        'vendor_id': vendorId,
      };

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      log("📥 استجابة السيرفر: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ المنتج تم تعديله بنجاح!");
      } else {
        log("❌ فشل التعديل: ${response.statusCode} - ${response.body}");
        throw Exception("فشل التعديل: ${response.body}");
      }
    } catch (e) {
      log("❌ خطأ أثناء التعديل: $e");
      throw Exception("خطأ أثناء التعديل: $e");
    }
  }

  Future<Product> getEditProduct(int id) async {
    final url = Uri.parse(
      'https://alashi.online/backendapi/public/api/products/$id/edit',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      print('API Response: $responseData'); // طباعة الاستجابة لفحص البيانات

      if (responseData['Product'] != null) {
        return Product.fromJson(responseData['Product']);
      } else {
        throw Exception('لا يوجد بيانات للشحنة');
      }
    } else {
      throw Exception('فشل في جلب البيانات: ${response.statusCode}');
    }
  }
}

final prodactNotifierProvider =
    StateNotifierProvider<ProdactNotifier, Product?>((ref) {
      return ProdactNotifier();
    });
