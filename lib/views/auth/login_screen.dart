import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_member_link/myconfig.dart';
import 'package:my_member_link/views/newsletter/news_screen.dart'; // Assuming MainScreen or your target screen
import 'package:my_member_link/views/auth/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  bool rememberme = false;
  bool _obscureText = true;  // Toggle for password visibility

  @override
  void initState() {
    super.initState();
    loadPref();
  }

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
                        hintText: "Your Email")),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  obscureText: _obscureText,
                  controller: passwordcontroller,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      hintText: "Your Password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      )),
                ),
                Row(
                  children: [
                    const Text("Remember me"),
                    Checkbox(
                      value: rememberme,
                      onChanged: (bool? value) {
                        setState(() {
                          String email = emailcontroller.text;
                          String pass = passwordcontroller.text;
                          if (value!) {
                            if (email.isNotEmpty && pass.isNotEmpty) {
                              storeSharedPrefs(value, email, pass);
                            } else {
                              rememberme = false;
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Please enter your credentials"),
                                backgroundColor: Colors.red,
                              ));
                              return;
                            }
                          } else {
                            email = "";
                            pass = "";
                            storeSharedPrefs(value, email, pass);
                          }
                          rememberme = value;
                          setState(() {});
                        });
                      },
                    ),
                  ],
                ),
                MaterialButton(
                    elevation: 10,
                    onPressed: onLogin,
                    minWidth: 400,
                    height: 50,
                    color: Colors.blue[800],
                    child: const Text("Login",
                        style: TextStyle(color: Colors.white))),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  child: const Text("Forgot Password?"),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (content) => const RegisterScreen()));
                  },
                  child: const Text("Create new account?"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onLogin() async {
  String email = emailcontroller.text;
  String password = passwordcontroller.text;

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Please enter email and password"),
      backgroundColor: Colors.red,
    ));
    return;
  }

  try {
    final response = await http.post(
      Uri.parse("${MyConfig.servername}/MyMemberLink/login_user.php"),
      body: {"email": email, "password": password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Login Success"),
          backgroundColor: Colors.green,
        ));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (content) => const MainScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['message'] ?? "Login Failed"),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Server Error. Please try again."),
        backgroundColor: Colors.red,
      ));
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Network Error: $error"),
      backgroundColor: Colors.red,
    ));
  }
}


  Future<void> storeSharedPrefs(bool value, String email, String pass) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      prefs.setString("email", email);
      prefs.setString("password", pass);
      prefs.setBool("rememberme", value);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Preferences Stored"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ));
    } else {
      prefs.setString("email", email);
      prefs.setString("password", pass);
      prefs.setBool("rememberme", value);
      emailcontroller.text = "";
      passwordcontroller.text = "";
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Preferences Removed"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ));
    }
  }

  Future<void> loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    emailcontroller.text = prefs.getString("email") ?? "";
    passwordcontroller.text = prefs.getString("password") ?? "";
    rememberme = prefs.getBool("rememberme") ?? false;
    setState(() {});
  }
}


