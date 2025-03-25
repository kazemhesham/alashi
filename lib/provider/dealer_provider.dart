import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../model/dealer_model.dart';

class DealersService {
  Future<Dealers> getDealer() async {
    final urlpro = Uri.parse(
      'https://alashi.online/backendapi/public/api/dealers',
    );
    final response = await http.get(urlpro);

    if (response.statusCode == 200) {
      final Map<String, dynamic> dataDealer = jsonDecode(response.body);
      return Dealers.fromJson(dataDealer);
    } else {
      throw ('error: ${response.body}');
    }
  }
}

final dealersServiceProvider = Provider<DealersService>((ref) {
  return DealersService();
});

final dealersListProvider = FutureProvider<Dealers>((ref) async {
  final dealersService = DealersService();
  return await dealersService.getDealer();
});

class DealerNotifier extends StateNotifier<Dealer1?> {
  DealerNotifier() : super(null);
  Future<void> addDealer(
    String name,
    String phone,
    String email,
    String adress,
    DealerLang dealerLang,
  ) async {
    final urllogin = Uri.parse(
      'https://alashi.online/backendapi/public/api/adddealer',
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
          'dealer_lang': dealerLangValues.reverse[dealerLang],
        }),
      );
      print("Converted dealer_lang: ${dealerLangValues.reverse[dealerLang]}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log("Dealer added successfully: ${data['dealer']}");
        if (data['dealer'] != null) {
          state = Dealer1.fromJson(data['dealer']);
          log(
            'Dealer Number Type: ${data['dealer']['dealer_Number'].runtimeType}',
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

  Future<void> deletDealer(int id) async {
    final urllogin = Uri.parse(
      'https://alashi.online/backendapi/public/api/dealers/$id',
    );
    try {
      final response = await http.delete(urllogin);

      if (response.statusCode == 200 || response.statusCode == 204) {
        log("Dealer deleted successfully.");
      } else {
        log("Deletion failed: ${response.body}");
        throw Exception("Failed to delete dealer");
      }
    } catch (e) {
      log("Exception: $e");
      throw Exception("Error occurred while deleting dealer");
    }
  }

  Future<void> editDealer(
    int id,
    String name,
    String phone,
    String email,
    String adress,
    DealerLang dealerLang,
  ) async {
    final urllogin = Uri.parse(
      'https://alashi.online/backendapi/public/api/dealers/$id',
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
          'dealer_lang': dealerLangValues.reverse[dealerLang],
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        log("Dealer update successfully: ${data['success']}");
        if (data['data'] != null) {
          state = Dealer1.fromJson(data['data']);
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

  Future<Dealer1> getEditDealer(int id) async {
    final urllogin = Uri.parse(
      'https://alashi.online/backendapi/public/api/dealers/$id/edit',
    );
    final response = await http.get(urllogin);

    if (response.statusCode == 200) {
      final Map<String, dynamic> dataDealer = jsonDecode(response.body);

      // تحقق من وجود بيانات التاجر مباشرة
      if (dataDealer['dealer'] != null) {
        return Dealer1.fromJson(dataDealer['dealer']);
      } else if (dataDealer['data'] != null) {
        return Dealer1.fromJson(dataDealer['data']);
      } else {
        throw Exception('لا يوجد بيانات للتاجر');
      }
    } else {
      throw Exception('فشل في جلب البيانات: ${response.statusCode}');
    }
  }
}

final dealerProvider = StateNotifierProvider<DealerNotifier, Dealer1?>((ref) {
  return DealerNotifier();
});
