import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // Commenté pour le Mode Test
import 'map_order_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;

  // 🔹 FONCTION DE CONNEXION (MODE TEST)
  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);

    // Simulation d'un délai réseau pour l'UX
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);

      // 🚀 REDIRECTION VERS LA CARTE
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MapOrderScreen()),
      );

      _showSnackBar("Connexion réussie (Mode Test)", Colors.green);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 HEADER AVEC LE DESIGN COURBÉ ET DÉGRADÉ YADELI
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green.shade700, Colors.green.shade400],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(80),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_taxi, size: 70, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text(
                    "YADELI",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    "Votre trajet, notre priorité",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isSignUp ? "Créer un compte" : "Connexion",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // Champ Email
                  _buildTextField(
                    _emailController, 
                    "Email", 
                    Icons.email_outlined, 
                    false
                  ),
                  const SizedBox(height: 15),
                  
                  // Champ Mot de passe
                  _buildTextField(
                    _passwordController, 
                    "Mot de passe", 
                    Icons.lock_outline, 
                    true
                  ),
                  
                  const SizedBox(height: 30),

                  // 🔹 BOUTON PRINCIPAL YADELI
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isSignUp ? "REJOINDRE YADELI" : "SE CONNECTER", 
                            style: const TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 16
                            ),
                          ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 LIEN POUR BASCULER ENTRE LOGIN ET SIGNUP
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _isSignUp = !_isSignUp),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black54, fontSize: 14),
                          children: [
                            TextSpan(
                              text: _isSignUp ? "Déjà membre ? " : "Nouveau chez Yadeli ? "
                            ),
                            TextSpan(
                              text: _isSignUp ? "Se connecter" : "Créer un compte",
                              style: const TextStyle(
                                color: Colors.green, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 WIDGET RÉUTILISABLE POUR LES CHAMPS DE TEXTE
  Widget _buildTextField(
      TextEditingController controller, 
      String label, 
      IconData icon, 
      bool isPassword
  ) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green.shade700),
        filled: true,
        fillColor: Colors.grey[50],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }
}