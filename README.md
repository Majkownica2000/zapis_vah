# Zapis vah (Flutter)

> Tato aplikace je z většiny vytvořena vibe codingem (AI asistovaný vývoj).

Jednoducha aplikace pro zapisovani vah pri cviceni v gymu.

## Funkce (MVP)
- Novy trenink, pridani cviku z knihovny
- Warm-up a pracovni serie (vaha, reps, poznamka)
- Historie a detail treninku
- Zopakovani treninku (zkopirovani cviku a serii)
- Nastaveni jednotek (kg/lb)

## Spusteni
1. Nainstaluj Flutter SDK (https://docs.flutter.dev/get-started/install)
2. V adresari projektu:
   ```
   flutter pub get
   flutter run
   ```

## Struktura
- `lib/core` - db, router, theme, providers
- `lib/features` - exercises, workouts, settings
