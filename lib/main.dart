import 'package:flutter/material.dart';
import 'package:storeflow/core/api/api_exception.dart';
import 'package:storeflow/core/api/api_response.dart';
import 'package:storeflow/features/auth/data/models/auth_models.dart';
import 'package:storeflow/features/auth/data/services/auth_service.dart';

void main() {
  runApp(const StoreFlowApp());
}

class StoreFlowApp extends StatelessWidget {
  const StoreFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoreFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const AuthDemoPage(),
    );
  }
}

class AuthDemoPage extends StatefulWidget {
  const AuthDemoPage({super.key});

  @override
  State<AuthDemoPage> createState() => _AuthDemoPageState();
}

class _AuthDemoPageState extends State<AuthDemoPage> {
  final emailController = TextEditingController(text: 'h@gmail.com');
  final passwordController = TextEditingController(text: '123456');
  final authService = AuthService();

  bool isLoading = false;
  String resultText = 'جاهز لتسجيل الدخول';

  Future<void> login() async {
    setState(() {
      isLoading = true;
      resultText = 'جاري إرسال الطلب...';
    });

    try {
      final ApiResponse<AuthResponse> response = await authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
        resultText = response.success
            ? 'نجح تسجيل الدخول\n${response.data?.user.name}\nToken: ${response.data?.auth.token}'
            : response.message;
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        resultText = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StoreFlow Login Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : login,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('تسجيل الدخول'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              resultText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
