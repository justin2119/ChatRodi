# ChatRodi - RodiumAi Multimodal BYOK Chatbot

<div align="center">

![RodiumAi Status](https://img.shields.io/badge/Status-Active%20Demo-00C9A7?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.47.4-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-Classic-008080?style=for-the-badge)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20MVVM-1E293B?style=for-the-badge)
![Security](https://img.shields.io/badge/Security-BYOK%20Local-10B981?style=for-the-badge)

<p align="center">
  <b>Application mobile de chatbot IA multimodale haute performance conçue pour une expérience utilisateur fluide, sécurisée et souveraine.</b>
</p>

</div>

---

## 💼 À propos du Projet

**ChatRodi** est une application mobile novatrice reposant sur le paradigme **Bring Your Own Key (BYOK)**. Elle permet à chaque utilisateur de connecter en toute sécurité sa propre clé API via l'infrastructure **RodiumAi** (`api.rodiumai.io/v1`).

> *"L'erreur n'est pas une faute, c'est le point de départ de l'apprentissage."*

---

## 👔 Leadership & Vision

| Rôle | Nom | Organisation |
| :--- | :--- | :--- |
| **Chief Executive Officer (CEO) & Solutions Architect** | **Justin BINA (BINA TOYI)** | ErreurZéro / B-SOLUTIONS |

> *"Notre vision avec ChatRodi est de démocratiser l'accès aux capacités d'intelligence artificielle de pointe tout en garantissant la souveraineté totale des données et la confidentialité des utilisateurs grâce au modèle BYOK."*  
> — **Justin BINA**, CEO

---

## 🚀 Fonctionnalités Clés

| Composant | Description | Statut |
| :--- | :--- | :---: |
| 🔑 **Architecture BYOK** | Stockage sécurisé local des clés API (`flutter_secure_storage`). Aucune transmission vers un serveur intermédiaire. | ✅ |
| 🧠 **Multimodalité Native** | Prise en charge fluide du texte, des images et des flux vidéo via les endpoints RodiumAi. | ✅ |
| ⚡ **Sélection Dynamique** | Changement et configuration en temps réel des modèles IA fournis par RodiumAi. | ✅ |
| 🛡️ **Zero Logging / Privacy** | Aucun enregistrement des prompts ni des réponses côté serveur tiers. Confidentialité absolue. | ✅ |
| 📂 **Local-First History** | Persistance locale intégrale des historiques de discussion sur l'appareil. | ✅ |

---

## 🛠 Architecture & Stack Technique

```
┌─────────────────────────────────────────────────────────┐
│                     ChatRodi UI                         │
│       (Flutter 3.47.4 • Clean Architecture • MVVM)      │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│              State Management (Riverpod)                │
│     StateNotifierProvider • FutureProvider.family       │
└──────────────┬────────────────────────────┬─────────────┘
               │                            │
               ▼                            ▼
┌─────────────────────────────┐  ┌────────────────────────┐
│  flutter_secure_storage     │  │   RodiumAi Client      │
│  (Clés API chiffrées local) │  │  (api.rodiumai.io/v1)  │
└─────────────────────────────┘  └────────────────────────┘
```

### Détail des Composants

| Domaine | Technologie / Choix | Rôle |
| :--- | :--- | :--- |
| **Framework** | Flutter 3.47.4 (Dart) | Client mobile multiplateforme réactif |
| **State Management** | Riverpod v3 (Syntaxe Classique) | Gestion prédictible de l'état sans couplage UI |
| **Sécurité** | `flutter_secure_storage` | Coffre-fort chiffré sur Keychain / Keystore |
| **IA Backend** | RodiumAi API (`v1`) | Inférence multimodale texte, image, vidéo |

---

## 🎨 Identité Visuelle & Palette

| Nom | Hex | Aperçu | Usage |
| :--- | :--- | :---: | :--- |
| **Rodium Emerald** | `#00C9A7` | `■` | Couleur d'accent principale, actions & succès |
| **Rodium Deep Slate** | `#0F172A` | `■` | Arrière-plans sombres, navigation |
| **Rodium Surface** | `#1E293B` | `■` | Cartes, conteneurs, bulles de messages |
| **Rodium Text Primary** | `#F8FAFC` | `■` | Titres, texte principal haute lisibilité |
| **Rodium Subtle Border** | `#334155` | `■` | Bordures fines et séparateurs UI |

---

## 📁 Structure du Projet

```
lib/
├── core/
│   ├── constants/
│   ├── network/
│   └── security/          # Gestion BYOK & flutter_secure_storage
├── features/
│   ├── auth_byok/         # Saisie et validation de la clé API
│   ├── chat/              # Logique et UI du chat multimodal
│   └── model_selection/   # Sélecteur dynamique des modèles RodiumAi
└── main.dart
```

---

## 📄 Licence & Droits

Propriété exclusive de **Justin BINA** — Tous droits réservés.  
Conçu et développé dans le cadre de la démonstration officielle **ChatRodi**.
