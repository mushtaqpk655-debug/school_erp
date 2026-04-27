import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  bool _isLoading = false;

  // --- NEW: FORGOT PASSWORD DIALOG ---
  void _showForgotPasswordDialog() {
    final TextEditingController _resetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter your registered email to receive a password reset link."),
            const SizedBox(height: 15),
            TextField(
              controller: _resetController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email Address",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
            onPressed: () async {
              String email = _resetController.text.trim();
              if (email.isNotEmpty) {
                try {
                  await _db.sendPasswordReset(email);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Reset link sent! Please check your inbox (and spam)."),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text("Send Link", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Login", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Welcome to School ERP", style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        _buildInputField(
                          controller: _emailController,
                          hint: "Email Address",
                          icon: Icons.person,
                          isPassword: false,
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          controller: _passwordController,
                          hint: "Password",
                          icon: Icons.lock,
                          isPassword: true,
                        ),
                        const SizedBox(height: 40),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : _buildLoginButton(),
                        const SizedBox(height: 20),
                        // --- UPDATED: FORGOT PASSWORD BUTTON ---
                        TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String hint, required IconData icon, required bool isPassword}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(32, 132, 232, .3), blurRadius: 20, offset: Offset(0, 10))
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          icon: Icon(icon, color: Colors.blue),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return MaterialButton(
      onPressed: () async {
        String email = _emailController.text.trim();
        String password = _passwordController.text.trim();

        if (email.isEmpty || password.isEmpty) {
          _showError("Please enter both email and password");
          return;
        }

        setState(() => _isLoading = true);

        var user = await _db.signIn(email, password);

        if (user != null) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          setState(() => _isLoading = false);
          _showError("Invalid email or password. Please try again.");
        }
      },
      height: 50,
      minWidth: double.infinity,
      color: Colors.blue[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      child: const Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}