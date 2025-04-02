import 'package:a1/API/gemini.dart';
import 'package:a1/Widget/gemini_display.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {

  // Controller for the search bar (for Gemini)
  final TextEditingController _searchController = TextEditingController();
  // List to hold the search results (for Gemini)
   // Function to call Gemini API using the external function and display the result
  void _searchGeminiRecipe() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Optionally show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    String recipeDetail = await fetchRecipeFromGemini(query);


   
    // Format the recipe output
  List<Widget> formattedRecipe = _formatRecipeOutput(recipeDetail);

  // Navigate to RecipeDetailPage with formatted data
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RecipeDetailPage(
        query: query,
        formattedRecipe: formattedRecipe,
      ),
    ),
  );
  }

  List<Widget> _formatRecipeOutput(String rawText) {
  if (rawText.isEmpty) {
    return [Text("No recipe found.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))];
  }

  List<Widget> formattedWidgets = [];
  List<String> lines = rawText.split("\n");

  for (String line in lines) {
    if (line.toLowerCase().contains("ingredients")) {
      formattedWidgets.add(Text(
        line.trim(),
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
      ));
    } else if (line.toLowerCase().contains("instructions") || line.toLowerCase().contains("method")) {
      formattedWidgets.add(SizedBox(height: 10));
      formattedWidgets.add(Text(
        line.trim(),
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
      ));
    } else if (line.startsWith("-") || line.startsWith("*") || line.contains("•")) {
      formattedWidgets.add(Padding(
        padding: EdgeInsets.only(left: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("• ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
            Expanded(
              child: Text(
                line.replaceAll(RegExp(r"[-*•]"), "").trim(),
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ));
    } else {
      formattedWidgets.add(Text(
        line.trim(),
        style: TextStyle(fontSize: 16),
      ));
    }

    formattedWidgets.add(SizedBox(height: 5)); // Add spacing between lines
  }

  return formattedWidgets;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Recipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for a recipe',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchGeminiRecipe,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchGeminiRecipe,
              child: const Text('Search Recipe'),
            ),
            // Add other widgets or functionality as needed
          ],
        ),
      ),
    );
  }
}