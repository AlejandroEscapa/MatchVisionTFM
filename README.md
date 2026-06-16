# ⚽ MatchVision

### Football Tracking & Live Scores App for iOS

> **Trabajo de Fin de Máster** · Tokio School · Curso 2026
>
> *A native iOS application focused on football tracking — live scores, league standings, team and player statistics, personalized favorites, and sports news.*

---

<p align="center">
  <a href="https://github.com/AlejandroEscapa/MatchVisionTFM/releases">
    <img src="https://img.shields.io/github/v/release/AlejandroEscapa/MatchVisionTFM?style=flat-square&color=blue" alt="Release">
  </a>
  <img src="https://img.shields.io/badge/License-All%20Rights%20Reserved-red.svg?style=flat-square" alt="License: All Rights Reserved">
  <a href="https://github.com/AlejandroEscapa/MatchVisionTFM/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/AlejandroEscapa/MatchVisionTFM/ci.yml?style=flat-square" alt="CI">
  </a>
  <img src="https://img.shields.io/badge/Swift-5.0-FA7343?style=flat-square&logo=swift" alt="Swift">
  <img src="https://img.shields.io/badge/SwiftUI-Ready-4FC3F7?style=flat-square&logo=swift" alt="SwiftUI">
  <img src="https://img.shields.io/badge/iOS-18.6-green?style=flat-square" alt="iOS">
