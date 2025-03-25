import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../model/containrs_model.dart';

class ContainrsService {
  Future<AllContainer> getContainrs() async {
    final url =
        Uri.parse('https://alashi.online/backendapi/public/api/containers');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AllContainer.fromJson(data);
    } else {
      throw Exception('Error fetching Containrs: ${response.body}');
    }
  }
}

final containrsServiceProvider = Provider<ContainrsService>((ref) {
  return ContainrsService();
});

final containrsListProvider = FutureProvider<AllContainer>((ref) async {
  final containrsService = ref.watch(containrsServiceProvider);
  return await containrsService.getContainrs();
});

class ContainrsNotifier extends StateNotifier<Containrs?> {
  ContainrsNotifier() : super(null);

  Future<void> addContainrs(
    String contNumber,
    String contWeight,
    String contParcelsCount,
    String contRemarks,
  ) async {
    final url =
        Uri.parse('https://alashi.online/backendapi/public/api/addcontainer');

    try {
      log("🚀 إرسال الطلب إلى السيرفر...");

      final Map<String, dynamic> requestBody = {
        "cont_number": contNumber,
        "cont_weight": contWeight,
        "cont_parcelsCount": contParcelsCount,
        "contRemarks": contRemarks.isNotEmpty ? contRemarks : "لا يوجد",
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

  Future<void> deleteContainrs(int id) async {
    final url =
        Uri.parse('https://alashi.online/backendapi/public/api/containers/$id');

    final response = await http.delete(url);

    if (response.statusCode == 200 || response.statusCode == 204) {
      log("Containrs deleted successfully.");
      state = null;
    } else {
      log("Error deleting Containrs: ${response.body}");
      throw Exception("Failed to delete Containrs");
    }
  }

  Future<void> editContainrs(int cId, String contNumber, String contWeight,
      String contParcelsCount, String contRemarks) async {
    final url = Uri.parse(
        'https://alashi.online/backendapi/public/api/containers/$cId');

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

final containrNotifierProvider =
    StateNotifierProvider<ContainrsNotifier, Containrs?>((ref) {
  return ContainrsNotifier();
});
