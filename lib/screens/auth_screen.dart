import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'map_order_screen.dart';
import '../services/user_service.dart';
import '../widgets/congo_flag.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  String _selectedGender = 'homme';
  final List<String> _selectedLanguages = ['FR'];

  static const _availableLanguages = ['FR', 'EN', 'Lingala', 'Kituba'];

  Future<void> _saveUserProfile({required String name, required String phone, String? email}) async {
    await UserService.saveUser(
      name: name,
      phone: phone,
      gender: _selectedGender,
      email: email,
      languages: _selectedLanguages,
    );
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Email et mot de passe requis", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      if (_isSignUp) {
        // Création de compte — enregistrement dans Supabase
        final res = await supabase.auth.signUp(email: email, password: password);
        if (res.user == null) {
          if (mounted) _showSnackBar("Erreur lors de la création du compte", Colors.red);
          return;
        }
        final phone = _phoneController.text.trim().replaceAll(RegExp(r'\s'), '');
        final validPhone = phone.isNotEmpty ? (phone.startsWith('+') ? phone : '+242 $phone') : '+242 06 444 22 11';
        await _saveUserProfile(
          name: _nameController.text.isNotEmpty ? _nameController.text : 'Utilisateur Yadeli',
          phone: validPhone,
          email: email,
        );
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MapOrderScreen()));
          _showSnackBar("Compte créé avec succès. Bienvenue !", Colors.green);
        }
      } else {
        // Connexion — uniquement si le compte existe déjà
        await supabase.auth.signInWithPassword(email: email, password: password);
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MapOrderScreen()));
          _showSnackBar("Connexion réussie", Colors.green);
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        if (e.message.contains('Invalid login credentials') || e.message.contains('invalid_credentials')) {
          _showSnackBar("Compte inexistant. Créez un compte pour continuer.", Colors.orange);
          setState(() => _isSignUp = true);
        } else {
          _showSnackBar(e.message, Colors.red);
        }
      }
    } catch (e) {
      if (mounted) _showSnackBar("Erreur: ${e.toString().split('\n').first}", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.google);
      // OAuth ouvre le navigateur. Au retour, onAuthStateChange met à jour la session.
      // Le StreamBuilder dans AuthRedirect affichera MapOrderScreen automatiquement.
      if (mounted) {
        _showSnackBar("Complétez la connexion dans le navigateur", Colors.green);
      }
    } on AuthException catch (e) {
      if (mounted) _showSnackBar(e.message, Colors.red);
    } catch (e) {
      if (mounted) _showSnackBar("Google : configurez le fournisseur dans Supabase (Authentication > Providers)", Colors.orange);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_taxi, size: 70, color: Colors.white),
                      const SizedBox(width: 16),
                      CongoFlag(width: 48, height: 32),
                    ],
                  ),
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
                  
                  if (_isSignUp) ...[
                    _buildTextField(_nameController, "Nom complet", Icons.person_outline, false),
                    const SizedBox(height: 15),
                    _buildTextField(_phoneController, "Téléphone (ex: 06 444 22 11)", Icons.phone, false, keyboardType: TextInputType.phone),
                    const SizedBox(height: 15),
                    _buildGenderSelector(),
                    const SizedBox(height: 15),
                    _buildLanguagesSelector(),
                    const SizedBox(height: 15),
                  ],
                  _buildTextField(_emailController, "Email", Icons.email_outlined, false),
                  const SizedBox(height: 15),
                  _buildTextField(_passwordController, "Mot de passe", Icons.lock_outline, true),
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

                  const SizedBox(height: 16),

                  // 🔹 CONNEXION AVEC GOOGLE
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      icon: Image.network('https://www.google.com/favicon.ico', width: 20, height: 20, errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24)),
                      label: const Text("Créer un compte avec Google"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[800],
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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

  Widget _buildLanguagesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Langues parlées (pour le support)", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableLanguages.map((lang) {
            final selected = _selectedLanguages.contains(lang);
            return FilterChip(
              label: Text(lang),
              selected: selected,
              onSelected: (v) {
                setState(() {
                  if (v) {
                    _selectedLanguages.add(lang);
                  } else {
                    _selectedLanguages.remove(lang);
                  }
                  if (_selectedLanguages.isEmpty) _selectedLanguages.add('FR');
                });
              },
              selectedColor: Colors.green[100],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Genre", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text("Homme"),
                value: 'homme',
                groupValue: _selectedGender,
                onChanged: (v) => setState(() => _selectedGender = v!),
                activeColor: Colors.green[700],
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text("Femme"),
                value: 'femme',
                groupValue: _selectedGender,
                onChanged: (v) => setState(() => _selectedGender = v!),
                activeColor: Colors.green[700],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool isPassword, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
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