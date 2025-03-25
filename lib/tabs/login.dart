import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/user_provider.dart';
import '../screen/dashbord.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool passvisibal = true; // حالة لإظهار وإخفاء كلمة المرور

  @override
  Widget build(BuildContext context) {
    var bl = const Color.fromARGB(234, 10, 127, 245);

    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('تسجيل الدخول'))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.only(
                    top: 30, left: 20, right: 20, bottom: 20),
                child: Image.asset('assets/Logo.png'),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 1),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25))),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: bl),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25))),
                      prefixIcon: const Icon(Icons.email),
                      hintText: "البريد الالكتروني",
                      hintStyle:
                          Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 18),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 1500),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25))
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2, color: bl),borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(25),
                              bottomRight: Radius.circular(25)),gapPadding: 4.0
                      ),border: InputBorder.none,
                      prefixIcon: const Icon(Icons.key_outlined),
                      hintText: "كلمة المرور",
                      hintStyle:
                          Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 18),
                      suffixIcon: IconButton(
                        icon: Icon(passvisibal
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            passvisibal = !passvisibal;
                          }); // إعادة بناء واجهة المستخدم عند تغيير الحالة
                        },
                      ),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: passvisibal,
                    controller: _passwordController,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              FadeInUp(
                duration: const Duration(milliseconds: 1600),
                child: MaterialButton(
                  height: 50,
                  minWidth: 200,
                  color: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  onPressed: () async {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();

                    await ref
                        .read(userProvider.notifier)
                        .loginUser(email, password);

                    if (ref.read(userProvider) != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DashbordPage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login failed')),
                      );
                    }
                  },
                  child: Text(
                    "تسجيل الدخول",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
