import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthController();
  bool _loading = false;

  void _msg(String s) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.signIn(_email.text, _password.text);
    } on FirebaseAuthException catch (e) {
      _msg('เข้าสู่ระบบไม่สำเร็จ: ${e.message}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _seed() async {
    setState(() => _loading = true);
    try {
      await _auth.seedTestAccounts();
      _msg('สร้างบัญชีทดสอบแล้ว (รหัสผ่าน ${AuthController.testPassword})');
    } catch (e) {
      _msg('สร้างบัญชีไม่สำเร็จ: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fill(String email) {
    _email.text = email;
    _password.text = AuthController.testPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.build_circle, size: 80, color: Color(0xFF0D47A1)),
                  const SizedBox(height: 8),
                  Text('PredictIQ',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const Text('Predictive Maintenance & Vibration Diagnostic'),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        labelText: 'อีเมล', border: OutlineInputBorder()),
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'กรุณากรอกอีเมล'),
                      EmailValidator(errorText: 'รูปแบบอีเมลไม่ถูกต้อง'),
                    ]).call,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'รหัสผ่าน', border: OutlineInputBorder()),
                    validator: RequiredValidator(errorText: 'กรุณากรอกรหัสผ่าน').call,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('เข้าสู่ระบบ'),
                    ),
                  ),
                  const Divider(height: 32),
                  const Text('บัญชีทดสอบ'),
                  Wrap(spacing: 8, children: [
                    ActionChip(
                        label: const Text('Admin'),
                        onPressed: () => _fill('admin@test.com')),
                    ActionChip(
                        label: const Text('Operator'),
                        onPressed: () => _fill('operator@test.com')),
                  ]),
                  TextButton(
                    onPressed: _loading ? null : _seed,
                    child: const Text('สร้างบัญชีทดสอบ (ทำครั้งแรกครั้งเดียว)'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
