import 'package:flutter/material.dart';
import 'package:formation_flutter/model/dummy_product.dart';
import 'package:formation_flutter/widget/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Mis à 'false' pour afficher l'écran vide au lancement
  bool hasScans = false;
  List<DummyProduct> scannedProducts = dummyProducts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes scans'),
        actions: [
          if (hasScans)
            IconButton(
              icon: const Icon(Icons.qr_code_scanner, size: 28),
              onPressed: () {},
            ),
          IconButton(
            icon: const Icon(Icons.star, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, size: 28),
            onPressed: () {
              // Déconnexion simulée : on retourne à l'écran de login
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: hasScans ? _buildHistoryView() : _buildEmptyView(),
    );
  }

  // Vue avec l'historique
  Widget _buildHistoryView() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: scannedProducts.length,
      itemBuilder: (context, index) {
        return ProductCard(product: scannedProducts[index]);
      },
    );
  }

  // Vue quand l'historique est vide
  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_basket,
                size: 80,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "Vous n'avez pas encore\nscanné de produit",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF001F5B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Simule un scan et affiche les données
                  setState(() {
                    hasScans = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFDB912),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'COMMENCER',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001F5B),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
