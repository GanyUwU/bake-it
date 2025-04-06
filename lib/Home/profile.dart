import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser; // Get current user
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator()) // Loading indicator
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundImage: userData?['profilePic'] != null
                  ? NetworkImage(userData!['profilePic']) // Firebase Storage URL
                  : AssetImage('assets/user.png') as ImageProvider,
              backgroundColor: Colors.white,
            ),
            SizedBox(height: 10),

            // User Info
            Text(
              userData?['name'] ?? "User Name",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Text(
              userData?['email'] ?? "user@example.com",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),

            // Saved Recipes Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Saved Recipes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            SizedBox(height: 10),
            _buildRecipeCard("Chocolate Cake"),
            _buildRecipeCard("Blueberry Muffins"),
            _buildRecipeCard("Vanilla Cookies"),

            SizedBox(height: 20),

            // Settings Options
            _buildSettingsOption(Icons.edit, "Edit Profile"),
            _buildSettingsOption(Icons.logout, "Log Out", isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(String recipeName) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.restaurant, color: Colors.grey[700]),
        title: Text(recipeName, style: TextStyle(color: Colors.black)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // Navigate to recipe details
        },
      ),
    );
  }

  Widget _buildSettingsOption(IconData icon, String title, {bool isLogout = false}) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : Colors.grey[700]),
        title: Text(title, style: TextStyle(color: isLogout ? Colors.red : Colors.black)),
        onTap: () {
          if (isLogout) {
            FirebaseAuth.instance.signOut();
            Navigator.pop(context); // Navigate back to login screen
          }
        },
      ),
    );
  }
}
