# Livin

Real estate app (buy / rent) built with Flutter, BLoC and Firebase.

## Features
- Onboarding screens on first launch
- Sign up with email verification, login, password reset, persistent session
- Profile: view and edit name, phone, address and photo
- Browse listings, search by keyword, filter by offer (sale / rent), type and wilaya
- Advanced filters: price range, minimum surface, minimum rooms, amenities
- Listing details with surface, amenities and full-screen zoomable photos
- Publish, edit and delete your own listings, with photos
- Mark a listing as sold / rented to hide it, and reactivate it
- Favorites
- Contact the seller via WhatsApp or phone call
- Offline banner
- Map view of listings (OpenStreetMap) with price markers, location picker when publishing, and directions from the listing details

## Architecture
Feature-first, three layers per feature (hybrid / simplified Clean Architecture):
- `data`: remote data sources (Firebase, Cloudinary) and models
- `domain`: entities and repositories (return `Either<Failure, T>`)
- `presentation`: BLoCs (event / state / bloc) and views

Shared code lives in `lib/core` (router, dependency injection, error handling, theme, utils).

Data flow: `Page -> Event -> Bloc -> Repository -> Data source -> Firebase / Cloudinary`

## Tech
- State management: flutter_bloc
- Navigation: go_router (auth-aware `redirect` + `refreshListenable`)
- Dependency injection: get_it
- Backend: Firebase Auth + Cloud Firestore (security rules in `firestore.rules`)
- Images: Cloudinary (unsigned upload preset)
- Error handling: custom `Failure` classes + `Either`

## Run
    flutter pub get
    flutter run

## Tests
    flutter test

## Known limitations
- No pagination: listings are loaded once and filtered on the device.
- Cloudinary upload preset is unsigned (acceptable for a prototype).
- No map view and no admin panel yet.