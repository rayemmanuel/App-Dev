import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6C0BF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD6C0BF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "My Forma",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black),
            onPressed: () {
              // Save profile action
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          children: [
            const CircleAvatar(radius: 60, backgroundColor: Colors.white),
            const SizedBox(height: 30),

            // Name
            TextField(
              decoration: const InputDecoration(
                labelText: "Name",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Email Address
            TextField(
              decoration: const InputDecoration(
                labelText: "Email Address",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Username
            TextField(
              decoration: const InputDecoration(
                labelText: "Username",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Password
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Phone Number
            TextField(
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: UnderlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
