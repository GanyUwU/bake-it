import 'package:a1/API/gemini.dart';
//import 'package:a1/Home/recipe.dart';
import 'package:a1/Home/search_display.dart';
import 'package:a1/Home/URL_display.dart';
import 'package:a1/Widget/gemini_display.dart';
import 'package:a1/Widget/search_bar_gem.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<Map<String, dynamic>> allRecipes = [];
  List<Map<String, dynamic>> filteredRecipes = [];
  TextEditingController searchController = TextEditingController();

  // Static recipes to use as fallback
  final List<Map<String, dynamic>> staticRecipes = [
    {
      'title': 'Chocolate Chip Cookies',
      'description': 'Classic homemade cookies with gooey chocolate chips',
      'image': 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?ixlib=rb-4.0.3',
      'time': '25m',
      'difficulty': 'Easy',
      'calories': '180 kcal',
      'details': 'Cream butter and sugars until fluffy. Beat in eggs and vanilla. Mix dry ingredients separately, then combine with wet ingredients. Fold in chocolate chips. Drop spoonfuls onto baking sheets and bake at 350°F for 10-12 minutes until golden brown around the edges.',
    },
    {
      'title': 'Vanilla Pound Cake',
      'description': 'Rich and buttery classic pound cake with vanilla flavor',
      'image': 'https://images.unsplash.com/photo-1605291445244-9ff5e28a5376?ixlib=rb-4.0.3',
      'time': '75m',
      'difficulty': 'Medium',
      'calories': '420 kcal',
      'details': 'Beat butter and sugar until light and fluffy. Add eggs one at a time, then vanilla extract. Gradually add flour, salt, and baking powder. Pour into a greased loaf pan and bake at 325°F for 60-65 minutes. Cool completely before slicing.',
    },
    {
      'title': 'Summer Berry Scones',
      'description': 'Buttery scones filled with seasonal fresh berries',
      'image': 'https://images.unsplash.com/photo-1592394533824-9440e5d61b43?ixlib=rb-4.0.3',
      'time': '30m',
      'difficulty': 'Easy',
      'calories': '320 kcal',
      'details': 'Mix flour, sugar, baking powder, and salt. Cut in cold butter. Stir in cream and fold in fresh berries. Pat dough into a circle, cut into wedges, brush with cream and sprinkle with sugar. Bake at 400°F for 15-18 minutes until golden.',
    },
    {
      'title': 'Double Chocolate Brownies',
      'description': 'Rich and fudgy chocolate brownies with chocolate chips',
      'image': 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?ixlib=rb-4.0.3',
      'time': '45m',
      'difficulty': 'Medium',
      'calories': '450 kcal',
      'details': 'Melt butter and dark chocolate together. Whisk in sugar until dissolved. Add eggs one at a time. Fold in flour, cocoa powder, and salt. Stir in chocolate chips. Pour into a lined baking pan and bake at 350°F for 25-30 minutes. Cool before cutting into squares.',
    },
    {
      'title': 'Summer Fruit Tart',
      'description': 'Buttery pastry crust filled with custard and fresh fruits',
      'image': 'https://images.unsplash.com/photo-1562005754-5f74feeef77a?ixlib=rb-4.0.3',
      'time': '90m',
      'difficulty': 'Hard',
      'calories': '380 kcal',
      'details': 'Make pastry by mixing flour, sugar, salt, and cold butter. Add egg and form dough. Chill, then roll out and press into tart pan. Blind bake at 375°F. Make custard with milk, eggs, sugar, and vanilla. Pour into cooled crust, arrange sliced fruits on top, and brush with apricot glaze.',
    },
    {
      'title': 'Summer Lemon Bars',
      'description': 'Tangy lemon filling on a buttery shortbread crust',
      'image': 'https://images.unsplash.com/photo-1576618148400-f54bed99fcfd?ixlib=rb-4.0.3',
      'time': '60m',
      'difficulty': 'Medium',
      'calories': '280 kcal',
      'details': 'Make shortbread crust with flour, butter, sugar and salt. Press into pan and bake at 350°F for 15 minutes. For filling, whisk eggs, sugar, lemon juice, zest, and flour. Pour over warm crust and bake 20-25 minutes until set. Cool completely before dusting with powdered sugar and cutting.',
    }
  ];

  // Keep the original function but comment it out
  Future<List<Map<String, dynamic>>> fetchRecipesAutomatically() async {
    // Try to fetch from API first
    try {
      final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List;

        return meals.take(4).map((meal) {
          return {
            'title': meal['strMeal'] ?? 'No Title',
            'description':
            meal['strInstructions']?.split('.').first ?? 'No Description',
            'image': meal['strMealThumb'] ?? '',
            'time': '30m', // Placeholder
            'difficulty': 'Medium', // Placeholder
            'calories': '400 kcal', // Placeholder
            'details': meal['strInstructions'] ?? '',
          };
        }).toList();
      } else {
        // If API fails, return static recipes
        print("API failed, using static recipes");
        return staticRecipes;
      }
    } catch (e) {
      // If error occurs, return static recipes
      print("Error fetching recipes: $e");
      return staticRecipes;
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize with static recipes immediately
    allRecipes = List.from(staticRecipes);
    filteredRecipes = List.from(staticRecipes);
    searchController.addListener(_filterRecipes);

    // Try to fetch from API anyway
    fetchRecipesAutomatically().then((fetchedRecipes) {
      setState(() {
        if (fetchedRecipes.isNotEmpty) {
          allRecipes = fetchedRecipes;
          filteredRecipes = fetchedRecipes;
        }
      });
    });
  }

  void _filterRecipes() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredRecipes = allRecipes.where((recipe) {
        return recipe['title']!.toLowerCase().contains(query) ||
            recipe['description']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  final TextEditingController _urlController = TextEditingController();
  String _recipeResult = "";

  // Function to send the POST request to your backend API
  Future<void> fetchRecipeData(String url) async {
    //final apiUrl = "http://10.64.81.58:8000/scrape"; // replace with your server address
    final apiUrl = "http://10.0.2.2:8000/scrape";
    print("Making POST request to $apiUrl with body: $url"); // <--- Debug

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"url": url}),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        // Parse the JSON response

        final data = json.decode(response.body);
        setState(() {
          _recipeResult =
              json.encode(data, toEncodable: (obj) => obj.toString());
          _recipeResult =
              json.encode(data, toEncodable: (obj) => obj.toString());
        });

        final title = data["title"] ?? "Recipe";
        // Inside fetchRecipeData()
        final parsedIngredients = (data['ingredients'] as List)
            .map((item) {
          final grams = item['grams']?.toStringAsFixed(1); // Round to 1 decimal
          return "${item['quantity']} ${item['unit']} ${item['ingredient']}${grams !=
              null ? ' ($grams g)' : ''}";
        })
            .join("\n");
        print("Parsed ingredients: $parsedIngredients"); // <--- Debug

        final recipe = Recipe.fromApiData(data);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RecipeDetailView(recipe: recipe,)
          ),
        );
        print("Recipe data: $_recipeResult");
      } else {
        // If API call fails, show static recipe detail
        _handleApiFailure(url);
      }
    } catch (e) {
      print("Exception: $e"); // <--- Debug
      // If exception occurs, show static recipe detail
      _handleApiFailure(url);
    }
  }

  // New method to handle API failure
  void _handleApiFailure(String url) {
    // Show an error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recipe API unavailable. Using sample recipe instead.')),
    );

    // Navigate to a static recipe detail
    final staticRecipe = staticRecipes.first;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(
          title: staticRecipe['title']!,
          imageUrl: staticRecipe['image']!,
          details: staticRecipe['details']!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFBDBABA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Text(
            'Embark on Your Cooking Journey',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Sanfrans',
              height: 1.2,
            ),
          ),
        ]),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              //Color(0xFF7C7A7A),
              Color(0xffcccaca),
              Color(0xFFFFFFFF)
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(height: 20),// Search bar with TextField and a search button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _urlController,
                          decoration: InputDecoration(
                            hintText: "Enter Recipe URL",
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
          
          
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.black),
                        onPressed: () {
                          print("Send button tapped");
                          // Trigger API call when button is pressed
                          final url = _urlController.text;
                          if (url.isNotEmpty) {
                            fetchRecipeData(url);
                          }
                        },
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Display the recipe result
          
                SizedBox(height: 20),
                // Need to Try Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Need to Try',
                      style: TextStyle(fontSize: 18,fontFamily: "Sanfrans", fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text('See all', style: TextStyle(fontFamily: "Sanfrans",color: Colors.black)),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Expanded(
                    child: Row(
                      children: staticRecipes.map((recipe) {
                        return RecipeCard(
                          title: recipe['title']!,
                          description: recipe['description']!,
                          imageUrl: recipe['image']!,
                          time: recipe['time']!,
                          difficulty: recipe['difficulty']!,
                          calories: recipe['calories']!,
                          details: recipe['details']!,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Summer Selection Section
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text(
                //       'Summer Selection',
                //       style: TextStyle(fontSize: 18, fontFamily: "Sanfrans",fontWeight: FontWeight.bold),
                //     ),
                //     TextButton(
                //       onPressed: () {},
                //       child: Text('See all', style: TextStyle(fontFamily: "Sanfrans",color: Colors.black)),
                //     ),
                //   ],
                // ),
                SizedBox(height: 10),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Expanded(
                //     child: Row(
                //       children: filteredRecipes
                //           .where((recipe) => recipe['title']!.toLowerCase().contains('summer'))
                //           .map((recipe) {
                //         return RecipeCard(
                //           title: recipe['title']!,
                //           description: recipe['description']!,
                //           imageUrl: recipe['image']!,
                //           time: recipe['time']!,
                //           difficulty: recipe['difficulty']!,
                //           calories: recipe['calories']!,
                //           details: recipe['details']!,
                //         );
                //       }).toList(),
                //     ),
                //   ),
                // ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:(){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchBar_gem(),
                        ),
                      );
                    } ,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Button background color
                      elevation: 8, // Shadow depth
                      shadowColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text("Try gemini",
                      style: TextStyle(
                          fontFamily: "Sanfrans",
                          fontSize: 20,
                          color: Colors.black
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String time;
  final String difficulty;
  final String calories;
  final String details;

  RecipeCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.time,
    required this.difficulty,
    required this.calories,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(
              title: title,
              imageUrl: imageUrl,
              details: details,
            ),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: EdgeInsets.only(right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback image if network image fails to load
                      return Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Icon(Icons.restaurant, size: 50, color: Colors.grey[600]),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.bookmark_border, size: 20),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.green),
                SizedBox(width: 5),
                Text(time, style: TextStyle(fontSize: 12)),
                SizedBox(width: 10),
                Icon(Icons.star, size: 16, color: Colors.green),
                SizedBox(width: 5),
                Text(difficulty, style: TextStyle(fontSize: 12)),
                SizedBox(width: 10),
                Icon(Icons.local_fire_department,
                    size: 16, color: Colors.green),
                SizedBox(width: 5),
                Text(calories, style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeDetailScreen extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String details;

  RecipeDetailScreen({
    required this.title,
    required this.imageUrl,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback image if network image fails to load
                return Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Icon(Icons.restaurant, size: 80, color: Colors.grey[600]),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Instructions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    details,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}