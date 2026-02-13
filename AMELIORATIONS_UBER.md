# Yadeli — Améliorations inspirées d'Uber

## État actuel du projet

### ✅ Ce qui existe déjà

| Fonctionnalité | État | Fichier(s) |
|----------------|------|------------|
| Carte avec zoom/pan | ✅ | map_order_screen, flutter_map |
| Recherche de destination | ✅ | search_screen (suggestions dynamiques) |
| Position GPS | ✅ | location_service, geocoding |
| Services (Moto, Auto, Pharmacie, Livraison) | ✅ | all_services_screen |
| Commande rapide (Moto, Pharmacie) | ✅ | map_order_screen |
| Historique des trajets | ✅ | history_screen |
| Détail d'un trajet | ✅ | trip_detail_screen |
| Paiement (flux détaillé) | ✅ | payment_screen, payment_detail_screen |
| Profil (photo, genre, téléphone) | ✅ | edit_profile_screen |
| Promotions / codes | ✅ | promotions_screen |
| Support, Paramètres, À propos | ✅ | support_screen, settings_screen |
| Multi-langues (FR, EN, Lingala, Kituba) | ✅ | app_localizations |
| Panneau réduisible "Prêt ? C'est parti !" | ✅ | DraggableScrollableSheet |

---

## Fonctionnalités Uber à intégrer

### 🔴 Priorité haute (expérience utilisateur)

| # | Fonctionnalité Uber | Description | Effort |
|---|---------------------|-------------|--------|
| 1 | **Flux de réservation complet** | Avant de commander : 1) Choisir lieu de prise en charge 2) Choisir destination 3) Voir estimation du prix 4) Confirmer | Moyen |
| 2 | **Statuts de course en temps réel** | Afficher le statut : "Recherche chauffeur" → "Chauffeur assigné" → "En route" → "Arrivé" → "En cours" → "Terminé" | Moyen |
| 3 | **Estimation du prix avant confirmation** | Calculer et afficher le prix estimé selon le trajet (distance/temps) avant de valider | Moyen |
| 4 | **Trajet en cours (écran dédié)** | Écran pendant la course : carte, infos chauffeur, ETA, bouton "Partager le trajet", "Contacter" | Moyen |

### 🟠 Priorité moyenne

| # | Fonctionnalité Uber | Description | Effort |
|---|---------------------|-------------|--------|
| 5 | **Infos chauffeur** | Nom, photo, véhicule, plaque, note — affichés quand un "chauffeur" est assigné | Faible |
| 6 | **Note / Avis après course** | Étoiles + commentaire optionnel à la fin du trajet | Faible |
| 7 | **Adresses favorites** | "Maison", "Travail" — sauvegarder et réutiliser | Moyen |
| 8 | **Décompose du prix** | Base + suppléments (ex: nuit, bagages) avant paiement | Faible |
| 9 | **Course programmée** | Réserver pour une date/heure future | Moyen |

### 🟢 Priorité basse

| # | Fonctionnalité Uber | Description | Effort |
|---|---------------------|-------------|--------|
| 10 | **Partager le trajet** | Lien ou SMS pour suivre la course en temps réel | Moyen |
| 11 | **Bouton urgence / sécurité** | Accès rapide au support ou aux secours | Faible |
| 12 | **Historique par statut** | Filtrer : En cours, Terminés, Annulés | Faible |

---

## Plan d'implémentation proposé

### Phase 1 — Flux de réservation (type Uber)

```
Accueil → Clic "Où allons-nous ?" 
  → Saisie destination (recherche)
  → Saisie lieu de prise en charge (optionnel, défaut = position actuelle)
  → Choix du service (Moto, Auto, etc.)
  → Affichage estimation prix
  → Confirmation
  → Création commande
```

**Fichiers à créer/modifier :**
- `booking_flow_screen.dart` — écran de flux complet
- `order_service.dart` — ajouter pickup/delivery depuis la recherche
- `map_order_screen.dart` — lancer le flux au lieu de la commande directe

### Phase 2 — Statuts de course

- Ajouter `status` dynamique : `searching` → `assigned` → `en_route` → `arrived` → `in_progress` → `completed`
- Écran "Course en cours" avec carte, infos chauffeur simulé, ETA
- Mise à jour du statut (simulation avec délais)

### Phase 3 — Estimation de prix

- Service `PriceEstimator` : calcul basé sur distance (ou temps simulé)
- Formule simple : `base + (distance_km * tarif_km)` ou prix fixe par zone

### Phase 4 — Note et adresses favorites

- Écran de notation après course terminée
- Service `AddressService` pour "Maison", "Travail"
- Intégration dans la recherche

---

## Résumé des écrans à ajouter

| Écran | Rôle |
|-------|------|
| `BookingFlowScreen` | Flux complet : départ → arrivée → service → prix → confirmation |
| `RideInProgressScreen` | Course en cours : carte, chauffeur, ETA, actions |
| `RatingScreen` | Notation après course |
| `SavedAddressesScreen` | Gérer adresses favorites |

---

## Implémenté ✅

### Phase 1 — Flux de réservation
- `BookingFlowScreen` : Départ → Destination → Service → Prix estimé → Confirmation
- Option "Utiliser ma position", adresses favorites dans la recherche

### Phase 2 — Statuts de course
- `RideInProgressScreen` : carte, chauffeur, ETA, partager, contacter
- Statuts : searching → assigned → en_route → arrived → in_progress → terminé

### Phase 3 — Estimation, notation, adresses
- `PriceEstimatorService`, ETA (Citymapper), `RatingScreen`, `SavedAddressesScreen`

### Inspirations : Uber Eats (suivi livraison), BlaBlaCar (badge vérifié), Bolt, Citymapper

---

## Prochaines étapes

1. **Valider les priorités** — Quelles fonctionnalités souhaitez-vous en premier ?
2. **Phase 1** — Implémenter le flux de réservation complet
3. **Phase 2** — Ajouter les statuts et l’écran "Course en cours"
4. **Phase 3** — Estimation de prix et finitions

Indiquez par quoi vous voulez commencer.
