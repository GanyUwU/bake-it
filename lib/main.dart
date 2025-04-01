import 'package:a1/API/try.dart';
import 'package:a1/Home/home.dart';
import 'package:a1/Home/new_homepage.dart';
import 'package:a1/Widget/new_recipe_prakyat.dart';
import 'package:a1/Widget/recipe_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Home/profile.dart';
import 'Home/splash.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
      //home: Splash()
      //home: RecipeApp(),
      //home: Home(),
        home: MyApp(),
  ));
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  // Add your screens here
  final List<Widget> tabs = [
    Home(),
    RecipeScreen(),       // First tab - Home Screen
    Profile(),    // Second tab - Profile Screen
  ];

  @override
  Widget build(BuildContext context) {
    print("Tabs length: ${tabs.length}");
    return MaterialApp(
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: tabs,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          fixedColor: Colors.black,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.food_bank),
              label: "Recipe",
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
