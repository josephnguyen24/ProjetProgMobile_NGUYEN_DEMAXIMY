import 'package:flutter/material.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_theme_extension.dart';
import 'package:formation_flutter/screens/auth/login_page.dart';
import 'package:formation_flutter/screens/auth/register_page.dart';
import 'package:formation_flutter/screens/product/product_page.dart';
import 'package:formation_flutter/services/auth_service.dart';
import 'package:provider/provider.dart';

void main(){

  runApp(
    // AuthService disponible dans tout l'arbre de widgets
    ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yukka',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(
          0xFFF5F6F8,
        ), // Fond grisé pour cartes
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F6F8),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF001F5B)),
          titleTextStyle: TextStyle(
            color: Color(0xFF001F5B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        extensions: [OffThemeExtension.defaultValues()],
        fontFamily: 'Avenir',
        dividerTheme: DividerThemeData(color: AppColors.grey2, space: 1.0),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF001F5B)),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: AppColors.blue,
          unselectedItemColor: AppColors.grey2,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          indicatorColor: AppColors.blue,
        ),
      ),

      // ── Page de démarrage ─────────────────────────────────────
      // Si l'utilisateur est déjà connecté (token valide) → /home
      // Sinon → /login
      home: Consumer<AuthService>(
        builder: (_, auth, __) =>
            auth.isLoggedIn ? const ProductPage() : const LoginPage(),
      ),

      // ── Routes nommées ────────────────────────────────────────
      routes: {
        '/login':    (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/home':     (_) => const ProductPage(),
      },
    );
  }
}