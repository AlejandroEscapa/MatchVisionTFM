# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] — 2026-06-08

### Added — Initial Release
- **⚽ Live Football Tracking**: API-Football integration for real-time match data
- **🏆 League Standings**: Comprehensive tables for Premier League, La Liga, Bundesliga, Serie A, Ligue 1
- **👥 Teams & Players**: Complete team details with roster and player statistics
- **⭐ Personal Favorites**: Favorite team selection synchronized to Firestore
- **📰 Sports News**: Real-time sports news via NewsAPI
- **🔐 Authentication**: Firebase Auth with email/password
- **🌙 Dark/Light Theme**: Dynamic theming with accent color selection (Blue, Green, Red)
- **🎬 Animated Onboarding**: Splash screen and welcome view with logo animation

### Technical Foundation
- SwiftUI with NavigationStack and TabView
- MVVM architecture with ObservableObject + @Published
- Firebase Auth + Firestore integration
- URLSession networking layer
- CoreData for local caching
- Custom ThemeManager for dynamic theming
- AsyncImage for remote image loading

---

## Version History Legend

| Symbol | Meaning |
|--------|---------|
| `[MAJOR.MINOR.PATCH]` | Semantic version (e.g., `1.0.0`) |
| `YYYY-MM-DD` | Release date |