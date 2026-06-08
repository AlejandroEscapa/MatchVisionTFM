# 🎮 GameVision

<div align="center">

# GameVision

### Gaming Social Network & Discovery Platform for Android

**A modern Android application focused on video game discovery, gaming news, social interaction and personalized game tracking.**

</div>

---

## 📖 Overview

GameVision is a native Android application built using modern Android development practices. The platform combines video game discovery, real-time gaming news, social features, user profiles and personalized game management into a unified mobile experience.

The project follows an MVVM architecture and leverages Jetpack Compose for a fully declarative UI experience.

---

## ✨ Key Features

### 🎮 Video Game Discovery

- Search games through RAWG API integration
- Detailed game information pages
- Ratings, genres and platform support
- Screenshot galleries and metadata

### 📰 Gaming News

- Real-time gaming news feed
- News aggregation from external APIs
- Dynamic content updates

### 👥 Social Platform

- Friend management system
- Social interaction capabilities
- User profile discovery

### 👤 User Profiles

- Editable profiles
- Personal information management
- Custom user descriptions
- Country and username configuration

### ❤️ Personal Library

- Game history tracking
- Favorite game management
- Personalized collections

### 🔐 Authentication

- Firebase Authentication
- Google Sign-In integration
- Guest access mode

### 🌙 User Experience

- Dark / Light Theme support
- Persistent settings via DataStore
- Material Design 3 UI
- Responsive Compose components

---

## 🏗 Architecture

```text
Presentation Layer
│
├── Jetpack Compose
├── Material Design 3
├── Navigation Compose
│
ViewModel Layer
│
├── UserViewModel
├── SearchViewModel
├── NewsViewModel
├── ThemeViewModel
├── GoogleViewModel
└── DDBBViewModel
│
Data Layer
│
├── Retrofit
├── Firebase Firestore
├── Firebase Authentication
├── Room Database
├── DataStore
└── External APIs
```

---

## 🛠 Technology Stack

| Category | Technology |
| --- | --- |
| Language | Kotlin |
| UI Toolkit | Jetpack Compose |
| Architecture | MVVM |
| Navigation | Navigation Compose |
| Authentication | Firebase Auth |
| Login Providers | Google Sign-In |
| Database | Room |
| Cloud Database | Firebase Firestore |
| Networking | Retrofit |
| Storage | DataStore |
| Dependency Injection | Hilt |
| Async Programming | Kotlin Coroutines |
| Design System | Material Design 3 |

---

## 📂 Project Structure

```text
app/
├── datastore/
├── retrofit/
├── ui/
│   ├── navigation/
│   ├── theme/
│   └── views/
├── viewmodel/
└── resources/
```

---

## 🚀 Getting Started

### Prerequisites

- Android Studio Hedgehog or newer
- Android SDK 35
- JDK 17+
- Firebase Project
- RAWG API Key
- NewsAPI Key

### Clone Repository

```bash
git clone <repository-url>
cd GameVision
```

### Configure Firebase

1. Create a Firebase project.
2. Enable Authentication.
3. Enable Firestore.
4. Download `google-services.json`.
5. Place the file inside:

```text
app/google-services.json
```

### Configure API Keys

Store secrets securely and avoid committing them to Git.

Recommended:

```properties
RAWG_API_KEY=your_key
NEWS_API_KEY=your_key
```

### Build

```bash
./gradlew assembleDebug
```

---

## 📱 Core Modules

### Authentication Module

Handles:

- Firebase Login
- Google Sign-In
- Guest Sessions

### News Module

Handles:

- Gaming news retrieval
- News presentation
- Feed management

### Search Module

Handles:

- Game search
- Game details
- Metadata retrieval

### Social Module

Handles:

- Friends
- User discovery
- Profile interactions

---

## 🔒 Security Recommendations

Before publishing publicly:

- Remove hardcoded API keys.
- Move secrets to local properties or secret managers.
- Rotate exposed credentials.
- Use BuildConfig fields for sensitive values.
- Exclude sensitive files from version control.

---

## 📈 Roadmap

- [ ] Push Notifications
- [ ] Real-Time Chat
- [ ] Achievement System
- [ ] Recommendation Engine
- [ ] AI-Powered Assistant
- [ ] Multi-language Support
- [ ] Cloud Save Synchronization
- [ ] Advanced Analytics

---

## 🧪 Testing

```bash
./gradlew test
```

```bash
./gradlew connectedAndroidTest
```

---

## 🤝 Contributing

Contributions are welcome.

1. Fork the repository.
2. Create a feature branch.
3. Commit your changes.
4. Open a Pull Request.

---

## 👨‍💻 Author

**Alejandro Olivares Escapa**

Software Engineer • Frontend and Mobile Developer

---

## ⭐ Project Vision

GameVision aims to provide a modern gaming ecosystem where users can:

- Discover new games
- Follow industry news
- Build gaming communities
- Track personal gaming activity

All through a modern Android-native experience powered by Kotlin and Jetpack Compose.

---

<div align="center">

Built with ❤️ using Kotlin, Jetpack Compose and Firebase.

</div>
