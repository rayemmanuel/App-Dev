import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/user_profile_model.dart';
import 'screens/get_started_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProfileModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FORMA App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.brown),
      home: GetStartedScreen(), // app starts here
    );
  }
}
