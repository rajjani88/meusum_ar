# 🗺️ Museum AR Navigator

![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![GetX](https://img.shields.io/badge/GetX-^4.6.6-purple?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS-lightgrey)
![License](https://img.shields.io/badge/License-MIT-green)

An open-source **Indoor Wayfinding Application** built with Flutter and Augmented Reality (AR). 

Ever been lost inside a massive complex—a museum, a mall, or a hospital? This app is the solution! It uses your device's camera to render **animated 3D arrows on the floor**, guiding you directly to your destination using real-world coordinates and local mapping.

Have a look at our [Full Technical Tutorial & Blog Post on Building This App](AR_TUTORIAL_BLOG.md).

---

## ✨ Features

- **Dual Navigation:** Toggle seamlessly between an interactive 2D Map space and the 3D AR Camera view.
- **Dynamic 3D AR Arrows:** Renders animated `GLB` arrows pointing to your physical destination.
- **Real-Time Distance & Tracking:** Automatically calculates your physical location in proportion to the active waypoint and reports distance down to the meter.
- **Mock Back-End (JSON):** Easy to add or edit 'Places' or 'Waypoints' via a local `places.json` database. No complex server setup is required to run!
- **Reactive Architecture:** Clean, decoupled UI driven entirely by the **GetX** state management engine.

---

## 📸 Screenshots (Coming Soon)
*(Add your app screenshots or GIFs here showing the AR overlay and the Place selection UI)*

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed to run this project:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable)
- Android Studio or Xcode (for emulation/compilation)
- A physical device (ARCore for Android or ARKit for iOS) is highly recommended. The AR engine cannot run on standard emulators.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/meusum_ar.git
   cd meusum_ar
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the App on your Physical Device:**
   ```bash
   flutter run
   ```

*(Note for iOS Users: Open the `ios/Runner.xcworkspace` in Xcode, configure your Team Profile, and ensure `NSCameraUsageDescription` is permitted in your `Info.plist`)*

---

## 🗂 Folders & File Structure

This app follows a strictly decoupled MVC/MVVM approach utilizing GetX.

```bash
lib/
├── controllers/          # Business Logic
│   └── place_controller.dart  # Core Brain (Calculates distances, AR arrows, routing)
├── models/               # Data Layer
│   └── place_model.dart       # The 3D Place Object (Contains Vector3 waypoints)
├── screens/              # Full Pages
│   ├── home_screen.dart       # The Main Map / Map Viewer
│   └── permission_screen.dart # Pre-flight Camera request
├── widgets/              # Reusable UI Components
│   ├── ar_view.dart           # The AR Core/Kit Implementation & Canvas
│   ├── minimap_overlay.dart   # Interactive 2D Map Underlay
│   └── navigation_sheet.dart  # Slide-up location picker
└── main.dart             # App Entry Point & Dependency Injection
```
**Data Layer:** Check `assets/data/places.json` to manually add destinations or edit store coordinates!

---

## 🛠️ Built With...

- **[Flutter](https://flutter.dev/)** - The cross-platform UI toolkit.
- **[GetX](https://pub.dev/packages/get)** - Used for lightweight Dependency Injection and high-performance State Management (Routing & Reactive variables).
- **[ar_flutter_plugin](https://pub.dev/packages/ar_flutter_plugin)** - Powerful AR plugin acting as a wrapper over ARCore (Android) and ARKit (iOS).
- **[vector_math](https://pub.dev/packages/vector_math)** - Handles complex real-world 3D Math (Matrix4 and Vector3).

---

## 🤝 Contribution Guidelines

We ❤️ open-source and would love your help to take this navigator to the next level! Here’s how you can contribute:

### How to Contribute
1. **Fork** the repository repository.
2. **Create a new branch** for your feature or bug fix:
   `git checkout -b feature/amazing-new-feature`
3. **Commit** your changes with a descriptive message:
   `git commit -m "Add Amazing New Feature"`
4. **Push** to the branch:
   `git push origin feature/amazing-new-feature`
5. Open a **Pull Request**.

### Upcoming Roadmap (Ideas)
Looking for something to work on? Check out these potential additions:
- [ ] Connect the `places.json` to a real-time BaaS like Firebase or Supabase.
- [ ] Add TTS (Text-to-Speech) for visually impaired users.
- [ ] Implement `google_maps_flutter` for outdoor navigation before transitioning indoors.
- [ ] Improve the visual aspect of the 3D `.glb` Navigation Arrows.

---

## ☕ Support & Sponsor

Building open-source projects takes time and coffee! If this project helped you learn AR in Flutter, helped your venue, or saved you hours of development time, please consider supporting the project.

**Are you a business looking for custom features, a tailored backend, or white-labeling?** 
Sponsor the project to get priority support and feature requests!

- 💸 **[Buy Me A Coffee](https://buymeacoffee.com/rajjani)**
- 💖 **[Sponsor me on GitHub](https://github.com/sponsors/rajjani88)** 
---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.
