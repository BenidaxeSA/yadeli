import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Un gris très léger pour faire ressortir les éléments blancs
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Compte", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 CARD PROFIL (MODERNE)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFFEDF1F7),
                        child: Icon(Icons.person, size: 50, color: Colors.green),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(width: 20),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Utilisateur Yadeli", 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text("+242 06 444 22 11", 
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),

            // 🔹 SECTION : INFORMATIONS PERSONNELLES
            _buildSectionTitle("Informations"),
            _buildAccountOption(
              icon: Icons.badge_outlined, 
              title: "Infos personnelles", 
              subtitle: "Nom, Prénom, Email",
              onTap: () {
                // TODO: Naviguer vers l'édition du profil
                print("Ouvrir l'édition du profil");
              },
            ),

            // 🔹 SECTION : PAIEMENTS & OFFRES
            _buildSectionTitle("Finances"),
            _buildAccountOption(
              icon: Icons.account_balance_wallet_outlined, 
              title: "Paiement", 
              subtitle: "Airtel Money, MTN MoMo, Cash",
              onTap: () {},
            ),
            _buildAccountOption(
              icon: Icons.confirmation_number_outlined, 
              title: "Promotions", 
              subtitle: "Codes promos disponibles",
              onTap: () {},
            ),

            // 🔹 SECTION : PRÉFÉRENCES & AIDE
            _buildSectionTitle("Général"),
            _buildAccountOption(
              icon: Icons.work_outline, 
              title: "Profil professionnel", 
              subtitle: "Facturation entreprise",
              onTap: () {},
            ),
            _buildAccountOption(
              icon: Icons.settings_outlined, 
              title: "Paramètres", 
              subtitle: "Confidentialité, Langue",
              onTap: () {},
            ),
            _buildAccountOption(
              icon: Icons.help_outline, 
              title: "Support", 
              subtitle: "Aide et contact d'urgence",
              onTap: () {},
            ),

            const SizedBox(height: 40),
            
            // 🔹 BOUTON DÉCONNEXION (DESIGN ÉPURÉ)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Déconnexion", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget pour les titres de section
  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  // Widget pour les options (modernisé)
  Widget _buildAccountOption({
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required VoidCallback onTap
  }) {
    return Container(
      color: Colors.white,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.green, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black26),
      ),
    );
  }
}