import 'package:flutter/material.dart';
import 'package:fmtpla_code/pages/history.dart';
import 'package:fmtpla_code/pages/home.dart';
import 'package:fmtpla_code/pages/search.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int selectedIndex = 0; // Keep track of the selected index
  late PageController
      _pageController; // PageController for managing the slide animation

  @override
  void initState() {
    super.initState();
    _pageController = PageController(); // Initialize the PageController
  }

  @override
  void dispose() {
    _pageController
        .dispose(); // Dispose the PageController when it's no longer needed
    super.dispose();
  }

  // List of pages to display based on selectedIndex
  final List<Widget> pages = const [
    HomePage(),
    SearchPage(),
    HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true, // Enable Material 3
        colorSchemeSeed: Colors.blue, // Optional: Customize colors
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor:
              const Color(0xFF9CBAA8), // Sage green color for the top bar
          title: const Text("FMTPLA's Feed"),
        ),
        body: (_pageController !=
                null) // Null check to ensure _pageController is initialized
            ? PageView(
                controller: _pageController, // Set the PageController
                children: pages, // Display the list of pages
                onPageChanged: (index) {
                  setState(() {
                    selectedIndex =
                        index; // Update selectedIndex when page is changed by swiping
                  });
                },
              )
            : const Center(
                child:
                    CircularProgressIndicator(), // Optional: Show a loading indicator while initializing
              ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color:
                const Color(0xFF9CBAA8), // Sage green color for the bottom bar
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0), // Adjust the radius as needed
              topRight: Radius.circular(20.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12, // Optional: Add shadow to the bottom bar
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: NavigationBar(
            elevation: 0,
            backgroundColor: Colors.transparent, // Make background transparent
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
              NavigationDestination(
                  icon: Icon(Icons.history), label: 'History'),
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex =
                    index; // Update selectedIndex when an item is tapped
              });
              _pageController.animateToPage(
                index,
                duration: const Duration(
                    milliseconds: 300), // Slide animation duration
                curve: Curves.easeInOut, // Curve for the sliding animation
              );
            },
          ),
        ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
