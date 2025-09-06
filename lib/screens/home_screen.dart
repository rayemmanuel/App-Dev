import 'package:flutter/material.dart';

void main() {
  runApp(const BodyShapeCalculatorApp());
}

class BodyShapeCalculatorApp extends StatelessWidget {
  const BodyShapeCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Body Shape Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
    );
  }
}

/// Main screen managing bottom navigation and tabs
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreenContent(), // Home tab
    PalleteScreen(),
    FormScreen(),
    MyFormaScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FORMA"), backgroundColor: Colors.brown),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.palette), label: 'Pallete'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Form'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My Forma'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// --- Updated Home tab content ---
class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "Welcome to FORMA!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            "Every Form. Every Shade. Sustainable & True.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// --- Placeholder screens ---
class PalleteScreen extends StatelessWidget {
  const PalleteScreen({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: Text(
      'Pallete Page',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
  );
}

class FormScreen extends StatelessWidget {
  const FormScreen({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: Text(
      'Form Page',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
  );
}

class MyFormaScreen extends StatelessWidget {
  const MyFormaScreen({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: Text(
      'My Forma Page',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
  );
}
