# Rapport de test – Projet Yadeli

> **Mise à jour** : Le backend Supabase d'origine n'existe plus. Voir `CONFIGURATION_BACKEND_SUPABASE.md` pour créer votre propre backend.

*Date : 12 février 2025*  
*Contexte : Analyse statique et revue de code (Flutter non disponible en CLI)*

---

## I. Vue d’ensemble du projet

**Yadeli** est une plateforme de transport et livraison à Brazzaville (Congo) :
- **Frontend** : Flutter (Supabase, Mapbox)
- **Backend** : Supabase (Edge Functions, PostgreSQL)
- **Fonctionnalités** : Auth, carte Mapbox, commandes (Moto, Pharmacie), compte utilisateur

---

## II. Problèmes critiques

### 1. Incohérence Frontend ↔ Backend (commande)

L’app Flutter envoie :
```dart
body: {
  'client_id': ..., 'category': ..., 'total_price': ...,
  'pickup_data': {'address': 'Ma Campagne'},
  'delivery_data': {'address': 'Poto-Poto'},
}
```

L’Edge Function `create-order` attend :
```ts
const { game_id, user_id, total_price } = await req.json();
// Insère dans orders: game_id, user_id, total_price, status
```

**Impact** : Les commandes échoueront (champs manquants, nommage différent).

**Suggestion** : Aligner le contrat API :
- Option A : Adapter l’Edge Function pour accepter `client_id`, `category`, `pickup_data`, `delivery_data` et les colonnes correspondantes en base.
- Option B : Adapter le Flutter pour envoyer `user_id` au lieu de `client_id` et définir clairement le schéma attendu.

---

### 2. Migrations SQL vides

Les fichiers suivants sont vides :
- `backend_app/supabase/migrations/20251223005102_init_schema.sql`
- `backend_app/supabase/migrations/20251223014306_create_orders_table.sql`

**Impact** : Pas de schéma de base créé par les migrations.

**Suggestion** : Créer les tables (users, orders, etc.) selon le document de conception et les besoins de l’Edge Function.

---

### 3. Clés API en dur dans le code

Dans `lib/main.dart` :
```dart
url: 'https://[PROJECT_REF].supabase.co',
anonKey: '[SUPABASE_ANON_KEY]',
MapboxOptions.setAccessToken("[MAPBOX_TOKEN]");
```

**Impact** : Risque de fuite des clés (repo public, builds, logs).

**Suggestion** : Utiliser des variables d’environnement ou `--dart-define` et ne jamais committer les clés.

---

## III. Problèmes modérés

### 4. Authentification en mode test uniquement

`auth_screen.dart` simule la connexion :
```dart
await Future.delayed(const Duration(seconds: 1));
Navigator.pushReplacement(..., MapOrderScreen());
// Supabase non utilisé pour l’auth
```

**Impact** : En mode test, `Supabase.instance.client.auth.currentUser` est `null` → les commandes envoient `client_id: null` → erreur côté backend.

**Suggestion** : Réintégrer `Supabase.instance.client.auth.signInWithPassword()` / `signUp()` pour une vraie authentification.

---

### 5. Tests unitaires obsolètes

`test/widget_test.dart` cible un ancien app Counter :
```dart
expect(find.text('0'), findsOneWidget);
await tester.tap(find.byIcon(Icons.add));
expect(find.text('1'), findsOneWidget);
```

**Impact** : Les tests échouent car l’app ne contient plus de compteur.

**Suggestion** : Réécrire les tests pour l’écran d’auth ou la carte (ex. présence du logo Yadeli, redirection après connexion).

---

### 6. Doublon `AccountScreen`

Deux définitions :
- `lib/screens/account_screen.dart` (standalone, sans `onLogout`)
- `lib/screens/map_order_screen.dart` (classe inline avec `onLogout`)

Seule la version inline est utilisée. `account_screen.dart` est du code mort.

**Suggestion** : Supprimer le doublon ou factoriser dans un seul fichier avec `onLogout` obligatoire.

---

### 7. Fichier `.env` mal utilisé

`backend_app/.env` contient des commandes :
```
supabase secrets set SUPABASE_URL=...
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=...
```

**Suggestion** : Créer un vrai `.env` avec `SUPABASE_URL=...` et `SUPABASE_SERVICE_ROLE_KEY=...` pour les Edge Functions, et ajouter `.env` au `.gitignore`.

---

## IV. Problèmes mineurs

### 8. Typos

- `map_order_screen.dart` ligne 143 : "Utilisateur Yedali" → "Utilisateur Yadeli"
- `account_screen.dart` ligne 225 : "Yedali" → "Yadeli"

---

### 9. `error.message` deprecated

Dans `create-order/index.ts` :
```ts
error: error.message  // Sur un objet Error, .message peut ne pas exister
```

**Suggestion** : Utiliser `String(error)` ou `error instanceof Error ? error.message : 'Erreur inconnue'`.

---

### 10. Namespace Android

Le document de conception mentionne `com.example.gamestore` à migrer vers `com.example.yadeli`.  
Les fichiers Android utilisent encore `com.example.gamestore`.

---

## V. Points positifs

- Structure Flutter claire (écrans séparés, rôles bien définis)
- Design cohérent (vert Yadeli, carte, barre de recherche)
- Intégration Mapbox et Supabase prévues
- Document de conception détaillé
- Drawer et navigation fonctionnels
- Déconnexion correctement reliée à `AuthScreen`

---

## VI. Synthèse des actions recommandées

| Priorité | Action |
|----------|--------|
| Haute | Harmoniser le contrat API create-order (Flutter ↔ Edge Function) |
| Haute | Remplir les migrations SQL (init_schema, orders) |
| Moyenne | Externaliser les clés API (env / dart-define) |
| Moyenne | Réactiver l’auth Supabase dans `auth_screen` |
| Moyenne | Remplacer les tests unitaires obsolètes |
| Basse | Corriger les typos "Yedali" → "Yadeli" |
| Basse | Supprimer ou fusionner le doublon `AccountScreen` |

---

## VII. Tester manuellement

1. Installer Flutter : https://docs.flutter.dev/get-started/install
2. Lancer l’app : `flutter run -d chrome` ou `flutter run -d windows`
3. Vérifier : écran d’auth → carte → commande Moto/Pharmacie
4. À noter : les commandes échoueront tant que l’API create-order n’est pas alignée avec le client.
