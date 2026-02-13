import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/user_service.dart';

/// Assistance IA en chat — renvoi vers agent réel si besoin
class AiChatSupportScreen extends StatefulWidget {
  const AiChatSupportScreen({super.key});

  @override
  State<AiChatSupportScreen> createState() => _AiChatSupportScreenState();
}

class _AiChatSupportScreenState extends State<AiChatSupportScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _loading = false;
  bool _agentRequested = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      text: "Bonjour ! Je suis l'assistant IA Yadeli. Comment puis-je vous aider ?",
      isUser: false,
      time: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true, time: DateTime.now()));
      _loading = true;
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 800));

    final response = _getAiResponse(text);

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(text: response, isUser: false, time: DateTime.now()));
      _loading = false;
    });
    _scrollToBottom();
  }

  String _getAiResponse(String userInput) {
    final lower = userInput.toLowerCase();
    if (lower.contains('agent') || lower.contains('humain') || lower.contains('réel') || lower.contains('parler') || lower.contains('support')) {
      return "Je peux vous mettre en contact avec un agent Yadeli. Souhaitez-vous être appelé, contacté par email/SMS ou via WhatsApp ? Dites-moi votre préférence.";
    }
    if (lower.contains('annuler') || lower.contains('annulation')) {
      return "Pour annuler une course : allez dans Historique > sélectionnez le trajet > Modifier/Annuler. Si la course est déjà en cours ou confirmée, l'annulation n'est pas possible sans signaler un problème. Des frais peuvent s'appliquer en cas d'annulation sans motif.";
    }
    if (lower.contains('paiement') || lower.contains('payer')) {
      return "Yadeli accepte : Cash, Airtel Money, MTN MoMo à la livraison ou au terme de la course.";
    }
    if (lower.contains('livraison') || lower.contains('pharmacie') || lower.contains('alimentaire')) {
      return "Nous proposons : Pharmacie, Alimentaire, Boutique, Cosmétique, Marché et Livraison colis. Choisissez le service dans l'application.";
    }
    if (lower.contains('pourboire')) {
      return "Vous pouvez ajouter un pourboire au chauffeur/livreur après la course, dans les détails du trajet.";
    }
    if (lower.contains('facture') || lower.contains('récap')) {
      return "Dans l'historique des trajets, ouvrez un trajet et cliquez sur 'Envoyer récap' ou 'Voir facture' pour recevoir le récapitulatif par mail/SMS.";
    }
    return "Je n'ai pas compris. Tapez 'agent' pour parler à un conseiller, ou posez une question sur : annulation, paiement, livraison, pourboire, facture.";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _requestAgent() async {
    setState(() => _agentRequested = true);
    final languages = await UserService.getUserLanguages();
    final langStr = languages.isNotEmpty ? languages.join(', ') : 'FR';

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Contacter un agent (langue(s): $langStr)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700])),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text("Appel"),
                onTap: () async {
                  Navigator.pop(context);
                  await launchUrl(Uri.parse('tel:+242064442211'), mode: LaunchMode.externalApplication);
                },
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Colors.green),
                title: const Text("Email"),
                onTap: () async {
                  Navigator.pop(context);
                  await launchUrl(Uri.parse('mailto:support@yadeli.cg'), mode: LaunchMode.externalApplication);
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.green),
                title: const Text("WhatsApp"),
                onTap: () async {
                  Navigator.pop(context);
                  await launchUrl(Uri.parse('https://wa.me/242064442211'), mode: LaunchMode.externalApplication);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sms, color: Colors.green),
                title: const Text("SMS"),
                onTap: () async {
                  Navigator.pop(context);
                  await launchUrl(Uri.parse('sms:+242064442211'), mode: LaunchMode.externalApplication);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assistance IA"),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _requestAgent,
            tooltip: "Parler à un agent",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(children: [CircularProgressIndicator(strokeWidth: 2), SizedBox(width: 12), Text("Réflexion...")]),
                  );
                }
                final m = _messages[i];
                return Align(
                  alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: m.isUser ? Colors.green[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.text, style: const TextStyle(fontSize: 15)),
                        const SizedBox(height: 4),
                        Text("${m.time.hour.toString().padLeft(2, '0')}:${m.time.minute.toString().padLeft(2, '0')}", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Votre question...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _loading ? null : _sendMessage,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(backgroundColor: Colors.green[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  _ChatMessage({required this.text, required this.isUser, required this.time});
}
