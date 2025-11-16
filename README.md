# e_commerce_app

A modern Flutter commerce experience that now ships with a cinematic splash screen, a premium auth flow, and polished shopping surfaces (home, listings, cart, checkout, account).

## Highlights
- ✨ Gradient splash entry that routes guests or signed-in users automatically.
- 🔐 Dedicated luxe-styled auth screen with login, signup, password reset, and quick guest access.
- 🛒 Curated home, product, cart, and checkout flows wired to Supabase-based services.
- 📱 Responsive typography (Google Fonts) and a cohesive color system for Material 3.

## Quick start
```powershell
cd c:\e_commerce_app
flutter pub get
flutter run
```

> **Note:** create a `.env` file with your `SUPABASE_URL` and `SUPABASE_ANON_KEY` before running locally.

## Project structure
- `lib/screens` – splash/auth/home/product/cart/account surfaces.
- `lib/services` – Supabase-backed data providers (products, cart, auth, orders, addresses).
- `lib/widgets` – shared UI building blocks (bottom nav, cards, filters, etc.).

Happy building!*** End Patch
