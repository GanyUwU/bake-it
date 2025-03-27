import 'package:flutter/material.dart';


class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> categories = [
    {'name': 'Special', 'icon': '⭐'},
    {'name': 'Breakfast', 'icon': '🍳'},
    {'name': 'Lunch', 'icon': '🍽️'},
    {'name': 'Dinner', 'icon': '🍲'},
  ];

  final List<Map<String, String>> needToTryRecipes = [
    {
      'title': 'Morning Pancakes',
      'description': 'Deep-fried ball of spiced with ground chickpeas or fava beans.',
      'image': 'https://via.placeholder.com/150', // Replace with your image
      'time': '1h',
      'difficulty': 'Easy',
      'calories': '300 kcal',
    },
    {
      'title': 'Fresh Tofu Salad',
      'description': 'Crispy tofu, greens, veggies, and tangy sesame-ginger dressing.',
      'image': 'https://via.placeholder.com/150', // Replace with your image
      'time': '1h',
      'difficulty': 'Medium',
      'calories': '470 kcal',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Embark on Your\nCooking Journey',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 20),
              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.filter_list),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Categories
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: category['name'] == 'Special'
                              ? Colors.green[800]
                              : Colors.grey[200],
                          foregroundColor: category['name'] == 'Special'
                              ? Colors.white
                              : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Row(
                          children: [
                            Text(category['icon']!),
                            SizedBox(width: 5),
                            Text(category['name']!),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
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
                  children: needToTryRecipes.map((recipe) {
                    return RecipeCard(
                      title: recipe['title']!,
                      description: recipe['description']!,
                      imageUrl: recipe['image']!,
                      time: recipe['time']!,
                      difficulty: recipe['difficulty']!,
                      calories: recipe['calories']!,
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              // Summer Selection Section (Partial)
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
              // Add more sections as needed
            ],
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

  RecipeCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.time,
    required this.difficulty,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
