
import 'package:a1/Home/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:a1/Auth/register.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  //final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscureText = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> signInWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _email.text.trim(),
            password: _password.text.trim()
        );

        if (!mounted) return;
        // Navigate to home page on successful login
        Navigator.push(
          context, MaterialPageRoute(builder: (context)=>Home())
        );
      } on FirebaseAuthException catch(e) {
        String errorMessage;

        if (e.code == 'user-not-found') {
          errorMessage = 'No user found with this email';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided for this user';
        } else {
          errorMessage = e.message ?? 'An unknown error occurred';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
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

  Future<void> googleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign-in flow
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Navigate to home page on successful login
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing in with Google: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme colors based on your registration page
    const Color backgroundColor = Color(0xFF2C2C2C);
    const Color surfaceColor = Color(0xFF1E1E1E);
    const Color primaryColor = Color(0xFF2F2F2F);
    const Color accentColor = Color(0xFFE0E0E0);
    const Color textColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 60),
                  // Title Section - Similar to the cooking app image
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome",
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: "Sanfrans",
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        "Back",
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: "Sanfrans",
                          fontWeight: FontWeight.bold,
                          color: accentColor.withAlpha(128),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Sign in to continue using the app",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Sanfrans",
                          color: accentColor.withAlpha(176),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 60),

                  // Google Sign In Button
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: _isLoading ? null : googleLogin,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/google.png', height: 24),
                          SizedBox(width: 12),
                          Text(
                            "Sign in with Google",
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                              fontFamily: "Sanfrans",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Divider with "or" text
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: accentColor.withAlpha(76),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "or",
                          style: TextStyle(
                            color: accentColor.withAlpha(176),
                            fontSize: 14,
                            fontFamily: "Sanfrans",
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: accentColor.withAlpha(77),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Email Field
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: accentColor.withAlpha(176)),
                      prefixIcon: Icon(Icons.email_outlined, color: accentColor.withAlpha(176)),
                      filled: true,
                      fillColor: surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!RegExp(r'^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+').hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _password,
                    obscureText: _obscureText,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: accentColor.withAlpha(176)),
                      prefixIcon: Icon(Icons.lock_outline, color: accentColor.withAlpha(176)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: accentColor.withAlpha(176),
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                      filled: true,
                      fillColor: surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Remember Me and Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? true;
                                });
                              },
                              activeColor: accentColor,
                              checkColor: primaryColor,
                              side: BorderSide(color: accentColor.withAlpha(128)),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Remember me",
                            style: TextStyle(
                              color: accentColor.withAlpha(230),
                              fontSize: 14,
                              fontFamily: "Sanfrans",
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // Handle forgot password
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Sanfrans",
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),

                  // Login Button - Similar to the cooking app "Get Started" button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : signInWithEmailAndPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        "Get Started",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Sanfrans",
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: accentColor.withAlpha(176),
                          fontSize: 14,
                          fontFamily: "Sanfrans",
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AuthPage()));
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Sanfrans",
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}