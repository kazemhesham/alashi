import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../model/billof_model.dart';

class BillofsService {
  Future<Billofladings> getBillof() async {
    final url =
        Uri.parse('https://alashi.online/backendapi/public/api/billofladings');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Billofladings.fromJson(data);
    } else {
      throw Exception('Error fetching Billofladings: ${response.body}');
    }
  }
}

final billofServiceProvider = Provider<BillofsService>((ref) {
  return BillofsService();
});

final billofListProvider = FutureProvider<Billofladings>((ref) async {
  final billofService = ref.watch(billofServiceProvider);
  return await billofService.getBillof();
});

class BillofladingNotifier extends StateNotifier<Billoflading?> {
  BillofladingNotifier() : super(null);

  Future<void> addBilloflading(
      String billOfLadingNumber,
      String outgoingClearance,
      String incomingClearance,
      String remarks,
      String shippingType,
      String navigationCompany) async {
    final url = Uri.parse(
        'https://alashi.online/backendapi/public/api/addbillofladings');

    try {
      log("🚀 إرسال الطلب إلى السيرفر...");

      final Map<String, dynamic> requestBody = {
        "billOfLading_number": billOfLadingNumber,
        "outgoing_clearance": outgoingClearance,
        "incoming_clearance": incomingClearance,
        "Remarks": remarks.isNotEmpty ? remarks : "لا يوجد",
        "ShippingType": shippingType,
        "Navigation_Company": navigationCompany,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        log("✅  تم اضافة الحاوية بنجاح!");
      } else {
        log("❌ فشل الإضافة: ${response.statusCode} - ${response.body}");
        throw Exception("فشل الإضافة: ${response.body}");
      }
    } catch (e) {
      log("❌ خطأ أثناء الإضافة: $e");
      throw Exception("خطأ أثناء الإضافة: $e");
    }
  }

  Future<void> deleteBilloflading(int id) async {
    final url = Uri.parse(
        'https://alashi.online/backendapi/public/api/billofladings/$id');

    final response = await http.delete(url);

    if (response.statusCode == 200 || response.statusCode == 204) {
      log("Containrs deleted successfully.");
      state = null;
    } else {
      log("Error deleting Containrs: ${response.body}");
      throw Exception("Failed to delete Containrs");
    }
  }

  Future<void> editBilloflading(int cId, String contNumber, String contWeight,
      String contParcelsCount, String contRemarks) async {
    final url = Uri.parse(
        'https://alashi.online/backendapi/public/api/billofladings/$cId');

    try {
      log("🚀 إرسال الطلب لتعديل المنتج...");

      final Map<String, dynamic> requestBody = {
        "cont_number": contNumber,
        "cont_weight": contWeight,
        "cont_parcelsCount": contParcelsCount,
        "contRemarks": contRemarks,
      };

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅  تم تعديل الحاوية بنجاح!");
      } else {
        log("❌ فشل التعديل: ${response.statusCode} - ${response.body}");
        throw Exception("فشل التعديل: ${response.body}");
      }
    } catch (e) {
      log("❌ خطأ أثناء التعديل: $e");
      throw Exception("خطأ أثناء التعديل: $e");
    }
  }
}

final billofladingNotifierProvider =
    StateNotifierProvider<BillofladingNotifier, Billoflading?>((ref) {
  return BillofladingNotifier();
});
