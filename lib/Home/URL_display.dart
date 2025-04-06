import 'package:flutter/material.dart';
import 'package:a1/Home/home.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Recipe {
  final String title;
  final List<Ingredient> ingredients;

  Recipe({
    required this.title,
    required this.ingredients,
  });

  // Add factory method to parse API data
  factory Recipe.fromApiData(Map<String, dynamic> data) {
    final title = data["title"] ?? "Recipe";

    // Parse ingredients from API data
    final ingredientsList = data["ingredients"] as List;
    final ingredients = ingredientsList.map((item) {
      final grams = item['grams']?.toStringAsFixed(1);
      final quantity = item['quantity'] ?? '';
      final unit = item['unit'] ?? '';
      final name = item['ingredient'] ?? '';
      final displayName = "$name${grams != null ? ' ($grams g)' : ''}";

      // Generate a deterministic color based on ingredient name
      final colorValue = name.hashCode % 9;
      final colors = [
        Colors.green,
        Colors.blue,
        Colors.orange,
        Colors.purple,
        Colors.teal,
        Colors.pink,
        Colors.amber,
        Colors.cyan,
        Colors.indigo,
      ];

      return Ingredient(
        name: displayName,
        amount: "$quantity $unit".trim(),
        iconColor: colors[colorValue],
      );
    }).toList();

    return Recipe(
      title: title,
      ingredients: ingredients,
    );
  }

  // Your existing method
  static Recipe Simple() {
    return Recipe(
      title: "French Macarons",
      ingredients: const [
        Ingredient(name: "Almond flour", amount: "1 cup", iconColor: Colors.amber),
        Ingredient(name: "Powdered sugar", amount: "1 3/4 cups", iconColor: Colors.blue),
        Ingredient(name: "Egg whites", amount: "3 large", iconColor: Colors.pink),
        Ingredient(name: "Granulated sugar", amount: "1/4 cup", iconColor: Colors.green),
      ],
    );
  }
}

class Ingredient {
  final String name;
  final String amount;
  final Color iconColor;

  const Ingredient({
    required this.name,
    required this.amount,
    required this.iconColor,
  });
}

class RecipeDetailView extends StatefulWidget {
  // Add recipe parameter
  final Recipe? recipe;

  const RecipeDetailView({super.key, this.recipe});

  @override
  State<RecipeDetailView> createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<RecipeDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Recipe _recipe;

