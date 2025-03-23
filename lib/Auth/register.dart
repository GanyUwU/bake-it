import 'package:a1/Auth/signin.dart';
import 'package:a1/Home/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();


  RegisterPage({super.key});

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In cancelled')),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in as ${_auth.currentUser?.displayName}')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in: $error')),
      );
    }
  }

  Future<void>_signUp() async{


    try{
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim()
      );
      // 2. Get user from auth result
      final User? user = userCredential.user;
      if (user == null) throw Exception('User creation failed');

      await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set({
        'uid' : user.uid,
        'email': _emailController.text.trim(),
        'password' : _passwordController.text.trim(),
        'name': _nameController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

    } on FirebaseAuthException catch(e){
      print("Error Code: ${e.code}");
      print("Error Message: ${e.message}");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F5F2),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Register',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Join us for effortless and confident baking.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () => _handleGoogleSignIn(context),
                icon: Image.asset(
                  'assets/google.png',
                  height: 10,
                ),
                label: Text('Sign up with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('or', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),
              ),
              TextFormField(
                controller: _nameController,
                validator: (text){
                  if(text == null || text.isEmpty){
                    return 'Name is empty';
                  }
                  return null;
                },
                decoration: InputDecoration(labelText: 'Name'),
              ),

              TextFormField(
                controller: _emailController,
                validator: (text){
                  if(text == null || text.isEmpty){
                    return 'Email is empty';
                  }
                  return null;
                },
                decoration: InputDecoration(labelText: 'Email'),
              ),

              SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                validator: (value){
                  if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                  }
                  if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),

              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
              ),
              SizedBox(height: 12),

              Row(
                children: [
                  Checkbox(value: false, onChanged: (value) {}),
                  Expanded(
                    child: Text(
                      'I agree to the Terms and Conditions',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try{
                    await _signUp();
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));
                  }
                  catch(e){
                    print("Sign in failed: $e");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF555555),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Register'),
              ),

              SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SignIn()));
                },
                child: Text('Already have an account? Login',
                    style: TextStyle(color: Color(0xFF434242))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
