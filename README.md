# Zápis váh (Flutter)

> Tato aplikace je z většiny vytvořena vibe codingem (AI asistovaný vývoj).

Jednoduchá aplikace pro zapisování vah při cvičení v gymu.

## Funkce (MVP)
- Nový trénink, přidání cviku z knihovny
- Warm-up a pracovní série (váha, reps, poznámka)
- Historie a detail tréninku
- Zopakování tréninku (zkopírování cviků a sérií)
- Nastavení jednotek (kg/lb)

## Spuštění
1. Nainstaluj Flutter SDK (https://docs.flutter.dev/get-started/install)
2. V adresáři projektu:
   ```
   flutter pub get
   flutter run
   ```

## Jak aplikace funguje

- **Home:** tlačítko „Nový trénink“ vytvoří trénink (volitelně s názvem). Spodní lišta přepíná Historii, Cviky a Nastavení.
- **Trénink:** přidej cvik z knihovny, pak warm-up a pracovní série (váha, reps, poznámka). Série se ukládají při opuštění pole.
- **Historie:** seznam tréninků s názvem a datem. Kliknutím otevřeš detail (jen pro čtení) nebo „Upravit“ pro změny.
- **Zopakovat trénink:** v detailu zkopíruje cviky a série (včetně názvu) jako výchozí hodnoty.
- **Cviky:** vlastní knihovna cviků (přidání, mazání, vyhledávání).
- **Nastavení:** jednotky (kg/lb), motiv (světlý/tmavý/systémový).

## Jak je aplikace udělaná

- **Framework:** Flutter (Dart), Material 3, podpora Android + web.
- **State management:** Riverpod.
- **Navigace:** go_router (ShellRoute se spodní NavigationBar).
- **Databáze:** sqflite (SQLite) – lokální, offline-first. Tabulky: `exercises`, `workouts`, `workout_exercises`, `sets`.
- **Motiv:** light/dark paleta (amber + teal + zelená), font Inter (Google Fonts).
- **Architektura:** feature-first (exercises, workouts, settings), repository pattern nad SQLite.
- **Build:** `flutter build apk` (Android), `flutter build web` (web). Žádný backend, vše lokálně.

## Struktura
- `lib/core` - db, router, theme, providers
- `lib/features` - exercises, workouts, settings
