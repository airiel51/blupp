import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blupp/main.dart';
import 'package:blupp/services/auth_service.dart';
import 'package:blupp/services/financial_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://thmfyjtaiqpdurzcazzv.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRobWZ5anRhaXFwZHVyemNhenp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIwMTc0NDgsImV4cCI6MjA5NzU5MzQ0OH0.w5psB45LC10UUj2ABYdLxxYql0eeo6H6t_b5TgDvs6E',
  );

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AuthService()),
          ChangeNotifierProvider(create: (context) => FinancialDataService()),
        ],
        child: const BluppApp(),
      ),
    );
    // Verify that the login page is shown initially, assuming no auth
    // expect(find.text('Login'), findsOneWidget);
  });
}
