
import 'package:a1/Auth/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Home/home.dart';


class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> with ChangeNotifier {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  signInWithEmailAndPassword() async{
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text,
          password: _password.text
      );
    }
    on FirebaseAuthException catch(e){
      if (e.code == 'user-not-found') {
        return showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              content: Text('No existing user found'),
            );
          },
        );

      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content:
          Text("Wrong password provided for that user.")
          ),
        );
      }
      else{
        return ("correctly signed in");
      }
    }
  }

  
// Future<void> googleLogin(BuildContext context) async {
//   try {
//     // Start the sign-in process
//     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//     if (googleUser == null) {
//       // The user canceled the sign-in
//       return;
//     }
//
//     final GoogleSignInAuthentication googleAuth =
//         await googleUser.authentication;
//
//     // Create a credential using the token
//     final AuthCredential credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );
//
//     // Sign in with the credential
//     final UserCredential userCredential =
//         await _auth.signInWithCredential(credential);
//     User? user = userCredential.user;
//
//     if (user != null) {
//       // Store user data in Firestore under the "users" collection
//       final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
//       await userDoc.set({
//         'displayName': user.displayName,
//         'email': user.email,
//         'photoURL': user.photoURL,
//         'lastSignIn': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true)); // merge true ensures existing data isn't overwritten
//
//       // Navigate to the next page, for example, HomePage
//       Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
//     }
//   } catch (e) {
//     print("Google sign-in error: $e");
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error signing in: $e')),
//     );
//   }
// }
  Future<UserCredential?> googleLogin()async{
    try{
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;

      final cred = GoogleAuthProvider.credential(
          idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken
      );
      return await _auth.signInWithCredential(cred);
    } catch(e){
      print(e.toString());
    }
    return null;

  }


  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // Soft beige background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text("Login",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 2)),
                ],
              ),

              // child:Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Image.asset('assets/google.png', height: 20), // Google logo
              //     SizedBox(width: 10),
              //     Text("Sign in with Google", style: TextStyle(fontSize: 16)),
              //   ],
              // ),
              child: GestureDetector(
                      onTap: () async {
                          // Call your googleLogin function here.
                          await googleLogin();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white, // or any color that fits your design
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/google.png', height: 20), // Google logo
                              SizedBox(width: 10),
                              Text("Sign in with Google", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),             
            ),

            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.grey,  // Line color
                    thickness: 1.2,      // Line thickness
                    indent: 20,          // Space from the left
                    endIndent: 10,       // Space before text
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("or", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1.2,
                    indent: 10,         // Space after text
                    endIndent: 20,      // Space from the right
                  ),
                ),
              ],
            ),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 2)),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Email",
                ),
              ),
            ),


            Container(
              margin: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 2)),
                ],
              ),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Type your password",
                  suffixIcon: Icon(Icons.visibility_off),
                ),
              ),
            ),

            Row(

              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Checkbox(value: true, onChanged: (value) {}),
                    Text("Remember me"),
                  ],
                ),
                Text("Forgot Password?", style: TextStyle(color: Colors.black)),
              ],
            ),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade700, Colors.grey.shade400],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 2)),
                ],
              ),
              child: Center(
                child: TextButton(
                  onPressed: (){
                    if(_formKey.currentState !.validate()){
                      signInWithEmailAndPassword();
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>Home()));
                    }
                  },
                  child: Text("Login",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            Text("Don't have an account?"),
            TextButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AuthPage()));
              },
                child: Text("Sign Up")
            )
          ],
        ),
      ),

    );

  }
}


