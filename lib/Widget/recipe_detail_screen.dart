import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map<String, dynamic>? recipeDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
  }

  Future<void> fetchRecipeDetails() async {
    final url = Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${widget.recipeId}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> meals = data['meals'];
        if (meals != null && meals.isNotEmpty) {
          setState(() {
            recipeDetails = meals[0];
            isLoading = false;
          });
        } else {
          throw Exception('No recipe details found');
        }
      } else {
        throw Exception('Failed to load recipe details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipeDetails?['strMeal'] ?? 'Recipe Details'),
        backgroundColor: Color(0xff9E9E9E),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : recipeDetails == null
              ? Center(child: Text("Failed to load recipe details"))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(20)),
                        child: Image.network(
                          recipeDetails!['strMealThumb'] ??
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
                            Text(
                              recipeDetails!['strMeal'] ?? 'No Title',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Category: ${recipeDetails!['strCategory']}",
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Ingredients",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Divider(color: Colors.green),
                            SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: 20,
                              itemBuilder: (context, index) {
                                final ingredient =
                                    recipeDetails!['strIngredient${index + 1}'];
                                final measure =
                                    recipeDetails!['strMeasure${index + 1}'];
                                if (ingredient != null &&
                                    ingredient.isNotEmpty) {
                                  return ListTile(
                                    leading: Icon(Icons.check_circle,
                                        color: Color(0xff9E9E9E)),
                                    title: Text("$measure $ingredient"),
                                  );
                                }
                                return SizedBox.shrink();
                              },
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Instructions",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Divider(color: Color(0xff9E9E9E)),
                            SizedBox(height: 10),
                            Text(
                              recipeDetails!['strInstructions'] ??
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
