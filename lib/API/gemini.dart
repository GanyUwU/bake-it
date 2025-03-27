import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> fetchRecipeFromGemini(String recipeName) async {
  const String apiKey = 'AIzaSyDOs4oVNTJQ-o14gpHNSdZi5a7jDrewQHU';  // Replace with your key
  const String endpoint = 'https://www.bbc.co.uk/food/cakes_and_baking'; // Replace with the actual API endpoint

  final response = await http.post(
    Uri.parse(endpoint),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      'query': recipeName,
      'measurement_units': ['grams', 'teaspoons', 'tablespoons']
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['recipe'];  // Adjust the key based on the actual API response
  } else {
    throw Exception('Failed to fetch recipe from Gemini AI');
  }
}
