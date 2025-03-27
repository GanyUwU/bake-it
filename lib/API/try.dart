import 'package:flutter/material.dart';
import 'package:a1/API/gemini.dart';


class RecipeSearch extends StatefulWidget {
  const RecipeSearch({super.key});

  @override
  _RecipeSearchState createState() => _RecipeSearchState();
}

class _RecipeSearchState extends State<RecipeSearch> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';

  void _searchRecipe() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    try {
      final result = await fetchRecipeFromGemini(query);
      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _result = 'Recipe not found. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Precision Baking Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter recipe name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchRecipe,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(_result, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

