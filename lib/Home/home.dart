import 'package:a1/API/gemini.dart';
import 'package:a1/Home/recipe.dart';
import 'package:a1/Home/search_display.dart';
import 'package:a1/Home/trial_s.dart';
import 'package:a1/Widget/gemini_display.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {


  final List<Map<String, String>> allRecipes = [
    {
      'title': 'Morning Pancakes',
      'description': 'Deep-fried ball of spiced with ground chickpeas or fava beans.',
      'image': 'assets/pancake.jpg', // Replace with your image
      'time': '1h',
      'difficulty': 'Easy',
      'calories': '300 kcal',
      'details': 'Step 1: Mix ingredients...\nStep 2: Cook on a pan...',
    },
    {
      'title': 'Fresh Tofu Salad',
      'description': 'Crispy tofu, greens, veggies, and tangy sesame-ginger dressing.',
      'image': 'assets/tofu.jpg', // Replace with your image
      'time': '1h',
      'difficulty': 'Medium',
      'calories': '470 kcal',
      'details': 'Step 1: Prepare tofu...\nStep 2: Toss with greens...',
    },
    {
      'title': 'Summer Pasta',
      'description': 'Light pasta with fresh summer veggies.',
      'image': 'assets/pasta/jpg', // Replace with your image
      'time': '45m',
      'difficulty': 'Easy',
      'calories': '350 kcal',
      'details': 'Step 1: Boil pasta...\nStep 2: Mix with veggies...',
    },
  ];

  List<Map<String, String>> filteredRecipes = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredRecipes = List.from(allRecipes); // Initially show all recipes
    searchController.addListener(_filterRecipes);
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
    //final apiUrl = "http://192.168.0.102:8000/scrape"; // replace with your server address
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
          _recipeResult = json.encode(data, toEncodable: (obj) => obj.toString());
        });
        // final ingredients = data["ingredients"]?.join("\n") ?? "No ingredients found";
        final title = data["title"] ?? "Recipe";

        // In fetchRecipeData()
        // final parsedIngredients = (data['ingredients'] as List)
        //     .map((item) => "${item['quantity']} ${item['unit']} ${item['ingredients']}")
        //     .join("\n");
        // print("Parsed ingredients: $parsedIngredients"); // <--- Debug

        // Inside fetchRecipeData()
        final parsedIngredients = (data['ingredients'] as List)
            .map((item) {
              final grams = item['grams']?.toStringAsFixed(1); // Round to 1 decimal
              return "${item['quantity']} ${item['unit']} ${item['ingredient']}${grams != null ? ' ($grams g)' : ''}";
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
        setState(() {
          _recipeResult = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      print("Exception: $e"); // <--- Debug
      setState(() {
        _recipeResult = "An error occurred: $e";
      });
    }
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header
            Text(
            'Embark on Your Cooking Journey',
            style: TextStyle(
              fontSize: 15 ,
              fontWeight: FontWeight.bold,
              fontFamily:'Sanfrans',
              height: 1.2,
              ),
            ),
         ]
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      body: Padding(
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('See all', style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filteredRecipes.map((recipe) {
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
            SizedBox(height: 20),
            // Summer Selection Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Summer Selection',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('See all', style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filteredRecipes.where((recipe) => recipe['title']!.contains('Summer')).map((recipe) {
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:(){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchBar(),
                ),
              );
            } , 
            child: Text("Try gemini"))
          ],
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
                Icon(Icons.local_fire_department, size: 16, color: Colors.green),
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