</p>

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Screenshots](#-screenshots)
- [Key Features](#-key-features)
- [Architecture](#-architecture)
- [Technology Stack](#-technology-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Core Modules](#-core-modules)
- [Security](#-security)
- [Testing](#-testing)
- [Citing This Work](#-citing-this-work)
- [Author](#-author)
- [License](#-license)
- [Project Vision](#-project-vision)

---

## 📖 Overview

MatchVision is a native iOS application built using **SwiftUI** for a fully declarative UI. The platform combines **live football tracking**, **league standings**, **team and player statistics**, **personalized favorites**, and **sports news** into a unified mobile experience.

The project follows an **MVVM architecture** approach, leveraging **Firebase** for authentication and cloud storage, and consuming **API-Football** and **NewsAPI** for real-time sports data.

> **Academic context**: This project was developed as part of a Master's Thesis (TFM) to demonstrate proficiency in mobile application development, software architecture, and modern iOS technologies.

---

## 📸 Screenshots

| Home | Match Details | Standings | Profile |
|------|---------------|-----------|---------|
| *[Screenshot]* | *[Screenshot]* | *[Screenshot]* | *[Screenshot]* |

---

## ✨ Key Features

### ⚽ Live Football Tracking
- **API-Football** integration for real-time match data
- Detailed match information with live scores and status
- Date-based match browsing with league grouping
- Pull-to-refresh for real-time updates

### 🏆 League Standings
- Comprehensive league tables (Premier League, La Liga, Bundesliga, Serie A, Ligue 1)
- Team rankings with points, goal difference, and form
- Detailed statistics: played, won, drawn, lost

### 👥 Teams & Players
- Complete team details with logo and position
- Player roster with statistics (goals, assists, cards, rating)
- Individual player profiles with physical data
- Player position translation (Goalkeeper, Defender, Midfielder, Forward)

### ⭐ Personal Favorites
- Favorite team selection synchronized to Firestore
- Quick access to favorite team matches and details
- Cloud-persisted user preferences

### 📰 Sports News
- Real-time sports news via NewsAPI
- Featured article highlighting
- Category-based filtering (sports)
- External article links

### 🔐 Authentication
- Firebase Authentication (Email/Password)
- User profile with name, email, and favorite team
- Session persistence
- Secure sign-out

### 🌙 User Experience
- Dark / Light Theme with system-follow mode
- Dynamic accent colors (Blue, Green, Red)
- Persistent settings via UserDefaults
- Animated Splash and Welcome screens
- Material Design-inspired SwiftUI components

---

## 🏗 Architecture

MatchVision follows **MVVM** (Model-View-ViewModel) architecture:

```text
┌─────────────────────────────────────────────-┐
│              PRESENTATION LAYER              │
│  ┌──────────────┐  ┌──────────────────────-┐ │
│  │ SwiftUI Views│  │NavigationStack/TabView│ │
│  └──────┬───────┘  └──────────┬───────────-┘ │
│         │                     │              │
│  ┌──────▼─────────────────────▼───────────-┐ │
│  │              ViewModels                 │ │
│  │  HomeVM · MatchsVM · PlayersVM          │ │
│  │  LeagueStandingsVM · ProfileVM          │ │
│  │  AuthVM · ThemeManager                  │ │
│  └──────────────────┬──────────────────────┘ │
└─────────────────────┼────────────────────────┘
                      │
┌─────────────────────▼────────────────────────┐
│                 DATA LAYER                   │
│  ┌──────────────┐  ┌──────────────────────┐  │
│  │  APIService  │  │    APINews           │  │
│  │  (URLSession)│  │  (URLSession)        │  │
│  └──────────────┘  └──────────────────────┘  │
│  ┌──────────────┐  ┌──────────────────────┐  │
│  │  Firestore   │  │  CoreData            │  │
│  │  (Cloud DB)  │  │  (Local Cache)       │  │
│  └──────────────┘  └──────────────────────┘  │
└──────────────────────────────────────────────┘
```

### Design Patterns Used
- **MVVM** — Separation of UI logic via ViewModels with @Published properties
- **Repository Pattern** — Single source of truth for data
- **Observer Pattern** — @Published, @StateObject, @EnvironmentObject
- **Navigation Component** — NavigationStack with type-safe routing

---

## 🛠 Technology Stack

| Category | Technology | Version |
|----------|-----------|---------|
| Language | Swift | 5.0+ |
| UI Toolkit | SwiftUI | iOS 18.6+ |
| Architecture | MVVM | — |
| Authentication | Firebase Auth | 12.5+ |
| Cloud DB | Firebase Firestore | 12.5+ |
| Networking | URLSession | Native |
| Local DB | CoreData | Native |
| Theme | Custom ThemeManager | Custom |
| Image Loading | AsyncImage | Native |
| Build System | Xcode | 26.0+ |

---

## 📂 Project Structure

```text
MatchVision/
├── API/
│   ├── FootballAPI.swift       # API-Football service
│   └── NewsAPI.swift           # NewsAPI service
├── Model/
│   ├── LeagueModel.swift        # League data models
│   ├── LeagueStatsModel.swift   # Standings models
│   ├── MatchModel.swift         # Match data models
│   ├── NewsModel.swift          # News article models
│   └── PlayerModel.swift        # Player data models
├── Resources/
│   ├── HeaderView.swift        # Navigation header
│   ├── SplashScreen.swift       # Animated splash
│   ├── ThemeManager.swift       # Theme & colors
│   └── UIStyles.swift          # Reusable modifiers
├── ViewModels/
│   ├── AuthViewModel.swift      # Authentication state
│   ├── HomeViewModel.swift      # Home screen logic
│   ├── LeagueStandingsViewModel.swift
│   ├── LoginViewModel.swift     # Login logic
│   ├── MatchsViewModel.swift    # Matches logic
│   ├── NewsViewModel.swift      # News logic
│   ├── PlayersViewModel.swift   # Players logic
│   ├── ProfileViewModel.swift   # Profile logic
│   └── UpcomingMatchesViewModel.swift
├── Views/
│   ├── Menus/
│   │   ├── Players/
│   │   │   └── PlayerDetailView.swift
│   │   ├── Settings/
│   │   │   ├── AboutView.swift
│   │   │   └── TerminosView.swift
│   │   ├── TabMenu/
│   │   │   ├── ActivityView.swift
│   │   │   ├── HomeView.swift
│   │   │   ├── LeagueListView.swift
│   │   │   ├── LeagueStandingsView.swift
│   │   │   ├── MatchsView.swift
│   │   │   ├── SettingsView.swift
│   │   │   └── TabViewLauncher.swift
│   │   └── Team/
│   │       ├── TeamDetailView.swift
│   │       └── UpcomingMatchesView.swift
│   └── UserRelated/
│       ├── LoginView.swift
│       ├── ProfileView.swift
│       └── RegisterView.swift
├── Persistence.swift             # CoreData controller
├── MatchVisionApp.swift          # App entry point
└── Assets.xcassets/             # Images & colors
```

---

## 🚀 Getting Started

### Prerequisites

| Tool | Minimum Version |
|------|----------------|
| Xcode | 26.0+ |
| iOS Simulator | 18.6+ |
| Swift | 5.0+ |

### Required Accounts & Keys

- **Firebase Project** — Auth + Firestore enabled → [console.firebase.google.com](https://console.firebase.google.com)
- **API-Football Key** — Free tier → [api-sports.io](https://api-sports.io)
- **NewsAPI Key** — Free tier → [newsapi.org](https://newsapi.org)

### Installation

```bash
# 1. Clone
git clone https://github.com/AlejandroEscapa/MatchVisionTFM.git
cd MatchVisionTFM

# 2. Firebase setup
#    - Create project at console.firebase.google.com
#    - Enable Authentication + Firestore
#    - Download GoogleService-Info.plist → place in MatchVision/

# 3. API Keys (update in code)
#    FootballAPI.swift: private let apiKey = "YOUR_API_KEY"
#    NewsAPI.swift: private let apiKey = "YOUR_API_KEY"

# 4. Open in Xcode
open MatchVision.xcodeproj

# 5. Select target device/simulator and run
```

### 🔐 API Key Management (Production)

```swift
// FootballAPI.swift — store keys securely in production
private let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_FOOTBALL_KEY") as? String ?? ""
```

---

## 📱 Core Modules

### 🔐 Authentication Module
- Firebase Authentication (Email/Password)
- Session persistence via AuthStateDidChangeListener
- User profile data in Firestore

### ⚽ Matches Module
- Date-based match browsing
- League grouping with headers
- Live status indicators (NS, FT, 1H, etc.)
- Pull-to-refresh

### 🏆 Standings Module
- League table visualization
- Team rankings with statistics
- Goal difference and form display

### 👥 Teams & Players Module
- Team details with roster
- Player statistics (appearances, goals, assists, cards, rating)
- Position-based sorting
- Individual player profiles

### 📰 News Module
- Sports news from NewsAPI
- Featured article highlighting
- Pull-to-refresh feed
- External article links

---

## 🔒 Security

### Current Measures
- Firebase Authentication for user identity
- Firestore security rules
- API keys stored in code (update before publishing)
- No sensitive data in logs

---

## 🧪 Testing

```bash
# Build for iOS Simulator
xcodebuild -project MatchVision.xcodeproj -scheme MatchVision -sdk iphonesimulator -configuration Debug build

# Run tests (when test targets exist)
xcodebuild test -project MatchVision.xcodeproj -scheme MatchVision
```

### Testing Strategy
| Layer | Framework | Focus |
|-------|-----------|-------|
| Unit | XCTest | ViewModels, Models |
| UI | SwiftUI Previews | View rendering |
| Integration | Firebase Emulator | Firestore reads/writes |

---

## 📚 Citing This Work

### APA 7th Edition
> Olivares Escapa, A. (2025). *MatchVision: Football Tracking & Live Scores App for iOS* [Master's Thesis, Tokio School]. GitHub. https://github.com/AlejandroEscapa/MatchVisionTFM

### BibTeX
```bibtex
@mastersthesis{olivares_matchvision,
  author  = {Alejandro Olivares Escapa},
  title   = {{MatchVision}: Football Tracking \& Live Scores App for iOS},
  school  = {Tokio School},
  year    = {2026},
  type    = {Master's Thesis (TFM)},
  url     = {https://github.com/AlejandroEscapa/MatchVisionTFM}
}
```

> See [CITATION.cff](CITATION.cff) for machine-readable metadata.

---

## 👨‍💻 Author

**Alejandro Olivares Escapa**

<p align="left">
  <a href="https://github.com/AlejandroEscapa">
    <img src="https://img.shields.io/badge/GitHub-000?style=flat-square&logo=github" alt="GitHub">
  </a>
  <a href="https://linkedin.com/in/alejandro-olivares-escapa">
    <img src="https://img.shields.io/badge/LinkedIn-0A66C2?style=flat-square&logo=linkedin" alt="LinkedIn">
  </a>
</p>

Software Engineer · iOS & Android Developer · Swift & Kotlin Specialist

---

## 📄 License

**All Rights Reserved**

This project is the intellectual property of Alejandro Olivares Escapa.
It is shared publicly for **portfolio and academic evaluation purposes only**.

You may:
- View the code for learning/evaluation
- Reference it with proper citation (see [CITATION.cff](CITATION.cff))

You may NOT:
- Copy, fork, modify, or distribute this code
- Use it in whole or part for commercial or personal projects
- Claim authorship

For licensing inquiries: alejandro.oliesc97@gmail.com

---

## ⚽ Project Vision

> *MatchVision aims to be the definitive mobile football companion — where fans track live scores, explore league standings, discover team and player statistics, manage their favorites, and stay informed with sports news — all through a modern, performant iOS-native experience.*

---

<div align="center">

<p>
  <img src="https://img.shields.io/badge/Built%20with-Swift-FA7343?style=for-the-badge&logo=swift" alt="Swift">
  <img src="https://img.shields.io/badge/Built%20with-SwiftUI-4FC3F7?style=for-the-badge&logo=swift" alt="SwiftUI">
  <img src="https://img.shields.io/badge/Built%20with-Firebase-FFCA28?style=for-the-badge&logo=firebase" alt="Firebase">
</p>

**Built with ❤️ by [Alejandro Olivares Escapa](https://github.com/AlejandroEscapa)**

⭐ *If you find this project useful, consider giving it a star!*

</div>
