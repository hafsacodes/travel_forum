import 'package:flutter/material.dart';

void main() {
  runApp(const TravelForumApp());
}

class TravelForumApp extends StatelessWidget {
  const TravelForumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Forum',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Forum'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Welcome to Travel Forum!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

