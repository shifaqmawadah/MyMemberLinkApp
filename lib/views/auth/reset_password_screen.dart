import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_member_link/myconfig.dart'; // MyConfig file for the server name

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController otpController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  void resetPassword() {
    String otp = otpController.text;
    String newPassword = newPasswordController.text;

    if (otp.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter OTP and new password."),
      ));
      return;
    }

    // Call the server to verify OTP and reset password
    http.post(Uri.parse("${MyConfig.servername}/MyMemberLink/reset_password.php"),
        body: {
          "email": widget.email,
          "otp": otp,
          "new_password": newPassword,
        }).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Password reset successfully."),
            backgroundColor: Colors.green,
          ));
          Navigator.pop(context); // Go back to the login screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Invalid OTP. Please try again."),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Enter the OTP sent to your email:"),
              const SizedBox(height: 20),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "OTP",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Enter your new password:"),
              const SizedBox(height: 20),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "New Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: resetPassword, // Reset password when clicked
                child: const Text("Reset Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
