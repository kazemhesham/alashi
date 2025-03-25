import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null);

  String? _token; // لتخزين التوكن بعد تسجيل الدخول

  Future<void> loginUser(String email, String password) async {
    final urllogin =
        Uri.parse('https://alashi.online/backendapi/public/api/login');
    try {
      final response = await http.post(
        urllogin,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log("Login successful: $data");

        if (data['user'] != null && data['token'] != null) {
          _token = data['token']; // حفظ التوكن لاستخدامه لاحقًا
          state = UserModel.fromJson(data); // تحديث حالة المستخدم
        }
      } else {
        log("Login failed: ${response.body}");
        state = null;
      }
    } catch (e) {
      log("Exception: $e");
      state = null;
    }
  }

  Future<void> logoutUser() async {
    if (_token == null) return;

    final urlLogout =
        Uri.parse('https://alashi.online/backendapi/public/api/logout');
    try {
      final response = await http.post(
        urlLogout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token', // إرسال التوكن
        },
      );

      if (response.statusCode == 200) {
        log("Logout successful");
        _token = null;
        state = null;
      } else {
        log("Logout failed: ${response.body}");
      }
    } catch (e) {
      log("Exception: $e");
      state = null;
    }
  }

  Future<List<User>> getUsers() async {
    if (_token == null) throw Exception("User not authenticated");

    final urlUser =
        Uri.parse('https://alashi.online/backendapi/public/api/users');
    final res = await http.get(
      urlUser,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (res.statusCode == 200) {
      final List dataUser = jsonDecode(res.body);
      return dataUser.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Error: ${res.body}');
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});
