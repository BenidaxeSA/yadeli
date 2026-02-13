# Configuration du backend Supabase pour Yadeli

Le projet Supabase d'origine (`ycdksonqiybrchpfmxzv.supabase.co`) n'existe plus. Suivez ce guide pour créer **votre propre backend** et connecter l'application.

---

## Étape 1 : Créer un projet Supabase

1. **Aller sur** [supabase.com](https://supabase.com) et créer un compte (gratuit).

2. **Nouveau projet** → Cliquer sur **New Project**.

3. **Remplir** :
   - **Name** : `yadeli` (ou autre)
   - **Database Password** : noter ce mot de passe (pour accès direct à la base)
   - **Region** : choisir la plus proche (ex. `West EU (Ireland)`)

4. Attendre la création du projet (2–3 minutes).

---

## Étape 2 : Récupérer les clés

1. Dans le **dashboard Supabase**, ouvrir **Project Settings** (⚙️).

2. Onglet **API** :
   - **Project URL** : `https://xxxxx.supabase.co` → c’est votre `SUPABASE_URL`
   - **anon public** : clé sous "Project API keys" → c’est votre `anonKey` pour Flutter
   - **service_role** : clé secrète (reste cachée) → pour les Edge Functions

---

## Étape 3 : Appliquer les migrations

1. **Installer Supabase CLI** (si besoin) :
   ```powershell
   npm install -g supabase
   ```

2. **Se connecter** :
   ```powershell
   cd C:\yadeli\backend_app
   supabase login
   ```

3. **Lier le projet** :
   ```powershell
   supabase link --project-ref VOTRE_PROJECT_REF
   ```
   Le `project-ref` est dans l’URL : `https://XXXXX.supabase.co` → `XXXXX`.

4. **Pousser les migrations** :
   ```powershell
   supabase db push
   ```

---

## Étape 4 : Déployer la fonction Edge

1. **Configurer les secrets** :
   ```powershell
   supabase secrets set SUPABASE_URL="https://VOTRE_PROJECT_REF.supabase.co"
   supabase secrets set SUPABASE_SERVICE_ROLE_KEY="votre_clé_service_role"
   ```

2. **Déployer la fonction** :
   ```powershell
   supabase functions deploy create-order
   ```

---

## Étape 5 : Mettre à jour l’app Flutter

Dans `C:\yadeli\lib\main.dart`, remplacer :

```dart
await Supabase.initialize(
  url: 'https://VOTRE_PROJECT_REF.supabase.co',  // ← Votre URL
  anonKey: 'VOTRE_CLE_ANON_PUBLIC',             // ← Votre clé anon
);
```

---

## Récapitulatif des fichiers

| Fichier | Rôle |
|---------|------|
| `lib/main.dart` | URL et `anonKey` Supabase |
| `backend_app/supabase/migrations/` | Schéma de la base (table `orders`) |
| `backend_app/supabase/functions/create-order/` | Edge Function pour créer une commande |

---

## Vérification

1. Lancer l’app : `flutter run -d windows`
2. Se connecter (mode test)
3. Cliquer sur **Moto Express** ou **Pharmacie**
4. Si tout est correct : message vert « Commande réussie ! 1500 XAF »

---

## Alternative : Supabase local

Pour tester sans déployer :

```powershell
cd C:\yadeli\backend_app
supabase start
```

Puis dans `main.dart` utiliser l’URL locale (ex. `http://127.0.0.1:54321`) et la clé anon locale.  
Voir [Supabase local development](https://supabase.com/docs/guides/cli/local-development).
