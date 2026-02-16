# Lush? Salon User App

A customer-facing salon booking app with an AI concierge and AI hairstyle recommendations. Built for UI/UX clarity, responsive layouts, and Riverpod-based state management.

## Tech Stack
- Flutter (Material 3)
- Riverpod (state management)
- GoRouter (navigation)
- Google Fonts (typography)

## AI Integration Approach
- **AI Concierge Chatbot**: Rule-based responses for pricing, timings, booking status, and cancellation policy.
- **AI Style Studio**: Simulated selfie upload and face-shape analysis flow. Recommendations are data-driven in the UI layer and connect directly to the booking flow.

## Setup Instructions
1. `flutter pub get`
2. `flutter run`

## Screenshots
- Home, Service Detail, Date & Time, Summary, Success
- AI Concierge Chat
- AI Style Studio

## Assumptions
- This is a UI-first submission. Data is mocked locally to keep the app fast and demonstrable without backend setup.
- Firebase can be integrated later for auth, bookings, and chat logs without changing the UI architecture.

## Firebase Notes
- Firebase is wired through `FirebaseBootstrap`. Set `enableFirebase = true` and replace the web options or run FlutterFire to generate platform configs.

## Added AI Features
- Face Recognition Login (local_auth, demo-ready UX)
- Voice-Based Booking (speech_to_text + parsing)
- Optional OpenAI Chat Integration (disabled by default)
