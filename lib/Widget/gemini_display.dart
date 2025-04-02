import 'package:flutter/material.dart';


class RecipeDetailPage extends StatelessWidget {
  final String query;
  final List<Widget> formattedRecipe;

  const RecipeDetailPage({super.key, required this.query, required this.formattedRecipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recipe for $query")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: formattedRecipe, // Display formatted widgets
          ),
        ),
      ),
    );
  }
}
