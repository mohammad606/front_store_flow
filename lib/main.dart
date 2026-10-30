import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storeflow/core/api/api_exception.dart';
import 'package:storeflow/core/api/api_response.dart';
import 'package:storeflow/features/auth/data/models/auth_models.dart';
import 'package:storeflow/features/auth/data/services/auth_service.dart';
import 'package:storeflow/features/user/screens/user_home_page.dart';

const Color _primaryBlue = Color(0xFF2563EB);
const Color _secondaryGray = Color(0xFF64748B);

bool hasStoredToken(String? token) {
  return token != null && token.trim().isNotEmpty;
}

bool isUserRole(String? role) {
  return role?.trim().toLowerCase() == 'user';
}

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
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: _primaryBlue),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final role = prefs.getString('user_role') ?? '';

    if (!mounted) return;

    if (hasStoredToken(token) && (role.isEmpty || isUserRole(role))) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserHomePage()),
      );
      return;
    }

    setState(() {
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: _primaryBlue),
        ),
      );
    }

    return const AuthPage();
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(text: 'admin@storeflow.com');
  final _passwordController = TextEditingController(text: '123456');
  final _authService = AuthService();
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  bool _isLoginMode = true;
  bool _isLoading = false;
  String _deviceId = '';
  String _statusMessage = 'مرحبا بك في StoreFlow';

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfoPlugin.androidInfo;
        _deviceId = info.id;
      } else if (Platform.isIOS) {
        final info = await _deviceInfoPlugin.iosInfo;
        _deviceId = info.identifierForVendor ?? '';
      }
    } catch (_) {
      _deviceId = '';
    }

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _submitAuth() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_isLoginMode) {
      if (email.isEmpty || password.isEmpty) {
        setState(() => _statusMessage = 'يرجى إدخال البريد الإلكتروني وكلمة المرور.');
        return;
      }
    } else {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        setState(() => _statusMessage = 'يرجى ملء جميع الحقول المطلوبة.');
        return;
      }
    }

    if (_deviceId.isEmpty) {
      await _loadDeviceId();
    }

    setState(() {
      _isLoading = true;
      _statusMessage = _isLoginMode ? 'جاري تسجيل الدخول...' : 'جاري إنشاء الحساب...';
    });

    try {
      final ApiResponse<AuthResponse> response = _isLoginMode
          ? await _authService.login(
              email: email,
              password: password,
              deviceId: _deviceId,
            )
          : await _authService.register(
              name: name,
              email: email,
              password: password,
              deviceId: _deviceId,
            );

      if (!mounted) return;

      if (response.success) {
        final user = response.data?.user;
        final token = response.data?.auth.token ?? '';

        if (token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setString('user_name', user?.name ?? '');
          await prefs.setString('user_email', user?.email ?? '');
          await prefs.setString('user_role', user?.role ?? '');
        }

        setState(() {
          _isLoading = false;
          _statusMessage = _isLoginMode
              ? 'تم تسجيل الدخول بنجاح \n${user?.name ?? ''}'
              : 'تم إنشاء الحساب بنجاح';
        });

        if (!_isLoginMode) {
          setState(() {
            _isLoginMode = true;
            _nameController.clear();
          });
        }

        if (user != null && isUserRole(user.role)) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserHomePage()),
          );
          return;
        }

        return;
      }

      setState(() {
        _isLoading = false;
        _statusMessage = response.message;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _statusMessage = error.message;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon, color: _secondaryGray),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: _secondaryGray),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: const Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: const Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: _primaryBlue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: _primaryBlue,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'StoreFlow',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'إدارة المخزون',
                  style: TextStyle(
                    color: _secondaryGray,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isLoginMode = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isLoginMode ? _primaryBlue : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'تسجيل الدخول',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _isLoginMode ? Colors.white : _secondaryGray,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isLoginMode = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isLoginMode ? _primaryBlue : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'إنشاء حساب',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !_isLoginMode ? Colors.white : _secondaryGray,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (!_isLoginMode)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildTextField(
                      controller: _nameController,
                      label: 'اسم المستخدم',
                      icon: Icons.person_outline,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildTextField(
                    controller: _emailController,
                    label: 'البريد الإلكتروني',
                    icon: Icons.email_outlined,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildTextField(
                    controller: _passwordController,
                    label: 'كلمة المرور',
                    obscureText: true,
                    icon: Icons.lock_outline,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('جاري الإرسال...'),
                            ],
                          )
                        : Text(
                            _isLoginMode ? 'تسجيل الدخول' : 'إنشاء الحساب',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _secondaryGray,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Device ID: ${_deviceId.isEmpty ? 'جاري التحميل...' : _deviceId}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
