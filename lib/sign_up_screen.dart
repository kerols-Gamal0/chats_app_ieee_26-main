import 'package:chats_app/whatsapp_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  const Icon(
                    Icons.group_add,
                    size: 80,
                    color: Color(0xFF075E54),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Create account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF075E54),
                    ),
                  ),
                  const SizedBox(height: 120),

                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "your Name",
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter team name' : null,
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Your Email",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter email' : null,
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF075E54),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .createUserWithEmailAndPassword(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              );
                          String uid = userCredential.user!.uid;
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .set({
                                'email': emailController.text.trim(),
                                'name': nameController.text.trim(),
                                'uid': uid,
                              });
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => WhatsAppHome(),
                            ),
                          );
                        }
                      },
                      child: const Text("Sign Up"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Color(0xFF075E54),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
