# MealPlanner

App Flutter para planificar comidas semanales y generar listas de la compra.

## Requisitos

- Flutter SDK (stable)
- Cuenta Supabase con proyecto `meal-planner` en `eu-west-1`

## Setup local

```bash
cd meal_planner
flutter pub get
```

Copia `.env.example` a `.env` como referencia local.

Para desarrollo, copia `dart_defines.example.json` → `dart_defines.json` y rellena tus valores.
Ese archivo está gitignored.

```powershell
copy dart_defines.example.json dart_defines.json
```

Ejecutar con defines desde archivo:

```powershell
# Emulador Android (recomendado en Windows; tras adb devices → emulator-5554 device)
flutter run -d emulator-5554 --dart-define-from-file=dart_defines.json

# Cualquier Android conectado
flutter run -d android --dart-define-from-file=dart_defines.json

# Web (alternativa en Windows si Firebase bloquea build nativo)
flutter run -d chrome --dart-define-from-file=dart_defines.json
```

1. Copia `dart_defines.example.json` → `dart_defines.json` y rellena valores.
2. Arranca el emulador: `flutter emulators --launch Pixel_8` o Android Studio → Device Manager.
3. Comprueba: `adb devices` y `flutter devices` antes de `flutter run`.

En Cursor/VS Code: **Run and Debug** → `meal_planner (Android)` / `Chrome` (usa `launch.json`).

O con flags sueltos:

```powershell
flutter run `
  --dart-define=SUPABASE_URL=https://hxtynisikjpwlvpdgdbt.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=<tu-anon-key> `
  --dart-define=GOOGLE_WEB_CLIENT_ID=<web-client-id> `
  --dart-define=GOOGLE_IOS_CLIENT_ID=<ios-client-id> `
  --dart-define=TURNSTILE_SITE_KEY=<turnstile-site-key>
```

Si `TURNSTILE_SITE_KEY` está vacío, `Env.hasTurnstile` es falso: la app omite el CAPTCHA y muestra el aviso de que Turnstile no está configurado.

> **Android:** no hay `GOOGLE_ANDROID_CLIENT_ID` en Dart. El cliente Android en Google Cloud se valida por package + SHA-1; en código usas `GOOGLE_WEB_CLIENT_ID` como `serverClientId`.

## Estructura

```
lib/
├── core/          # Supabase, theme, utils, widgets
├── features/      # auth, household, recipes, planner, shopping
└── router/        # go_router + shell con bottom nav
```

## CI

- **GitHub Actions**: análisis + tests en PRs a `main` / `develop`
- **Codemagic**: builds Android (AAB) e iOS (IPA) en push a `main` — guía completa en [`docs/CODEMAGIC.md`](../docs/CODEMAGIC.md)
- **CodeRabbit**: revisión automática de PRs y commits (comentarios, bugs y sugerencias)

## Supabase

Migraciones SQL en [`../supabase/migrations/`](../supabase/migrations/). Ver [`../supabase/README.md`](../supabase/README.md).
