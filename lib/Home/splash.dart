import 'package:a1/Home/home.dart';
import 'package:flutter/material.dart';
import '../Auth/signin.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF7C7A7A),
              Color(0xffcccaca),
              Color(0xFFFFFFFF)
            ],
          ),
        ),

        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft, // Moves image to the left
              child: Image.asset(
                'assets/mac.png',
                fit: BoxFit.contain,
                width: size.width * 0.7, // Adjust the width to control positioning
              ),
            ),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  //textAlign: TextAlign.center, // Adjust alignment if needed
                  text: TextSpan(
                    // Base style (applies to all children that don't override it)
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Sanfrans',
                      color: Colors.black,
                      height: 1.2,
                    ),
                    children: [
                      const TextSpan(
                        text: "Cooking\n", // Normal text
                      ),
                      TextSpan(
                        text: "Delicious\n", // Different color
                        style: const TextStyle(
                          color: Colors.grey, // Pick your color
                        ),
                      ),
                      const TextSpan(
                        text: "Like a Baker",
                        style: const TextStyle(
                          color: Colors.grey, // Pick your color
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ),

            // 4) Subtitle text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "This recipe app offers a wide selection of diverse "
                    "and easy recipes suitable for all cooking levels!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Customize color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>SignIn()));
                        //Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));
                      },  
                      child: const Text(
                        "Get Started",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: "Sanfrans"
                        ),
                      ),
                    )
                )
            )
          ],
        ),
      ),
    );
  }
}
