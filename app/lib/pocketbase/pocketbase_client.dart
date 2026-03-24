import 'package:pocketbase/pocketbase.dart';

/// Point d'accès unique au serveur PocketBase.
///
/// Adaptez [baseUrl] selon votre environnement :
///   - Web / Firefox sur le même PC  → http://127.0.0.1:8090
///   - Émulateur Android             → http://10.0.2.2:8090
///   - Appareil physique             → http://<IP_LAN_DU_PC>:8090
class PocketBaseClient {
  PocketBaseClient._();

  static const String baseUrl = 'http://37.67.150.3:8090';

  static final PocketBase instance = PocketBase(baseUrl);
}