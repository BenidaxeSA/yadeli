import 'package:flutter/material.dart';
import '../services/locale_service.dart';

/// Langues: Français, English, Lingala, Kituba — Congo (drapeau vert, jaune, rouge)
enum AppLocale {
  fr('fr', 'Français'),
  en('en', 'English'),
  ln('ln', 'Lingala'),
  kg('kg', 'Kituba');

  const AppLocale(this.code, this.label);
  final String code;
  final String label;

  static AppLocale fromCode(String? c) {
    if (c == null) return AppLocale.fr;
    return AppLocale.values.firstWhere((e) => e.code == c, orElse: () => AppLocale.fr);
  }
}

class AppLocalizations {
  final AppLocale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) => _l(context);

  static AppLocalizations _l(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(AppLocale.fr);
  }

  // --- GÉNÉRAL ---
  String get appName => _s('appName');
  String get readyLetsGo => _s('readyLetsGo');
  String get whereWeGo => _s('whereWeGo');
  String get search => _s('search');
  String get home => _s('home');
  String get trips => _s('trips');
  String get account => _s('account');
  String get logout => _s('logout');
  String get back => _s('back');
  String get save => _s('save');
  String get cancel => _s('cancel');
  String get ok => _s('ok');

  // --- AUTH ---
  String get login => _s('login');
  String get signUp => _s('signUp');
  String get createAccount => _s('createAccount');
  String get fullName => _s('fullName');
  String get email => _s('email');
  String get password => _s('password');
  String get phone => _s('phone');
  String get gender => _s('gender');
  String get male => _s('male');
  String get female => _s('female');
  String get alreadyMember => _s('alreadyMember');
  String get newUser => _s('newUser');
  String get verifyPhone => _s('verifyPhone');
  String get takePhoto => _s('takePhoto');
  String get choosePhoto => _s('choosePhoto');

  // --- NAV ---
  String get payment => _s('payment');
  String get promotions => _s('promotions');
  String get support => _s('support');
  String get settings => _s('settings');
  String get about => _s('about');
  String get proProfile => _s('proProfile');
  String get tripHistory => _s('tripHistory');

  // --- SETTINGS ---
  String get language => _s('language');
  String get notifications => _s('notifications');
  String get privacy => _s('privacy');

  // --- PAYMENT ---
  String get airtelMoney => _s('airtelMoney');
  String get mtnMomo => _s('mtnMomo');
  String get cash => _s('cash');
  String get creditCard => _s('creditCard');
  String get playStore => _s('playStore');
  String get appleStore => _s('appleStore');

  String _s(String key) {
    final m = _strings[locale] ?? _strings[AppLocale.fr]!;
    return m[key] ?? key;
  }

  static final Map<AppLocale, Map<String, String>> _strings = {
    AppLocale.fr: {
      'appName': 'Yadeli',
      'readyLetsGo': "Prêt ? C'est parti !",
      'whereWeGo': 'Où allons-nous ?',
      'search': 'Rechercher',
      'home': 'Accueil',
      'trips': 'Trajets',
      'account': 'Compte',
      'logout': 'Déconnexion',
      'back': 'Retour',
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'ok': 'OK',
      'login': 'Connexion',
      'signUp': "S'inscrire",
      'createAccount': 'Créer un compte',
      'fullName': 'Nom complet',
      'email': 'Email',
      'password': 'Mot de passe',
      'phone': 'Téléphone',
      'gender': 'Genre',
      'male': 'Homme',
      'female': 'Femme',
      'alreadyMember': 'Déjà membre ?',
      'newUser': 'Nouveau chez Yadeli ?',
      'verifyPhone': 'Vérifier le numéro',
      'takePhoto': 'Prendre une photo',
      'choosePhoto': 'Choisir une photo',
      'payment': 'Paiement',
      'promotions': 'Promotions',
      'support': 'Support',
      'settings': 'Paramètres',
      'about': 'À propos',
      'proProfile': 'Profil professionnel',
      'tripHistory': 'Historique des trajets',
      'language': 'Langue',
      'notifications': 'Notifications',
      'privacy': 'Confidentialité',
      'airtelMoney': 'Airtel Money',
      'mtnMomo': 'MTN MoMo',
      'cash': 'Espèces (Cash)',
      'creditCard': 'Carte bancaire',
      'playStore': 'Google Play',
      'appleStore': 'App Store',
    },
    AppLocale.en: {
      'appName': 'Yadeli',
      'readyLetsGo': "Ready? Let's go!",
      'whereWeGo': 'Where are we going?',
      'search': 'Search',
      'home': 'Home',
      'trips': 'Trips',
      'account': 'Account',
      'logout': 'Log out',
      'back': 'Back',
      'save': 'Save',
      'cancel': 'Cancel',
      'ok': 'OK',
      'login': 'Login',
      'signUp': 'Sign up',
      'createAccount': 'Create account',
      'fullName': 'Full name',
      'email': 'Email',
      'password': 'Password',
      'phone': 'Phone',
      'gender': 'Gender',
      'male': 'Male',
      'female': 'Female',
      'alreadyMember': 'Already a member?',
      'newUser': 'New to Yadeli?',
      'verifyPhone': 'Verify phone',
      'takePhoto': 'Take photo',
      'choosePhoto': 'Choose photo',
      'payment': 'Payment',
      'promotions': 'Promotions',
      'support': 'Support',
      'settings': 'Settings',
      'about': 'About',
      'proProfile': 'Professional profile',
      'tripHistory': 'Trip history',
      'language': 'Language',
      'notifications': 'Notifications',
      'privacy': 'Privacy',
      'airtelMoney': 'Airtel Money',
      'mtnMomo': 'MTN MoMo',
      'cash': 'Cash',
      'creditCard': 'Credit card',
      'playStore': 'Google Play',
      'appleStore': 'App Store',
    },
    AppLocale.ln: {
      'appName': 'Yadeli',
      'readyLetsGo': 'Esengeli? Tokende!',
      'whereWeGo': 'Tókende wapi?',
      'search': 'Koluka',
      'home': 'Ndako',
      'trips': 'Mbisalelo',
      'account': 'Konti',
      'logout': 'Kobima',
      'back': 'Kozonga',
      'save': 'Kobomba',
      'cancel': 'Kozongisa',
      'ok': 'Malamu',
      'login': 'Kokota',
      'signUp': 'Kolanda koti',
      'createAccount': 'Kolonga koti',
      'fullName': 'Nkombo ya mobimba',
      'email': 'Email',
      'password': 'Banda ya kokota',
      'phone': 'Téléphone',
      'gender': 'Moke',
      'male': 'Mobali',
      'female': 'Mwasi',
      'alreadyMember': 'Ozali na koti?',
      'newUser': 'Mokli na Yadeli?',
      'verifyPhone': 'Kokakatisa nómba',
      'takePhoto': 'Kozua foto',
      'choosePhoto': 'Koluka foto',
      'payment': 'Lifuta',
      'promotions': 'Promotions',
      'support': 'Lisalisi',
      'settings': 'Paramètres',
      'about': 'Mambí',
      'proProfile': 'Profil ya mosala',
      'tripHistory': 'Historique ya mbisalelo',
      'language': 'Lokota',
      'notifications': 'Notifikations',
      'privacy': 'Confidentialité',
      'airtelMoney': 'Airtel Money',
      'mtnMomo': 'MTN MoMo',
      'cash': 'Mbongo',
      'creditCard': 'Karte ya banki',
      'playStore': 'Google Play',
      'appleStore': 'App Store',
    },
    AppLocale.kg: {
      'appName': 'Yadeli',
      'readyLetsGo': 'Ku kondowa? Tudya!',
      'whereWeGo': 'Tudya wapi?',
      'search': 'Koluka',
      'home': 'Ndaku',
      'trips': 'Mbisalelo',
      'account': 'Konti',
      'logout': 'Kubasika',
      'back': 'Kuvutuka',
      'save': 'Kutula',
      'cancel': 'Kufutuka',
      'ok': 'Yo',
      'login': 'Kota',
      'signUp': 'Sanya koti',
      'createAccount': 'Kanga koti',
      'fullName': 'Zina ya mutu',
      'email': 'Email',
      'password': 'Mfumu',
      'phone': 'Téléphone',
      'gender': 'Bukala',
      'male': 'Bakala',
      'female': 'Nkento',
      'alreadyMember': 'Ozali na koti?',
      'newUser': 'Mukli na Yadeli?',
      'verifyPhone': 'Kukatangisa nómba',
      'takePhoto': 'Kubaka foto',
      'choosePhoto': 'Koluka foto',
      'payment': 'Lifuta',
      'promotions': 'Promotions',
      'support': 'Lisalisi',
      'settings': 'Paramètres',
      'about': 'Mambí',
      'proProfile': 'Profil ya mosala',
      'tripHistory': 'Historique ya mbisalelo',
      'language': 'Lokota',
      'notifications': 'Notifikations',
      'privacy': 'Confidentialité',
      'airtelMoney': 'Airtel Money',
      'mtnMomo': 'MTN MoMo',
      'cash': 'Mbongo',
      'creditCard': 'Karte ya banki',
      'playStore': 'Google Play',
      'appleStore': 'App Store',
    },
  };
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final appLoc = LocaleService.instance.locale;
    return AppLocalizations(appLoc);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
