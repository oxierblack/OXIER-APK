# OXIER Flutter App — Setup Guide

## Requirements
- Flutter SDK 3.x (https://docs.flutter.dev/get-started/install)
- Android Studio or VS Code
- Android SDK (API 21+)

## Steps to Build

### 1. Edit local.properties
Open `android/local.properties` and update these two paths to match YOUR machine:
```
flutter.sdk=/home/YOUR_USERNAME/flutter
sdk.dir=/home/YOUR_USERNAME/Android/Sdk
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run on device/emulator
```bash
flutter run
```

### 4. Build APK
```bash
flutter build apk --release
```
APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

### 5. Build App Bundle (for Play Store)
```bash
flutter build appbundle
```

## Project Structure
```
lib/
├── main.dart              # Entry point
├── app.dart               # App root + screen routing
├── constants/
│   ├── app_colors.dart    # Color palette (dark/light)
│   └── api_constants.dart # API endpoints
├── models/
│   ├── market.dart        # Market data model
│   ├── trade.dart         # Trade model
│   └── transaction.dart   # Transaction model
├── providers/
│   └── app_store.dart     # Global state (Provider)
├── services/
│   ├── api_service.dart   # Backend API calls
│   └── binance_service.dart  # Binance API + WebSocket
└── screens/
    ├── splash_screen.dart
    ├── auth/
    │   ├── login_screen.dart
    │   ├── register_screen.dart
    │   ├── verify_screen.dart
    │   └── pin_screen.dart
    └── trading/
        ├── trading_platform.dart   # Main screen
        ├── widgets/
        │   ├── top_bar.dart        # Header + wallet switcher
        │   ├── asset_bar.dart      # Market + timeframe selector
        │   ├── trading_chart.dart  # Candlestick chart (Binance WS)
        │   ├── bottom_controls.dart # Amount, expiry, BUY/SELL
        │   └── nav_bar.dart        # Bottom navigation
        └── overlays/
            ├── history_overlay.dart    # Trade history
            ├── signals_overlay.dart    # Trading signals
            ├── indicators_overlay.dart # Technical indicators
            ├── events_overlay.dart     # Economic calendar
            ├── panel_overlay.dart      # Account dashboard
            ├── expiry_overlay.dart     # Amount & expiry settings
            ├── deposit_screen.dart     # Deposit funds
            ├── profile_screen.dart     # User profile
            ├── transfers_screen.dart   # Withdrawals & history
            └── markets_overlay.dart    # Market selector
```

## Key Features
- Real-time candlestick charts via Binance WebSocket
- Binary options trading (BUY UP / SELL DOWN)
- Demo & Real account wallets
- Markets: Crypto, Forex, Gold
- Technical indicators (RSI, MACD, BB, EMA, SMA, CCI, ATR...)
- Dark / Light theme
- Deposit & withdrawal system
- Trade history
- Economic calendar
- Trading signals

## Backend
Connected to: https://oxier-backend-production.up.railway.app