  @override
  void initState() {
    super.initState();
    // Initialize tab controller for switching between Details and Reviews tabs
    _tabController = TabController(length: 2, vsync: this);

    // Use provided recipe or fallback to default
    _recipe = widget.recipe ?? Recipe.Simple();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
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
          child: Column(
            children: [
              // Top navigation and image area
              _buildRecipeHeader(),

              // Recipe details content
              Expanded(
                child: _buildRecipeDetails(),
              ),

              // Bottom navigation
              // _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeHeader() {
    return Stack(
      children: [
        // Recipe image
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cake,
                  size: 80,
                  color: Colors.amber[300],
                ),
                const SizedBox(height: 8),
                Text(
                  // Use recipe title in the header
                  '${_recipe.title} Image',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),

        // Back button and bookmark
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconButton(Icons.arrow_back, () {
                Navigator.pop(context); // Add navigation back
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildRecipeDetails() {
    return Column(
      children: [
        // Tab bar for switching between Details and Reviews
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green,
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Reviews'),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDetailsTab(),
              _buildReviewsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _recipe.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      "4.5",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'A delicious recipe with simple ingredients that you can prepare at home.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Ingredients with "Add to cart" feature
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${_recipe.ingredients.length} ingredients added to shopping list'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart, size: 16),
                  label: const Text('Add to cart'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Ingredients list - use dynamic data from recipe
            ...List.generate(_recipe.ingredients.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: IngredientItem(
                  name: _recipe.ingredients[index].name,
                  amount: _recipe.ingredients[index].amount,
                  iconColor: _recipe.ingredients[index].iconColor,
                ),
              );
            }),

            const SizedBox(height: 24),

            // Instructions title
            const Text(
              'Instructions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Steps
            ...List.generate(4, (index) {
              return StepItem(
                stepNumber: index + 1,
                description:
                'This is step ${index + 1} of the recipe. ${index == 0 ? 'Preheat oven to 320°F (160°C) and line baking sheets with parchment paper.' : index == 1 ? 'In a large bowl, sift together ground almonds, powdered sugar, and cocoa powder.' : index == 2 ? 'Beat egg whites until foamy, then gradually add granulated sugar until stiff peaks form.' : 'Pipe small circles onto the baking sheets and let rest for 30 minutes before baking.'}',
              );
            }),

            const SizedBox(height: 24),

            // Watch videos button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon:
                const Icon(Icons.play_circle_outline, color: Colors.white),
                label: const Text(
                  'Watch Video Tutorial',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Overall rating summary section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  // Right side: Rating breakdown by stars (5★ to 1★)
                  Expanded(
                    child: Column(
                      children: List.generate(5, (index) {
                        final starCount = 5 - index;
                        // Example percentages for each star rating
                        final percentage = [60, 25, 10, 3, 2][index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              // Star count (5, 4, 3, etc.)
                              Text('$starCount',
                                  style: const TextStyle(color: Colors.grey)),
                              const SizedBox(width: 4),
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 12),
                              const SizedBox(width: 8),
                              // Progress bar showing percentage of reviews with this rating
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: percentage / 100,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.green),
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Percentage display
                              Text('$percentage%',
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Individual user reviews
            ...List.generate(3, (index) {
              // Sample review data - in a real app, this would come from a database
              return ReviewItem(
                username: ['Laura K.', 'David M.', 'Sophie T.'][index],
                date: ['Feb 25, 2025', 'Mar 12, 2025', 'Feb 19, 2025'][index],
                rating: [5.0, 4.0, 4.5][index],
                comment: [
                  'This cake are absolutely delicious! The recipe is easy to follow and the results were better than the ones from my local bakery!',
                  'Good recipe overall, but I had to adjust the baking time for my oven. I would suggest checking them earlier.',
                  'Loved this cake! The vanilla filling was divine. Will definitely make these again for special occasions.'
                ][index],
              );
            }),

            const SizedBox(height: 16),

            // Write review button
            OutlinedButton.icon(
              onPressed: () {
                // Show a snackbar for now
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Review feature coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.rate_review),
              label: const Text('Write a Review'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Widget _buildBottomNavigation() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 8,
  //           offset: const Offset(0, -4),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: [
  //         _buildNavItem(Icons.home_outlined, 'Home', false),
  //         _buildNavItem(Icons.search, 'Search', false),
  //         _buildNavItem(Icons.restaurant_menu, 'Recipes', true),
  //         _buildNavItem(Icons.favorite_outline, 'Favorites', false),
  //         _buildNavItem(Icons.person_outline, 'Profile', false),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildNavItem(IconData icon, String label, bool isActive) {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Icon(
  //         icon,
  //         color: isActive ? Colors.green : Colors.grey,
  //       ),
  //       const SizedBox(height: 4),
  //       Text(
  //         label,
  //         style: TextStyle(
  //           fontSize: 12,
  //           color: isActive ? Colors.green : Colors.grey,
  //           fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
  //         ),
  //       ),
  //     ],
  //   );
  // }
}

class RecipeInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const RecipeInfoChip({
    Key? key,
    required this.icon,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.green),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class IngredientItem extends StatelessWidget {
  final String name;
  final String amount;
  final Color iconColor;

  const IngredientItem({
    Key? key,
    required this.name,
    required this.amount,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200] ?? Colors.grey),
      ),
      child: Row(
        children: [
          // Ingredient icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.food_bank,
              color: iconColor,
            ),
          ),

          const SizedBox(width: 12),

          // Ingredient name
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),

          // Amount
          Text(
            amount,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class StepItem extends StatelessWidget {
  final int stepNumber;
  final String description;

  const StepItem({
    Key? key,
    required this.stepNumber,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Step description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step $stepNumber',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewItem extends StatelessWidget {
  final String username;
  final String date;
  final double rating;
  final String comment;

  const ReviewItem({
    Key? key,
    required this.username,
    required this.date,
    required this.rating,
    required this.comment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200] ?? Colors.grey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Review header with user info and rating
          Row(
            children: [
              // User avatar (in a real app, would show profile picture)
              CircleAvatar(
                backgroundColor: Colors.green[100],
                child: Text(
                  username[0], // First letter of username as avatar placeholder
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // User name and review date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Star rating display
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    // Logic to show full, half, or empty stars
                    index < rating.floor()
                        ? Icons.star
                        : index == rating.floor() && rating % 1 > 0
                        ? Icons.star_half
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Review content/comment
          Text(
            comment,
            style: const TextStyle(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Add this modified function to your home.dart file
Future<void> fetchRecipeData(BuildContext context, String url) async {
  final apiUrl = "http://10.0.2.2:8000/scrape";
  print("Making POST request to $apiUrl with body: $url");

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

      // Create Recipe object from API data
      final recipe = Recipe.fromApiData(data);

      // Navigate to RecipeDetailView with the recipe data
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RecipeDetailView(recipe: recipe)
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading recipe: ${response.statusCode}")),
      );
    }
  } catch (e) {
    print("Exception: $e");
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occurred: $e")),
    );
  }
}