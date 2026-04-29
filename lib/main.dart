import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/floppy.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flappy Bird Clone',
      home: SplashScreen(),
    );
  }
}


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
     
          Container(color: Colors.lightBlue.shade300),

  
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'FLAPPY BIRD',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow.shade700,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => GameWithButton()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    backgroundColor: Colors.orangeAccent,
                  ),
                  child: const Text(
                    'PLAY',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class GameWithButton extends StatelessWidget {
  const GameWithButton({super.key});

  @override
  Widget build(BuildContext context) {
    final FlappyGame game = FlappyGame();

    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),
          Positioned(
            bottom: 50,
            right: 30,
            child: ElevatedButton(
              onPressed: () => game.jump(),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.blueAccent,
              ),
              child: const Icon(Icons.arrow_upward, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}

 