import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_member_link/myconfig.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/login.png'),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    hintText: "Your Email",
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  obscureText: isPasswordHidden,
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    hintText: "Your Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordHidden = !isPasswordHidden;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                MaterialButton(
                  elevation: 10,
                  onPressed: onRegisterDialog,
                  minWidth: 400,
                  height: 50,
                  color: Colors.blue[800],
                  child: const Text(
                    "Register",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Already registered? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onRegisterDialog() {
    String email = emailController.text;
    String password = passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter email and password"),
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          title: const Text("Register new account?"),
          content: const Text("Are you sure?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog first
                userRegistration();
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
                clearFields(); // Clear fields even when registration is canceled
              },
            ),
          ],
        );
      },
    );
  }

  void userRegistration() async {
    String email = emailController.text;
    String pass = passwordController.text;

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/MyMemberLink/register_user.php"),
        body: {"email": email, "password": pass},
        headers: {"Content-Type": "application/x-www-form-urlencoded"}, // Ensure correct headers
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Registration Successful"),
            backgroundColor: Colors.green,
          ));
          clearFields(); // Clear fields after success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Registration Failed: ${data['message']}"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Server Error"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
    setState(() {}); // Ensure UI is updated
  }
}
