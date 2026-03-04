# 🛡️ Softel Control: License Activation Desktop

[![Flutter](https://img.shields.io/badge/Flutter-v3.12+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![GetX](https://img.shields.io/badge/State%20Management-GetX-purple)](https://pub.dev/packages/get)
[![Platform](https://img.shields.io/badge/Platform-Windows-blue?logo=windows)](https://flutter.dev/desktop)

**Softel Control** is a premium, high-performance desktop admin dashboard built with Flutter. It provides a sophisticated interface for managing software licenses, client subscriptions, and device activations with a focus on modern aesthetics (Glassmorphism) and smooth user experience.

---

## ✨ Key Features

- **📊 Dynamic Dashboard**: Real-time stats with animated progress tracking and recent activity logs.
- **📋 License Management**: Comprehensive system to generate, edit, and Remove license keys.
- **👥 Client Management**: Built-in views for managing client details and their associated subscriptions.
- **🎨 Premium UI/UX**: 
  - Sleek Dark Mode interface.
  - Glassmorphic design elements.
  - Hover effects and micro-animations using `flutter_animate`.
  - Responsive sidebar and top navigation rail.
- **🔍 Advanced Filtering**: Sort and filter subscriptions by status (Active, Expiring, Expired) and date.
- **⚡ Performance First**: Efficient state management using **GetX** and lazy-loaded bindings.

---

## 🏗️ Architecture & Tech Stack

This project follows a clean, modular architecture:

- **Framework**: [Flutter](https://flutter.dev) (Windows Desktop)
- **State Management**: [GetX](https://pub.dev/packages/get)
- **Styling & UI**:
  - Custom Dark Theme with Linear Gradients.
  - Google Fonts (Inter, Roboto).
  - Material Design 3 icons.
- **Animations**: [flutter_animate](https://pub.dev/packages/flutter_animate)
- **Structure**:
  - `/lib/view`: UI Components and Screens.
  - `/lib/controller`: Business logic and state handling.
  - `/lib/data`: Models and API integration layers.
  - `/lib/core`: Constants, themes, and route definitions.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (v3.12.0 or higher)
- Windows OS (for desktop development)
- Visual Studio (with Desktop development with C++)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/khaledbouhoun/License-Activation-Desktop-.git
   cd License-Activation-Desktop-
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   flutter run -d windows
   ```

---

## 📖 Component Documentation

For detailed information on project structure and components, please refer to:
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Technical deep dive into widget hierarchy.
- [QUICK_START.md](./QUICK_START.md) - Fast-track guide for new developers.

---

## 🔒 Security

This project includes a pre-configured `.gitignore` to protect sensitive data. 
**Avoid committing**:
- `.env` files
- Key stores (`*.jks`)
- API credentials
- Private certificates

---

## 👤 Author

**Khaled Bouhoun**
- GitHub: [@khaledbouhoun](https://github.com/khaledbouhoun)

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
