import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const VMFSwedenApp());
}

class VMFSwedenApp extends StatelessWidget {
  const VMFSwedenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VMF Sweden - DJI Mimo Style',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.black,
      ),
      debugShowCheckedModeBanner: false,
      home: const MainNavigationScreen(),
    );
  }
}
