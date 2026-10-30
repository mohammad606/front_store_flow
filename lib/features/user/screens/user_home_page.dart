import 'package:flutter/material.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'StoreFlow',
          style: TextStyle(color: Color(0xFF0F172A)),
        ),
      ),
      body: const SizedBox.expand(),
    );
  }
}
