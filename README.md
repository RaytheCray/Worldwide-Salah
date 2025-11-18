# Worldwide Salah - Mobile App

A comprehensive prayer time app letting Muslims worldwide pray on time

-> Flutter mobile application for Islamic prayer times, Qibla direction, and Ramadan tracking.

## Features

- 📍 Automatic location detection
- 🕌 Accurate prayer times based on your location
- 🧭 Qibla compass pointing to Mecca
- 📅 Monthly prayer timetable
- 🌙 Ramadan schedule with fasting times
- 🔔 Prayer notifications (coming soon)
- 🌍 Support for multiple calculation methods
- 📱 Beautiful iOS-style interface

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart 3.0+
- Xcode (for iOS)
- Android Studio (for Android)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/RaytheCray/worldwide-salah-frontend.git
cd worldwide-salah-frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure API endpoint:
   - Copy `.env.example` to `.env`
   - Update `API_BASE_URL` with your backend URL

4. Run the app:
```bash
flutter run
```

## Backend Setup

This app requires the Worldwide Salah backend API. 

Backend repository: [worldwide-salah-backend](https://github.com/RaytheCray/worldwide-salah-backend)

### Local Development
```bash
# Start the backend server
python app.py
```

The app will connect to `http://localhost:5000/api` by default.

## Configuration

### Calculation Methods
- ISNA - Islamic Society of North America
- MWL - Muslim World League
- Egyptian - Egyptian General Authority of Survey
- Karachi - University of Islamic Sciences, Karachi
- Makkah - Umm Al-Qura University, Makkah
- Tehran - Institute of Geophysics, University of Tehran

### Asr Methods
- Standard - Shafi, Maliki, Hanbali schools (1 shadow length)
- Hanafi - Hanafi school (2 shadow lengths)
