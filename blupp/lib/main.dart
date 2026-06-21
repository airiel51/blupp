import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/dashboard_page.dart';
import 'pages/combined_tracking_page.dart';
import 'pages/analytics_page.dart';
import 'pages/login_page.dart';
import 'widgets/financial_advice_widget.dart';
import 'services/auth_service.dart';
import 'services/financial_data_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://thmfyjtaiqpdurzcazzv.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRobWZ5anRhaXFwZHVyemNhenp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIwMTc0NDgsImV4cCI6MjA5NzU5MzQ0OH0.w5psB45LC10UUj2ABYdLxxYql0eeo6H6t_b5TgDvs6E',
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => FinancialDataService()),
      ],
      child: const BluppApp(),
    ),
  );
}

class BluppApp extends StatelessWidget {
  const BluppApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blupp AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          primary: Colors.pink,
          secondary: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: Consumer<AuthService>(
        builder: (context, auth, child) {
          if (!auth.isAuthenticated) {
            return LoginPage();
          }
          return const MainScreen();
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const CombinedTrackingPage(),
    const AnalyticsPage(),
  ];

  final List<String> _titles = [
    'Blupp Dashboard',
    'Tracking & Budget',
    'Analytics',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_titles[_selectedIndex], style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _pages[_selectedIndex],
            ),
            // The Advice Widget stays on every page at the bottom
            const FinancialAdviceWidget(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tracking'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
        ],
      ),
    );
  }
}
