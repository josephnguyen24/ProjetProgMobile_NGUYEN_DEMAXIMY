import 'package:flutter/material.dart';
import 'package:formation_flutter/custom_button.dart';
import 'package:formation_flutter/widget/custom_input_field.dart';
import 'package:formation_flutter/services/auth_service.dart';
import 'package:formation_flutter/widget/custom_input_field.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le mot de passe doit faire au moins 8 caractères.'),
        ),
      );
      return;
    }

    final authService = context.read<AuthService>();
    final success = await authService.register(email, password);

    if (!mounted) return;

    if (success) {
      // Inscription + connexion automatique → page principale
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authService.errorMessage ?? 'Erreur d\'inscription.'),
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
          'Inscription',
          style: TextStyle(color: Color(0xFF001F5B)),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Inscription',
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
                hintText: 'Mot de passe (8 caractères min.)',
                isPassword: true,
                controller: _passwordController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _registerUser(),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: "S'inscrire",
                onPressed: _registerUser,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}