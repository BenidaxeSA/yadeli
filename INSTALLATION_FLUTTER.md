# Installation de Flutter pour tester Yadeli

*Guide basé sur la [documentation officielle Flutter](https://docs.flutter.dev/get-started/install)*

---

## Étape 1 : Prérequis

### 1.1 Git pour Windows
- **Télécharger** : [Git for Windows](https://git-scm.com/downloads/win)
- **Installer** puis redémarrer le terminal si nécessaire

### 1.2 Cursor / VS Code
- Vous utilisez déjà **Cursor** → compatible avec les extensions VS Code (Code OSS-based)

---

## Étape 2 : Installer Flutter via Cursor

### Option A : Via l’extension Flutter (recommandé)

1. **Ouvrir Cursor** et ouvrir le projet `C:\yadeli`.

2. **Installer l’extension Flutter** :
   - `Ctrl+Shift+X` pour ouvrir la vue Extensions
   - Rechercher **"Flutter"**
   - Installer **Flutter** (par Dart Code) — cela installe aussi Dart

3. **Télécharger le SDK Flutter** :
   - `Ctrl+Shift+P` pour ouvrir la palette de commandes
   - Taper **`Flutter: New Project`**
   - Quand Cursor demande l’emplacement du SDK Flutter → choisir **`Download SDK`**
   - Choisir un dossier (ex : `C:\flutter` ou `C:\src\flutter`)
   - Cliquer sur **Clone Flutter**
   - Attendre la fin du téléchargement (quelques minutes)

4. **Ajouter Flutter au PATH** :
   - Après la fin du téléchargement, cliquer sur **`Add SDK to PATH`**
   - Fermer puis rouvrir tous les terminaux
   - Redémarrer Cursor

### Option B : Installation manuelle

1. **Télécharger** : [Flutter SDK Windows](https://docs.flutter.dev/install/manual) — sur la page, cliquer sur le lien de téléchargement du bundle Windows (fichier `.zip`)

2. **Extraire** : par exemple dans `C:\flutter` (éviter les chemins avec espaces ou caractères spéciaux)

3. **Ajouter au PATH** :
   - Paramètres Windows → **Rechercher « variables d’environnement »**
   - Ouvrir **Variables d’environnement**
   - Dans **Variables utilisateur**, sélectionner **Path** → **Modifier**
   - **Nouveau** → `C:\flutter\bin` (ou votre chemin)
   - Valider puis fermer

4. Redémarrer Cursor et tous les terminaux

---

## Étape 3 : Vérifier l’installation

Ouvrir un **nouveau terminal** dans Cursor :

```powershell
flutter doctor
```

Résultat attendu : au moins `[✓] Flutter` et `[✓] Windows Version`.

---

## Étape 4 : Lancer Yadeli

```powershell
cd C:\yadeli
flutter pub get
flutter run -d chrome
```

ou pour Windows desktop :

```powershell
flutter run -d windows
```

Pour lister les appareils disponibles :

```powershell
flutter devices
```

---

## Cibles possibles

| Cible | Commande | Prérequis |
|-------|----------|-----------|
| **Chrome** | `flutter run -d chrome` | Chrome installé |
| **Windows** | `flutter run -d windows` | Visual Studio 2022 (build tools) |
| **Edge** | `flutter run -d edge` | Edge installé |

---

## Dépannage

- **Flutter non reconnu** : relancer Cursor et tous les terminaux après l’installation.
- **`flutter doctor` incomplet** : Android Studio peut être ignoré si vous testez uniquement sur web/Windows.
- **Problèmes** : [Dépannage Flutter](https://docs.flutter.dev/install/troubleshoot)

---

*Référence : [Install Flutter](https://docs.flutter.dev/get-started/install)*
