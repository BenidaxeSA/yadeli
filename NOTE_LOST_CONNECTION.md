# "Lost connection to device" sur Windows

Lorsque vous lancez `flutter run -d windows`, l'application s'ouvre et tourne normalement. Le message **"Lost connection to device"** apparaît quand :

1. **Vous fermez le terminal** où Flutter tournait
2. **La connexion debug est perdue** (réseau, timeout, etc.)

**C'est normal** : l'application continue de fonctionner. Elle s'exécute en processus séparé. Le message signifie seulement que le débogueur n'est plus connecté, pas que l'app a planté.

Pour arrêter l'app : fermez la fenêtre de l'application ou terminez le processus `gamestore.exe` dans le Gestionnaire des tâches.
