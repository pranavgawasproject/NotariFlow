# 📓 NotariFlow

> **Flutter app for personal journaling, calendar planning, and expense tracking** — backed by Firebase. Scan receipts with ML Kit, sign documents, generate PDFs, chart your spending.

> The previous README was a one-line header followed by ad-hoc shell commands. This version is the real one.

---

## ✨ Features

### 📅 Calendar
- Month-view with `table_calendar`
- Day-cell entries, event hooks
- Cross-links with Journal entries

### 📝 Journal
- Rich text entries with attachments
- **OCR receipts** via `google_mlkit_text_recognition`
- Embedded **signatures** with the `signature` package
- **PDF export** of any entry (`pdf` + `printing`)

### 💸 Expenses / Currency
- Multi-currency support (`currency_service.dart`)
- **Charts** via `fl_chart`
- **CSV export** of spend data
- Subscription tier gating (`subscription_service.dart`)

### 🌍 Other
- **Geolocation** for location-tagged entries (`geolocator`)
- **Firebase Storage** for image uploads
- **Google Fonts** for typography
- Web target supported (uses `universal_html`)

---

## 🧱 Tech Stack

| Layer | Choice |
|---|---|
| Framework | **Flutter** (Dart) |
| Backend | **Firebase** — Auth + Firestore + Storage |
| State / UI | Built-in Flutter + `google_fonts` |
| Charts | `fl_chart` |
| PDF | `pdf` + `printing` |
| OCR | `google_mlkit_text_recognition` |
| Signatures | `signature` |
| CSV | `csv` |
| Calendar | `table_calendar` |
| Geo | `geolocator` |
| Local storage | `shared_preferences` |

---

## 🗂️ Project Structure

```
NotariFlow/
├── lib/
│   ├── main.dart                       # entry point + Firebase bootstrap
│   ├── main_backup.dart
│   ├── screens/
│   │   ├── calendar_screen.dart
│   │   └── journal_screen.dart
│   ├── utils/
│   │   ├── currency_service.dart
│   │   └── subscription_service.dart
│   └── widgets/
│       └── premium_widgets.dart
├── android/  ios/  linux/  web/        # platform shells
├── assets/
├── test/
├── PRIVACY_POLICY.md
├── pubspec.yaml
├── analysis_options.yaml
└── quick-rebuild.sh
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (stable)
- A Firebase project (Auth + Firestore + Storage enabled)

### Setup

```bash
git clone https://github.com/Pranavgawas/NotariFlow.git
cd NotariFlow

flutter pub get
flutter run                   # connects to the default device/emulator
```

Firebase config is embedded in `lib/main.dart` (`firebaseOptions`) — replace with your own project's config before shipping.

### Quick rebuild script

```bash
./quick-rebuild.sh
```

### Useful commands

```bash
flutter clean
flutter pub get
flutter analyze
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
```

---

## 🧪 Tests

```bash
flutter test
```

---

## 📚 Docs

- [`PRIVACY_POLICY.md`](./PRIVACY_POLICY.md) — privacy policy
- `quick-rebuild.sh` — fast clean-and-rebuild helper

---

## 🤝 Contributing

Issues + PRs welcome. Keep platform-specific code under `lib/` and platform shells under `android/`, `ios/`, etc.

---

## 📄 License

[MIT](./LICENSE) — © 2026 Pranav Gawas