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
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

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
                  controller: emailcontroller,
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
                  obscureText: true,
                  controller: passwordcontroller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    hintText: "Your Password",
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
    String email = emailcontroller.text;
    String password = passwordcontroller.text;
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
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text("Register new account?", style: TextStyle()),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text("Yes", style: TextStyle()),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog first
                userRegistration();
              },
            ),
            TextButton(
              child: const Text("No", style: TextStyle()),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> userRegistration() async {
    String email = emailcontroller.text;
    String pass = passwordcontroller.text;

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/MyMemberLink/register_user.php"),
        body: {"email": email, "password": pass},
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}"); // Print raw response for debugging

      // Check if the response is valid JSON
      if (response.statusCode == 200) {
        try {
          var data = jsonDecode(response.body); // Decode the JSON response
          print('Decoded JSON: $data'); // Print decoded data to check

          if (data['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Registration Success"),
              backgroundColor: Color.fromARGB(255, 12, 12, 12),
            ));
            // Clear the input fields
            emailcontroller.clear();
            passwordcontroller.clear();
          } else if (data['status'] == 'email_exists') {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Email already in use"),
              backgroundColor: Colors.red,
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Registration Failed"),
              backgroundColor: Colors.red,
            ));
          }
        } catch (e) {
          print("Error parsing response: $e"); // Log parsing error
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Error parsing response"),
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
        content: Text("Error: ${e.toString()}"),
        backgroundColor: Colors.red,
      ));
    }
  }
}
