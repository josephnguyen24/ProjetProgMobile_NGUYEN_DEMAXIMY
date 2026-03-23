import 'package:flutter/material.dart';
import 'package:formation_flutter/model/rappel.dart';
import 'package:url_launcher/url_launcher.dart';

/// Écran de détail d'un rappel produit.
class RappelDetailScreen extends StatelessWidget {
  const RappelDetailScreen({super.key, required this.rappel});

  final Rappel rappel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF001F5B)),
        title: const Text(
          'Rappel produit',
          style: TextStyle(
            color: Color(0xFF001F5B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          if (rappel.lienPdf != null)
            IconButton(
              tooltip: 'Ouvrir la fiche PDF',
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: () async {
                final uri = Uri.parse(rappel.lienPdf!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.reply, textDirection: TextDirection.rtl),
            onPressed: () {
              // TODO: Implémenter le partage
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image du produit
            if (rappel.photoUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Image.network(
                    rappel.photoUrl!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),

            // Nom & marque du produit
            if (rappel.libelleProduit != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  rappel.libelleProduit!.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001F5B),
                  ),
                ),
              ),
            if (rappel.marque != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 20.0),
                child: Text(
                  rappel.marque!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ),

            // Sections de détails
            _Section(
              title: 'Dates de commercialisation',
              content: _datesContent(),
            ),
            _Section(title: 'Distributeurs', content: rappel.distributeurs),
            _Section(
              title: 'Zone géographique concernée',
              content: rappel.zoneGeographique,
            ),
            _Section(title: 'Motif du rappel', content: rappel.motifRappel),
            _Section(
              title: 'Risques encourus',
              content: rappel.risquesEncouirus,
            ),

            // Autres données utiles issues de PocketBase
            _Section(title: 'Conduite à tenir', content: _conduiteFormatted()),
            _Section(
              title: 'Informations complémentaires',
              content: rappel.informationsComplementaires,
            ),
            if (rappel.numeroContact != null)
              _Section(
                title: 'Numéro de contact',
                content: rappel.numeroContact,
              ),
            _Section(
              title: 'Modalités de compensation',
              content: rappel.modalitesCompensation,
            ),

            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  String? _datesContent() {
    final debut = rappel.dateDebutCommercialisation;
    final fin = rappel.dateFinCommercialisation;
    if (debut == null && fin == null) return null;
    final parts = <String>[];
    if (debut != null) parts.add('Du $debut');
    if (fin != null) parts.add('au $fin');
    return parts.join(' ');
  }

  /// Transforme "a|b|c" en liste à puces.
  String? _conduiteFormatted() {
    final raw = rappel.conduiteATenir;
    if (raw == null) return null;
    return raw
        .split('|')
        .map((e) => '• ${e.trim()}')
        .where((e) => e.length > 2)
        .join('\n');
  }
}

// ── Widget section ──────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.content});

  final String title;
  final String? content;

  @override
  Widget build(BuildContext context) {
    if (content == null || content!.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Le titre sur fond gris clair
        Container(
          color: const Color(0xFFF8F9FA),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF001F5B),
            ),
          ),
        ),
        // Le contenu sur fond blanc
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: Text(
            content!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
