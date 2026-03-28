import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final AuthService authService = AuthService();

  void resetPassword() async {
    await authService.forgotPassword(emailController.text);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reset link sent to email")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Enter Email")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: resetPassword, child: const Text("Reset Password"))
          ],
        ),
      ),
    );
  }
}

