<div align="center">

# 💬 Chats App

### A Real-Time WhatsApp-Style Messaging Application Built with Flutter & Firebase

[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter&logoColor=white&style=for-the-badge)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart&logoColor=white&style=for-the-badge)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black&style=for-the-badge)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

**A modern, feature-rich real-time messaging application with a clean, WhatsApp-inspired interface.**

</div>

---

## ✨ Features

- 🔐 **Authentication:** Secure Email & Password sign-up/login via Firebase Auth.
- 💬 **Real-Time Chat:** 1-on-1 private messaging with instant Firestore listeners & auto-managed chat rooms.
- ✅ **Message Status:** Single tick (sent) & double tick (seen/read receipts).
- 🗂️ **Smart Chat List:** Live updates with last message preview & dynamic timestamp formatting (Today, Yesterday, Date).
- 🎨 **WhatsApp UI/UX:** Clean design with custom message bubbles and tab navigation.

---

## 🛠️ Tech Stack

- **Frontend:** Flutter (Cross-platform UI framework)
- **Language:** Dart
- **Backend & Database:** Firebase (Authentication & Cloud Firestore)
- **Architecture:** Stream-driven real-time data synchronization

---

## 🚀 Getting Started

```bash
# 1. Clone the repository
git clone [https://github.com/kerols-Gamal0/chats_app.git](https://github.com/kerols-Gamal0/chats_app.git)
cd chats_app

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
flutterfire configure

# 4. Run the app
flutter run