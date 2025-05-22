import 'package:flutter/material.dart';

class CreatorHomeScreen extends StatelessWidget {
  const CreatorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Screen'),
      ),
      body: const Center(
        child: Text('Welcome, Instructor!'),
      ),
    );
  }
}