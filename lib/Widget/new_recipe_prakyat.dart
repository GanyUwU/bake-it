import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'recipe_detail_screen.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> filteredRecipes = [];
  int displayedRecipes = 8;
  bool isLoading = false;
  Set<int> likedRecipes = {};

  @override
  void initState() {
    super.initState();
    fetchRecipes();
    searchController.addListener(_onSearchChanged);
  }

  Future<void> fetchRecipes({String? query}) async {
    setState(() {
      isLoading = true;
    });

    final url = query == null || query.isEmpty
        ? Uri.parse(
            'https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert')
        : Uri.parse(
            'https://www.themealdb.com/api/json/v1/1/search.php?s=$query');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic>? fetchedRecipes = data['meals'];

        setState(() {
          if (fetchedRecipes != null) {
            recipes = fetchedRecipes.map((recipe) {
              return {
                'id': int.parse(recipe['idMeal']),
                'title': recipe['strMeal'],
                'image': recipe['strMealThumb'],
              };
            }).toList();
          } else {
            recipes = [];
          }
          filteredRecipes = List.from(recipes);
        });
      }
    } catch (e) {
      print("Error fetching recipes: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    String query = searchController.text.trim();
    fetchRecipes(query: query);
  }

  void _loadMoreRecipes() {
    setState(() {
      displayedRecipes += 8;
    });
  }

  void toggleLike(int recipeId) {
    setState(() {
      if (likedRecipes.contains(recipeId)) {
        likedRecipes.remove(recipeId);
      } else {
        likedRecipes.add(recipeId);
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Baking Recipes"),
        backgroundColor: Color(0xff9E9E9E),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search Baking Recipes',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 20),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: (displayedRecipes < filteredRecipes.length)
                          ? displayedRecipes
                          : filteredRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = filteredRecipes[index];
                        bool isLiked = likedRecipes.contains(recipe['id']);
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RecipeDetailScreen(recipeId: recipe['id']),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        recipe['image'],
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RecipeDetailScreen(
                                                        recipeId: recipe['id']),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.favorite,
                                          color: isLiked
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                        onPressed: () =>
                                            toggleLike(recipe['id']),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    recipe['title'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              if (displayedRecipes < filteredRecipes.length)
                Center(
                  child: TextButton(
                    onPressed: _loadMoreRecipes,
                    child: Text(
                      'See More',
                      style: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
