import 'package:chatt_app/Screen/Chat/chat_page.dart';
import 'package:chatt_app/Screen/Login/LoginScreen.dart';
import 'package:chatt_app/Screen/Services/auth.dart';
import 'package:chatt_app/Widget/button.dart';
import 'package:chatt_app/Widget/snack_bar.dart';
import 'package:chatt_app/Widget/textFeild.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> signUpUser() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    String res = await AuthServices().signUpUser(
      email: emailController.text,
      password: passController.text,
      name: nameController.text,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (res == "User registered successfully") {
      String recipientId = await AuthServices().getUserId();
      String recipientName = await AuthServices().getUserName();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            recipientId: recipientId,
            recipientName: recipientName,
          ),
        ),
      );
    } else {
      showSnackBar(context, res);
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
                child: Image.asset("images/6333040.jpg"),
              ),
              TextFeildInput(
                textEditingController: nameController,
                hintText: "Enter Your name",
                icon: Icons.person,
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
              if (isLoading) CircularProgressIndicator(),
              MyButton(onTab: signUpUser, text: "Sign Up"),
              SizedBox(height: height / 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: const Text(
                      " Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
