import 'package:flutter/material.dart';

/// Écran détaillé de paiement type Uber : saisie, vérification, validation, confirmation
class PaymentDetailScreen extends StatefulWidget {
  final String methodId;
  final String methodTitle;
  final IconData methodIcon;

  const PaymentDetailScreen({
    super.key,
    required this.methodId,
    required this.methodTitle,
    required this.methodIcon,
  });

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  int _step = 1;
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step < 4) setState(() => _step++);
  }

  void _prevStep() {
    if (_step > 1) setState(() => _step--);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.methodTitle),
        backgroundColor: Colors.green[700],
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Stepper(
        currentStep: _step - 1,
        onStepContinue: _nextStep,
        onStepCancel: _prevStep,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                  child: Text(_step == 4 ? "Confirmer" : "Continuer"),
                ),
                if (_step > 1) ...[
                  const SizedBox(width: 12),
                  TextButton(onPressed: details.onStepCancel, child: const Text("Retour")),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text("1. Saisie des informations"),
            content: _buildStep1(),
            isActive: _step >= 1,
            state: _step > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text("2. Vérification"),
            content: _buildStep2(),
            isActive: _step >= 2,
            state: _step > 2 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text("3. Validation"),
            content: _buildStep3(),
            isActive: _step >= 3,
            state: _step > 3 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text("4. Confirmation"),
            content: _buildStep4(),
            isActive: _step >= 4,
            state: StepState.indexed,
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    const methods = ['Airtel', 'MTN', 'Card', 'PlayStore', 'AppleStore', 'Cash'];
    if (widget.methodId == 'Cash') {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.payments, size: 48, color: Colors.green),
              SizedBox(height: 12),
              Text("Paiement en espèces à la livraison.", style: TextStyle(fontSize: 16)),
              Text("Aucune information à saisir.", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    if (methods.contains(widget.methodId) && (widget.methodId == 'Airtel' || widget.methodId == 'MTN')) {
      return Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Numéro ${widget.methodId}",
                hintText: "06 123 45 67",
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => v == null || v.length < 8 ? "Numéro invalide" : null,
            ),
          ],
        ),
      );
    }
    if (widget.methodId == 'Card') {
      return Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _cardController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Numéro de carte",
                hintText: "4111 1111 1111 1111",
                prefixIcon: const Icon(Icons.credit_card),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => v == null || v.replaceAll(' ', '').length < 16 ? "Numéro invalide" : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    decoration: InputDecoration(
                      labelText: "Expiration (MM/AA)",
                      hintText: "12/28",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => v == null || v.length < 5 ? "Format invalide" : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "CVV",
                      hintText: "123",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => v == null || v.length < 3 ? "CVV invalide" : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    if (widget.methodId == 'PlayStore' || widget.methodId == 'AppleStore') {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(widget.methodIcon, size: 48, color: Colors.green),
              const SizedBox(height: 12),
              Text("Paiement via ${widget.methodTitle}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Le paiement sera débité de votre compte ${widget.methodTitle} associé à cet appareil.", style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildStep2() {
    if (widget.methodId == 'Cash') return const Text("Aucune vérification requise.");
    if (widget.methodId == 'Airtel' || widget.methodId == 'MTN') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Un code de vérification a été envoyé au ${_phoneController.text.isEmpty ? '***' : _phoneController.text}"),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Code reçu (ex: 123456)",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Code renvoyé !"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating)),
            child: const Text("Renvoyer le code"),
          ),
        ],
      );
    }
    if (widget.methodId == 'Card') {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Vérification 3D Secure", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Un code a été envoyé à votre téléphone enregistré pour valider le paiement."),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(labelText: "Code 3D Secure", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
        ),
      );
    }
    return const Text("Vérification en cours...");
  }

  Widget _buildStep3() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified_user, color: Colors.green[700], size: 40),
                const SizedBox(width: 12),
                const Expanded(child: Text("Informations validées", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.methodId == 'Airtel' || widget.methodId == 'MTN')
              Text("Numéro vérifié : ${_phoneController.text}"),
            if (widget.methodId == 'Card')
              Text("Carte **** **** **** ${_cardController.text.length > 4 ? _cardController.text.substring(_cardController.text.length - 4) : '****'}"),
            if (widget.methodId == 'PlayStore' || widget.methodId == 'AppleStore')
              Text("Compte ${widget.methodTitle} vérifié"),
            if (widget.methodId == 'Cash') const Text("Paiement à la livraison confirmé."),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4() {
    return Card(
      color: Colors.green.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green[700]),
            const SizedBox(height: 16),
            Text("Paiement ${widget.methodTitle} enregistré !", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800])),
            const SizedBox(height: 8),
            const Text("Ce mode de paiement sera utilisé par défaut pour vos prochains trajets."),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mode ${widget.methodTitle} défini par défaut"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
              child: const Text("Terminer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
