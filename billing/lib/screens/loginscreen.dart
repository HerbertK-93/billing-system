import 'package:flutter/material.dart';
import 'forgotpasswordscreen.dart';
import 'signupscreen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get the screen size

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500, // Maximum width for the login card
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo-like heading
                const Text(
                  "INNOVATION CONSORTIUM BILLING",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),

                // Email Text Field
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password Text Field
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to Forgot Password Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen()),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Color.fromARGB(255, 241, 4, 4),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Login Button
                ElevatedButton(
                  onPressed: () {
                    // Implement login logic here
                    print("Logging in with ${emailController.text}");
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // Red color for login button
                  ),
                  child: const Text(
                    "Log In",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 16),

                // Don't Have an Account
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to Signup Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: "Do not have an account? ",
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: "Create one",
                            style: TextStyle(
                              color: Color.fromARGB(255, 157, 182, 15),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
