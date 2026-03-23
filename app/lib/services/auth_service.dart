import 'package:flutter/material.dart';
import 'package:formation_flutter/pocketbase/pocketbase_client.dart';
import 'package:pocketbase/pocketbase.dart';

/// Gère l'état d'authentification de l'application.
///
/// États exposés :
///   - [isLoggedIn]   : l'utilisateur est authentifié
///   - [currentUser]  : le modèle RecordModel du user connecté (ou null)
///   - [isLoading]    : une opération async est en cours
///   - [errorMessage] : message d'erreur de la dernière opération (ou null)
class AuthService extends ChangeNotifier {
  final PocketBase _pb = PocketBaseClient.instance;

  RecordModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // ── Getters ─────────────────────────────────────────────────

  bool get isLoggedIn => _pb.authStore.isValid;
  RecordModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Connexion ────────────────────────────────────────────────

  /// Tente une connexion avec [email] et [password].
  /// Retourne [true] en cas de succès.
  Future<bool> login(String email, String password) async {
    _setLoading(true);

    try {
      final authData = await _pb
          .collection('users')
          .authWithPassword(email.trim(), password);

      _currentUser = authData.record;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ClientException catch (e) {
      _errorMessage = _friendlyError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Inscription ──────────────────────────────────────────────

  /// Crée un nouveau compte avec [email] et [password].
  /// Retourne [true] en cas de succès (le user est aussi connecté).
  Future<bool> register(String email, String password) async {
    _setLoading(true);

    try {
      // 1. Création du compte
      await _pb.collection('users').create(body: {
        'email': email.trim(),
        'password': password,
        'passwordConfirm': password,
        'name': email.split('@').first, // nom par défaut
      });

      // 2. Connexion automatique après inscription
      return await login(email, password);
    } on ClientException catch (e) {
      _errorMessage = _friendlyError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Déconnexion ──────────────────────────────────────────────

  void logout() {
    _pb.authStore.clear();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Helpers privés ───────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Traduit les erreurs PocketBase en messages lisibles.
  String _friendlyError(ClientException e) {
    final status = e.statusCode;
    if (status == 400) return 'Email ou mot de passe invalide.';
    if (status == 401) return 'Non autorisé. Vérifiez vos identifiants.';
    if (status == 403) return 'Accès refusé.';
    if (status == 404) return 'Utilisateur introuvable.';
    return 'Erreur réseau (${e.statusCode}). Vérifiez que PocketBase est lancé.';
  }
}