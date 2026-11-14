# Zapis vah (Flutter)

> Tato aplikace je z většiny vytvořena vibe codingem (AI asistovaný vývoj).

Jednoduchá aplikace pro zapisování vah pri cvičení v gymu.

## Funkce (MVP)
- Nový trénink, přidání cviku z knihovny
- Warm-up a pracovní série (váha, reps, poznámka)
- Historie a detail tréninku
- Zopakování tréninku (zkopírování cviků a sérií)
- Nastavení jednotek (kg/lb)

## Spusteni
1. Nainstaluj Flutter SDK (https://docs.flutter.dev/get-started/install)
2. V adresáři projektu:
   ```
   flutter pub get
   flutter run
   ```

## Struktura
- `lib/core` - db, router, theme, providers
- `lib/features` - exercises, workouts, settings
