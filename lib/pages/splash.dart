import "package:flutter/material.dart";

class Splash extends StatelessWidget {
  static const TextStyle style = TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink,
      body: Center(child: Text("Berrymon", style: style)),
    );
  }
}
