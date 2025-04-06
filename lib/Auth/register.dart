import 'package:a1/Auth/signin.dart';
import 'package:a1/Home/home.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final User? user = userCredential.user;
        if (user == null) throw Exception('User creation failed');

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': _emailController.text.trim(),
          'name': _nameController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Navigate to home page on successful registration
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    } else if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$').hasMatch(value)) {
      return 'Password must include at least 1 uppercase letter, 1 number, and 1 special character';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Theme colors
    const Color primaryColor = Color(0xFF2F2F2F);
    const Color backgroundColor = Color(0xFF2C2C2C);
    const Color surfaceColor = Color(0xFF1E1E1E);
    const Color accentColor = Color(0xFFE0E0E0);
    const Color textColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          'Create Account',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontFamily: "Sanfrans",
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: "Sanfrans",
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!RegExp(r'^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+').hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: accentColor.withAlpha(176)),
                      prefixIcon: Icon(Icons.lock_outline, color: accentColor.withAlpha(176)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: accentColor.withAlpha(176),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 30),
                  _buildPasswordRequirements(),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: primaryColor)
                          : Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Sanfrans",
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Navigate to login page
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context)=>SignIn()));
                      },
                      child: Text(
                        'Already have an account? Log In',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Sanfrans",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFFE0E0E0).withAlpha(176)),
        prefixIcon: Icon(prefixIcon, color: Color(0xFFE0E0E0).withAlpha(176)),
        filled: true,
        fillColor: Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordRequirements() {
    const Color requirementColor = Color(0xFFAAAAAA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password requirements:',
          style: TextStyle(
            color: requirementColor,
            fontSize: 12,
            fontFamily: "Sanfrans",
          ),
        ),
        const SizedBox(height: 8),
        _buildRequirementText('At least 6 characters'),
        _buildRequirementText('At least one uppercase letter (A-Z)'),
        _buildRequirementText('At least one number (0-9)'),
        _buildRequirementText('At least one special character (@\$!%*?&)'),
      ],
    );
  }

  Widget _buildRequirementText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Color(0xFFAAAAAA),
            size: 14,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 12,
              fontFamily: "Sanfrans",
            ),
          ),
        ],
      ),
    );
  }
}