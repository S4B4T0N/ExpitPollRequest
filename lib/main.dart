import 'package:flutter/material.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // vypne banner vpravo hore
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand, // natiahne pozadie na celú obrazovku
          children: [
            // 🔹 Pozadie z assetu
            Image.asset('assets/pozadie/pozadie.jpg', fit: BoxFit.cover),

            // 🔹 Text v strede obrazovky
            const Center(
              child: Text(
                'Hello World!',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black54,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
