import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wyceny/app/auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final auth = AuthScope.of(context);
      if (!auth.isInitialized) {
        await auth.init();
      }
      if (!mounted) return;
      if (auth.isLoggedIn) {
        context.go('/quote');
      } else {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
