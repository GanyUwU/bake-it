import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> fetchRecipeFromGemini(String recipeName) async {
  const String apiKey = 'AIzaSyDa9uzq0TV27-EaV_MmmZSRJgig8stiFsw';  // Replace with your actual API key
  final String endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

  final Map<String, dynamic> requestBody = {
    "contents": [
      {
        "parts": [
          {
            "text":
                "Provide a detailed recipe for $recipeName, including all ingredients with accurate measurements in both grams and teaspoons/tablespoons. Format it clearly."
          }
        ]
      }
    ],
    "generationConfig": {
      "temperature": 0.7,
      "maxOutputTokens": 2000
    }
  };

  try {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data['candidates'] != null && 
          data['candidates'].isNotEmpty && 
          data['candidates'][0]['content'] != null &&
          data['candidates'][0]['content']['parts'] != null &&
          data['candidates'][0]['content']['parts'].isNotEmpty) {
        return data["candidates"][0]["content"]["parts"][0]["text"];
      } else {
        print("Unexpected API response structure");
        return "Error: Unable to parse recipe from API response";
      }
    } else {
      print("API Error Details: ${response.body}");
      return "Error fetching recipe. Status: ${response.statusCode}";
    }
  } catch (e) {
    print("Exception occurred: $e");
    return "An unexpected error occurred: $e";
  }
}
