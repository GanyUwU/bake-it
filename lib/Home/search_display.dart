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
  final String _recipeResult = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Display'),
      ),
      body: Center(
        child: Row(
          children: [
            Expanded(
                child: ListView.builder(
                  itemCount: _recipeResult.split("\n").length,
                  itemBuilder: (context, index) {
                    final ingredient = _recipeResult.split("\n")[index];
                    return ListTile(
                      leading: Icon(Icons.circle, size: 8),
                      title: Text(ingredient),
                    );
                  },
                ),
              ),
          ],
        )
      ),
    );
  }
}