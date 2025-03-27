import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  RecipeDetailScreen({required this.recipeId});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final String apiKey = '1c266f8a0eb84f7d8888e73fc2141053';
  Map<String, dynamic>? recipeDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
  }

  Future<void> fetchRecipeDetails() async {
    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/${widget.recipeId}/information?apiKey=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          recipeDetails = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load recipe details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipeDetails?['title'] ?? 'Recipe Details'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : recipeDetails == null
              ? Center(child: Text("Failed to load recipe details"))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe Image
                      ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(20)),
                        child: Image.network(
                          recipeDetails!['image'] ??
                              'https://via.placeholder.com/400',
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Recipe Title
                            Text(
                              recipeDetails!['title'] ?? 'No Title',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),

                            // Cooking Info (Time & Servings)
                            Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.green),
                                SizedBox(width: 5),
                                Text(
                                  "${recipeDetails!['readyInMinutes']} min",
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(width: 20),
                                Icon(Icons.restaurant, color: Colors.green),
                                SizedBox(width: 5),
                                Text(
                                  "${recipeDetails!['servings']} servings",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),

                            SizedBox(height: 20),

                            // Ingredients Section
                            Text(
                              "Ingredients",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Divider(color: Colors.green),
                            SizedBox(height: 10),

                            // List of Ingredients
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount:
                                  recipeDetails!['extendedIngredients'].length,
                              itemBuilder: (context, index) {
                                final ingredient =
                                    recipeDetails!['extendedIngredients']
                                        [index];
                                return ListTile(
                                  leading: Icon(Icons.check_circle,
                                      color: Colors.green),
                                  title: Text(ingredient['original']),
                                );
                              },
                            ),

                            SizedBox(height: 20),

                            // Instructions Section
                            Text(
                              "Instructions",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Divider(color: Colors.green),
                            SizedBox(height: 10),

                            // Recipe Instructions
                            Text(
                              recipeDetails!['instructions'] ??
                                  'No instructions available',
                              style: TextStyle(fontSize: 16, height: 1.5),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
