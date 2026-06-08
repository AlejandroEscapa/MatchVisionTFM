# Support

## Getting Help

### 📖 Documentation
- [README.md](README.md) — Project overview, setup, and architecture
- [CONTRIBUTING.md](CONTRIBUTING.md) — Development guidelines
- [CHANGELOG.md](CHANGELOG.md) — Version history
- [SECURITY.md](SECURITY.md) — Vulnerability reporting

### 🐛 Bug Reports & Feature Requests
- [GitHub Issues](https://github.com/AlejandroEscapa/MatchVisionTFM/issues)
  - Search existing issues before opening a new one
  - Use templates (Bug Report / Feature Request)
  - Include:
    - Device model & iOS version
    - Steps to reproduce
    - Screenshots/recordings if applicable

### 💬 Questions & Discussion
- [GitHub Discussions](https://github.com/AlejandroEscapa/MatchVisionTFM/discussions) — Q&A, ideas, polls

### 🔒 Security Vulnerabilities
See [SECURITY.md](SECURITY.md) for private reporting guidelines.

---

## Common Issues

### Build Error: `GoogleService-Info.plist not found`
```bash
# Download from Firebase Console → Project Settings → Your apps
# Place in: MatchVision/GoogleService-Info.plist
```

### API Rate Limiting (API-Football)
The API-Football free tier has rate limits. To avoid issues:
- Implement caching (CoreData local storage)
- Use pull-to-refresh sparingly
- Consider upgrading to paid tier for production

### Firebase Configuration Issues
```bash
# Ensure Firebase project has:
# - Authentication enabled (Email/Password)
# - Firestore database created
# - iOS app registered with correct bundle ID
```

### Xcode Build Issues
```bash
# Clean build folder
# Product → Clean Build Folder (Cmd+Shift+K)

# Delete derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/

# In Xcode: File → Invalidate Caches → Restart
```

---

## Contact

- **Author**: Alejandro Olivares Escapa
- **Email**: alejandro.oliesc97@gmail.com
- **GitHub**: [@AlejandroEscapa](https://github.com/AlejandroEscapa)

---

## Status

| Service | Status |
|---------|--------|
| Repository | ✅ Active |
| Documentation | ✅ Available |
| Issue Tracker | ✅ Open |
| CI/CD | ⚠️ Pending setup |

*Last updated: 2025-06-08*
