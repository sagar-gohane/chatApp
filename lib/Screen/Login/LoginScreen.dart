import 'package:chatt_app/Screen/Chat/UserListPage.dart';
import 'package:chatt_app/Screen/Chat/chat_page.dart';
import 'package:chatt_app/Screen/Login/signUp.dart';
import 'package:chatt_app/Screen/Services/auth.dart';

import 'package:chatt_app/Widget/button.dart';
import 'package:chatt_app/Widget/snack_bar.dart';
import 'package:chatt_app/Widget/textFeild.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  void loginUser() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> res = await AuthServices().loginUser(
      email: emailController.text,
      password: passController.text,
    );

    if (res['status'] == "Successfully logged in") {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => UserListPage(),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, res['status']);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: height / 2.7,
                width: double.infinity,
                child: Image.asset("images/5098293.jpg"),
              ),
              TextFeildInput(
                textEditingController: emailController,
                hintText: "Enter Email",
                icon: Icons.email,
              ),
              TextFeildInput(
                textEditingController: passController,
                hintText: "Enter Password",
                icon: Icons.lock,
                isPass: true,
              ),
              MyButton(onTab: loginUser, text: "Log In"),
              SizedBox(
                height: height / 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "SignUp",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
