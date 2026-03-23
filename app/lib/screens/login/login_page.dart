import 'package:flutter/material.dart';
import 'package:formation_flutter/custom_button.dart';
import 'package:formation_flutter/custom_input_field.dart';
import 'package:formation_flutter/services/auth_service.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    final authService = context.read<AuthService>();
    final success = await authService.login(email, password);

    if (!mounted) return;

    if (success) {
      // Redirige vers la page principale en remplaçant la pile
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authService.errorMessage ?? 'Erreur de connexion.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthService>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Connexion',
          style: TextStyle(color: Color(0xFF001F5B)),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Connexion',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF001F5B),
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
                isLoading: false,
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