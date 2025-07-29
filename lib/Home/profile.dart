import 'package:a1/Home/URL_display.dart';
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
  List<Map<String, dynamic>> scrapedRecipes = [];
  Future<void> _fetchScrapedRecipes() async {
    if (user == null) return;
    
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('recipes')
        .orderBy('timestamp', descending: true)
        .limit(3)
        .get();

    setState(() {
      scrapedRecipes = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Untitled Recipe',
          'url': data['url'] ?? '',
          'ingredients': List<Map<String, dynamic>>.from(data['ingredients'] ?? []),
        };
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchScrapedRecipes(); // <-- Add this line
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
            if(scrapedRecipes.isEmpty)
                    Text("No recipes scraped yet", style: TextStyle(color: Colors.grey)),

                    ...scrapedRecipes.map((recipe) => 
                    _buildRecipeCard(
                      recipe['title'],
                      recipe['ingredients'],
                      recipeId: recipe['id']
                    )
                    ),

            SizedBox(height: 20),

            // Settings Options
            _buildSettingsOption(Icons.edit, "Edit Profile"),
            _buildSettingsOption(Icons.logout, "Log Out", isLogout: true),
          ],
        ),
      ),
    );
  }
Widget _buildRecipeCard(String title, List<dynamic> ingredients, {required String recipeId}) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(Icons.link, color: Colors.blue),
        title: Text(title),
        subtitle: Text("${ingredients.length} ingredients"),
        onTap: () => _navigateToRecipe(ingredients, title),
      ),
    );
  }
void _navigateToRecipe(List<dynamic> ingredients, String title) {
    final recipe = Recipe(
      title: title,
      ingredients: ingredients.map((ing) => Ingredient(
        name: ing['ingredient'],
        amount: ing['quantity'],
        iconColor: Color(ing['iconColor'] ?? 0xFF9E9E9E), // Default to grey if missing
      )).toList(),
    );
    
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => RecipeDetailView(recipe: recipe)
    ));
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

