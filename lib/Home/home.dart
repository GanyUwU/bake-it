import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _urlController = TextEditingController();
  String _recipeResult = "";

  // Function to send the POST request to your backend API
  Future<void> fetchRecipeData(String url) async {
    final apiUrl = "http://127.0.0.1:5000"; // replace with your server address
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"url": url}),
      );
      if (response.statusCode == 200) {
        // Parse the JSON response
        final data = json.decode(response.body);
        setState(() {
          _recipeResult = json.encode(data, toEncodable: (obj) => obj.toString());
        });
      } else {
        setState(() {
          _recipeResult = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _recipeResult = "An error occurred: $e";
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Location", style: TextStyle(fontSize: 12, color: Colors.grey)),
            Row(
              children: [
                Icon(Icons.location_pin, color: Colors.red, size: 18),
                Text(
                  "172 Grand St, NY",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.keyboard_arrow_down, color: Colors.black),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Search bar with TextField and a search button
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        hintText: "Enter Recipe URL",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.black),
                    onPressed: () {
                      // Trigger API call when button is pressed
                      final url = _urlController.text;
                      if (url.isNotEmpty) {
                        fetchRecipeData(url);
                      }
                    },
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            // Display the recipe result
            Expanded(
              child: SingleChildScrollView(
                child: Text(_recipeResult),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
