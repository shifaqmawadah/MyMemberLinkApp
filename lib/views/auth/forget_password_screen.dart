import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_member_link/myconfig.dart'; // MyConfig file for the server name
import 'package:my_member_link/views/auth/reset_password_screen.dart'; // Import the reset password screen

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailController = TextEditingController();

  void sendOTP() {
    String email = emailController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter your email address."),
      ));
      return;
    }

    // Send OTP request to the backend
    http.post(Uri.parse("${MyConfig.servername}/MyMemberLink/send_otp.php"),
        body: {"email": email}).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("OTP sent to your email."),
            backgroundColor: Colors.green,
          ));
          // Navigate to OTP verification screen
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ResetPasswordScreen(email: email)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed to send OTP. Please try again."),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error occurred. Please try again later."),
          backgroundColor: Colors.red,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Enter your email to reset your password:"),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "Your Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: sendOTP, // Send OTP when clicked
                child: const Text("Send OTP"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

