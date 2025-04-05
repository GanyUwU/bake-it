
import 'package:flutter/material.dart';

class SearchDisplay extends StatefulWidget {
  final String title;
  final String recipeResult;

  const SearchDisplay({
    super.key,
    required this.title,
    required this.recipeResult,
  });

  @override
  State<SearchDisplay> createState() => _SearchDisplayState();
}

class _SearchDisplayState extends State<SearchDisplay> {
  @override
  Widget build(BuildContext context) {
    List<String> ingredients = widget.recipeResult.trim().isNotEmpty
        ? widget.recipeResult.split("\n")
        : [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ingredients.isEmpty
          ? _buildEmptyState() // Show empty state if no ingredients
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  return _buildIngredientCard(ingredients[index]);
                },
              ),
            ),
    );
  }

  /// 🎨 *Empty State UI*
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "No ingredients found!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  /// 🍽 *Ingredient Card UI*
  Widget _buildIngredientCard(String ingredient) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.fastfood, color: Colors.orange),
        title: Text(
          ingredient,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}