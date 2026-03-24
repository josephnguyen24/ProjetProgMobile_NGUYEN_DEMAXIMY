import 'package:flutter/material.dart';
import 'package:formation_flutter/widget/custom_button.dart';
import 'package:formation_flutter/widget/custom_input_field.dart';
import 'package:formation_flutter/services/auth_service.dart';
import 'package:formation_flutter/services/favorite_service.dart';
import 'package:formation_flutter/services/scan_service.dart';

import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Veuillez remplir tous les champs.');
      return;
    }

    final authService = context.read<AuthService>();
    final success = await authService.login(email, password);

    if (!mounted) return;

    if (success) {
      // Pré-charge les scans et les favoris de l'utilisateur
      await Future.wait([
        context.read<ScanService>().load(force: true),
        context.read<FavoriteService>().load(force: true),
      ]);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showSnack(
        authService.errorMessage ?? 'Erreur de connexion.',
        isError: true,
      );
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthService>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Connexion',
          style: TextStyle(color: Color(0xFF080040)),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Connexion',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF080040),
                  letterSpacing: -0.48,
                ),
              ),
              const SizedBox(height: 50),
              CustomInputField(
                icon: Icons.email,
                hintText: 'Adresse email',
                controller: _emailController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 15),
              CustomInputField(
                icon: Icons.lock,
                hintText: 'Mot de passe',
                isPassword: true,
                controller: _passwordController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _loginUser(),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Créer un compte',
                onPressed: () => Navigator.pushNamed(context, '/register'),
              ),
              const SizedBox(height: 15),
              CustomButton(
                text: 'Se connecter',
                onPressed: _loginUser,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
