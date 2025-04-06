import 'package:a1/API/gemini.dart';
import 'package:a1/Widget/gemini_display.dart';
import 'package:flutter/material.dart';

class SearchBar_gem extends StatefulWidget {
  const SearchBar_gem({super.key});

  @override
  State<SearchBar_gem> createState() => _SearchBar_gemState();
}

class _SearchBar_gemState extends State<SearchBar_gem> {
  final TextEditingController _searchController = TextEditingController();

  void _searchGeminiRecipe() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    String recipeDetail = await fetchRecipeFromGemini(query);

    Navigator.of(context).pop(); // Close the loading dialog

    // Format and navigate
    List<Widget> formattedRecipe = _formatRecipeOutput(recipeDetail);
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
      return [Text("No recipe found.", style: TextStyle(fontSize: 16))];
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

      formattedWidgets.add(SizedBox(height: 5));
    }

    return formattedWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gemini for Bakers',
        style: TextStyle(fontFamily: "Sanfrans",
          color: Color(0xFF151414)
          ),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFAFACAC), // Start color (fully opaque version)
              Color(0x80AFACAC), // End color (semi-transparent as in your example)
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Generate any Recipe you like !!",
                style: TextStyle(
                    fontFamily: "Sanfrans",
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 40),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search for a recipe',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchGeminiRecipe,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
