# Codemagic — guía de setup (Fase 1)

> **Estado:** Fase 1 completada ✅ — CI/CD operativo (GitHub Actions + Codemagic Android/iOS).

Guía de referencia histórica: **[§ Pasos manuales (detallados)](#pasos-manuales-detallados)**.

## División de responsabilidades

| Qué | Dónde | Estado |
|-----|-------|--------|
| CI (analyze + test) | GitHub Actions en `develop` / PRs | ✅ |
| `codemagic.yaml` | Raíz del repo | ✅ |
| CD (AAB + IPA) | Codemagic en push a `main` | ✅ |
| Publicación automática Play / TestFlight | Codemagic `publishing` (requiere setup manual) | ⚙️ |
| Config Firebase | Commiteada en el repo | ✅ |
| Secrets runtime | Grupos env en Codemagic | ✅ |
| Firma Android/iOS | Codemagic Code signing | ✅ |

**Monorepo:** `codemagic.yaml` en la raíz; **Project path** en Codemagic = `meal_planner`.  
El yaml usa `working_directory: meal_planner` — los scripts no hacen `cd meal_planner`.

---

## Checklist rápido

- [x] 1. Cuenta Codemagic + conectar GitHub
- [x] 2. Project path = `meal_planner` + yaml desde raíz
- [x] 3. Grupos env: `supabase`, `sentry`, `google`
- [x] 4. Keystore Android → ref `meal_planner_keystore`
- [x] 5. SHA-1 release → Google Cloud (cliente Android OAuth)
- [x] 6. Apple Developer conectado en Codemagic (iOS)
- [x] 7. Primer build Android (rama `main`)
- [x] 8. Primer build iOS (rama `main`)

---

## Grupos de variables (referencia)

Los nombres de grupo deben ser **exactos** (coinciden con `codemagic.yaml`).

| Grupo | Variables |
|-------|-----------|
| `supabase` | `SUPABASE_URL`, `SUPABASE_ANON_KEY` |
| `sentry` | `SENTRY_DSN` |
| `google` | `GOOGLE_WEB_CLIENT_ID`, `GOOGLE_IOS_CLIENT_ID` |

Valores = los mismos que en tu `dart_defines.json` local.

> **Firebase:** no requiere grupo env — archivos en el repo.

---

## Firma Android (referencia)

- Keystore ref en yaml: **`meal_planner_keystore`**
- Gradle ya lee `CM_KEYSTORE_*` en release (`meal_planner/android/app/build.gradle.kts`)
- Tras crear el keystore, registra SHA-1 **release** en Google Cloud

---

## Firma iOS (referencia)

- Bundle ID: `com.japegomez.mealPlanner`
- `distribution_type: app_store` en yaml
- Requiere Apple Developer Program activo

---

## Workflows

| Workflow | Trigger | Output |
|----------|---------|--------|
| **Android Release** | Push a `main` | `.aab` → **Google Play** (track `internal`, draft) |
| **iOS Release** | Push a `main` | `.ipa` → **TestFlight** (internal) |

Pipeline: `flutter clean` → `pub get` → `analyze lib test` → `test` → **set build version** → build release.

### Versionado automático (versionCode / build number)

En CI, el **build number** no viene del `+1` de `pubspec.yaml`: Codemagic lo calcula en el paso *Set build version*.

| Campo | Origen en CI |
|-------|----------------|
| **versionName** / `CFBundleShortVersionString` | Parte antes del `+` en `pubspec.yaml` (p. ej. `1.0.0`) |
| **versionCode** / `CFBundleVersion` | `max(último en Play en todos los tracks, BUILD_NUMBER del workflow) + 1` |

- Cambias la versión visible (`1.0.0` → `1.0.1`) editando `pubspec.yaml` y haciendo merge a `main`.
- No hace falta tocar el número tras el `+` para releases de Codemagic; el `+1` del repo solo aplica a builds locales.
- Android consulta **todos los tracks** de Play (no solo `internal`): el `versionCode` es global por app.
- Si la API de Play falla, se usa el contador del workflow; en ese caso sube `BUILD_NUMBER_OFFSET` si hace falta.
- **No uses `PROJECT_BUILD_NUMBER`:** cada push a `main` lanza Android **e** iOS, y ese contador sube 2 por push aunque solo publiques una plataforma.

En el log del paso **Set build version** verás: `Release version: 1.0.0+42`.

---

## Publicación automática en stores

Tras cada push a `main`, Codemagic **construye y publica**:

| Plataforma | Destino | Config en yaml |
|------------|---------|----------------|
| Android | Google Play → track **internal** (borrador) | `publishing.google_play` |
| iOS | App Store Connect → **TestFlight** | `publishing.app_store_connect` |

> **Primera vez:** Google exige subir el **primer AAB manualmente** en Play Console. Apple recomienda crear la app en App Store Connect antes de automatizar.

### Grupo `google_play` (Codemagic → Environment variables)

| Variable | Valor |
|----------|--------|
| `GOOGLE_PLAY_SERVICE_ACCOUNT_CREDENTIALS` | Contenido completo del JSON de la service account (Secure) |

**Setup Google Cloud + Play Console:**

1. [Google Cloud Console](https://console.cloud.google.com/) → IAM → **Service accounts** → Create.
2. Keys → Add key → **JSON** → descarga el fichero.
3. [Play Console](https://play.google.com/console) → **Setup → API access** → vincula el proyecto GCP.
4. **Users and permissions** → Invite user → email de la service account.
5. Permisos de la app: **Release to testing tracks** (mínimo para internal).

El grupo debe llamarse exactamente **`google_play`**.

Track por defecto: `internal` (variable `GOOGLE_PLAY_TRACK`). Para producción, cambia a `production` y `submit_as_draft: false` en `codemagic.yaml`.

### Integración App Store Connect (iOS)

1. [App Store Connect](https://appstoreconnect.apple.com/) → **Users and Access → Integrations → App Store Connect API** → Generate key (**App Manager**).
2. Descarga el `.p8` (solo una vez). Anota **Issuer ID** y **Key ID**.
3. Codemagic → **Team settings → Integrations → Developer Portal** → Connect.
4. **API key name:** `Codemagic API Key` ← debe coincidir con `integrations.app_store_connect` en el yaml.
5. Sube Issuer ID, Key ID y el `.p8`.

### Variable `APP_STORE_APPLE_ID` (iOS)

En App Store Connect → tu app → **App Information** → **Apple ID** (número, p. ej. `6750123456`).

Actualiza en `codemagic.yaml`:

```yaml
APP_STORE_APPLE_ID: 6750123456
```

Sin esto, el build number usa `BUILD_NUMBER` del workflow (funciona, pero no sincroniza con TestFlight).

### Versionado al publicar

- **Android:** `google-play get-latest-build-number` en **todos los tracks** + 1; si la API falla, `max(BUILD_NUMBER, …) + 1`. Publica en track `internal` (`GOOGLE_PLAY_TRACK`).
- **iOS:** `get-latest-testflight-build-number` + 1 si `APP_STORE_APPLE_ID` está configurado; si no, `BUILD_NUMBER` del workflow iOS.

### Flujo tras merge a `main`

```
push main → Android Release → AAB → Play (internal, draft)
         → iOS Release     → IPA → TestFlight (internal, sin beta review)
```

Revisa el log en **Publishing** al final del build. iOS puede tardar 5–30 min en procesar en App Store Connect (post-processing).

---

## Troubleshooting

| Problema | Solución |
|----------|----------|
| `Failed to install dependencies... /Users/builder/clone` | **Project path** → Rescan → elige `meal_planner` (no `.`) |
| `flutter analyze` falla con cientos de issues en `build/.../SourcePackages/firebase_analytics/...` | Normal si analyze escanea todo el árbol. En el repo: `flutter analyze --fatal-infos lib test` + `exclude: build/**` en `analysis_options.yaml`. Ver PR #4. |
| Build no arranca | Project path = `meal_planner`; yaml en raíz |
| Variables vacías | Grupos con nombres exactos; marcar Secure |
| Android signing failed | Ref keystore = `meal_planner_keystore` |
| Google Sign-In en release | Añadir SHA-1 upload key **y** SHA-1 **App signing** de Play Console en Firebase/Google Cloud → ver [`OAUTH_SETUP.md`](OAUTH_SETUP.md) |
| iOS signing failed | Bundle ID + Apple Developer conectado |
| Solo corre en `main` | Merge `develop` → `main` o build manual en `main` |
| `Version code N has already been used` (Play) | Revisa log *Set build version*: debe consultar **todos los tracks** y usar `max(Play, BUILD_NUMBER)+1`. Verifica grupo `google_play` y credenciales JSON |
| Play Console: declaración ID publicidad vs manifiesto | Firebase Analytics usa `AD_ID` solo para analíticas. Manifiesto: permiso `AD_ID` + `google_analytics_adid_collection_enabled=true`. En Play: **Sí → Analíticas** (no anuncios) |

---

## Pasos manuales (detallados)

Sigue este orden. Tiempo estimado: **1–2 h** la primera vez.

### Paso 1 — Cuenta y repositorio

1. Ve a [https://codemagic.io/signup](https://codemagic.io/signup)
2. Regístrate con **GitHub** (recomendado) usando la cuenta `Japegomez`
3. Autoriza acceso al repositorio `meal_planner`
4. **Teams** → **Add application** → selecciona `Japegomez/meal_planner`
5. Cuando pregunte el tipo de proyecto: **Flutter App**

### Paso 2 — Project path y configuración YAML

1. Abre la app en Codemagic → **Settings** (engranaje)
2. Pestaña **Build**:

| Campo | Valor |
|-------|--------|
| **Project path** | `meal_planner` |
| **Branch** | `main` (para CD; prueba manual también en `main`) |
| **Build configuration** | **codemagic.yaml** (desde la raíz del repo) |

3. Guarda cambios
4. Verifica que aparecen dos workflows: **Android Release** e **iOS Release**

> **Error frecuente:** `Failed to install dependencies for pubspec file in /Users/builder/clone`  
> Codemagic busca `pubspec.yaml` en la raíz. Solución:
> 1. **Settings → Build → Project path** → clic en **Rescan** (icono refrescar)
> 2. Elige **`meal_planner`** en el desplegable (no `.`)
> 3. Confirma que **Build configuration** = **codemagic.yaml** (Configuration as code)
> 4. Relanza el build

### Paso 3 — Variables de entorno (3 grupos)

Codemagic → **Teams** → tu equipo → **Environment variables**  
(o **App settings** → **Environment variables**, según la UI actual)

Crea **un grupo por nombre** y añade las variables. Marca todas como **Secure** (candado).

#### Grupo `supabase`

| Variable | Dónde obtenerla |
|----------|-----------------|
| `SUPABASE_URL` | `https://hxtynisikjpwlvpdgdbt.supabase.co` |
| `SUPABASE_ANON_KEY` | [Supabase Dashboard](https://supabase.com/dashboard/project/hxtynisikjpwlvpdgdbt/settings/api) → **anon public** |

#### Grupo `sentry`

| Variable | Dónde obtenerla |
|----------|-----------------|
| `SENTRY_DSN` | [sentry.io](https://sentry.io) → tu proyecto Flutter → **Client Keys (DSN)** |

#### Grupo `google`

| Variable | Dónde obtenerla |
|----------|-----------------|
| `GOOGLE_WEB_CLIENT_ID` | [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services → Credentials → cliente OAuth **Web** |
| `GOOGLE_IOS_CLIENT_ID` | Mismo sitio → cliente OAuth **iOS** |

Copia los mismos valores que tienes en `meal_planner/dart_defines.json`.

**Importante:** el nombre del grupo debe ser exactamente `supabase`, `sentry`, `google` (minúsculas).

### Paso 4 — Keystore Android

#### 4a. Generar el keystore (en tu PC, una sola vez)

Abre CMD o PowerShell en una carpeta segura (no dentro del repo):

```cmd
keytool -genkey -v -keystore meal-planner-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias meal_planner
```

Te pedirá:

- Contraseña del keystore (guárdala)
- Contraseña de la clave `meal_planner` (puede ser la misma)
- Nombre, organización, etc.

**Guarda backup** del `.jks` y las contraseñas (1Password, etc.). Si lo pierdes, no podrás actualizar la app en Play Store.

#### 4b. Subir a Codemagic

1. Codemagic → **Teams** → **Code signing identities** → pestaña **Android**
2. **Upload keystore**
3. Rellena:
   - **Keystore file:** `meal-planner-release.jks`
   - **Keystore password:** la que elegiste
   - **Key alias:** `meal_planner`
   - **Key password:** la de la clave
   - **Reference name:** `meal_planner_keystore` ← **exacto**, coincide con el yaml
4. Guarda

#### 4c. SHA-1 release → Google Cloud

Obtén el SHA-1 del certificado release:

```cmd
keytool -list -v -keystore meal-planner-release.jks -alias meal_planner
```

Copia la línea **SHA1:** (formato `AA:BB:CC:...`).

1. [Google Cloud Console](https://console.cloud.google.com/) → **APIs & Services** → **Credentials**
2. Abre el cliente OAuth **Android** (`com.japegomez.meal_planner`)
3. **Add fingerprint** → pega el SHA-1 release
4. Guarda

> Sin este paso, Google Sign-In funciona en debug pero **falla en builds de Codemagic/Play Store**.

**Play App Signing (obligatorio en closed testing / producción):** Google Play re-firma el AAB con otro certificado. Copia el SHA-1 de **Integridad de la app → Certificado de firma de la app** en Play Console y regístralo también en Firebase (Project settings → Android app → Add fingerprint) y en el cliente OAuth Android. Regenera `google-services.json` con `flutterfire configure`. Detalle: [`OAUTH_SETUP.md`](OAUTH_SETUP.md).

### Paso 5 — Firma iOS (Apple Developer)

Requisito: **Apple Developer Program** activo (~99 USD/año).

1. Codemagic → **Code signing identities** → pestaña **iOS**
2. **Connect Apple Developer account** → inicia sesión con tu Apple ID de desarrollador
3. Codemagic puede **generar automáticamente** certificado + provisioning profile, o puedes subir los tuyos
4. Confirma que el **Bundle ID** es `com.japegomez.mealPlanner`

En [Apple Developer](https://developer.apple.com/account/) verifica (debería estar hecho):

- App ID `com.japegomez.mealPlanner` con **Sign In with Apple**
- App creada en **App Store Connect** (necesaria para TestFlight)

### Paso 6 — Primer build Android

1. Asegúrate de que `main` tiene el último código (`develop` mergeado o push directo)
2. Codemagic → tu app → **Start new build**
3. Configura:
   - **Branch:** `main`
   - **Workflow:** `Android Release`
4. **Start build**
5. Espera ~10–20 min; revisa el log si falla
6. Al terminar: **Artifacts** → descarga el `.aab`

**Si falla en signing:** revisa que la ref del keystore sea `meal_planner_keystore`.  
**Si falla en analyze/test:** reproduce localmente:

```powershell
cd meal_planner
flutter analyze --fatal-infos lib test
flutter test
```

### Paso 7 — Primer build iOS

Repite el paso 6 con **Workflow: iOS Release**.

1. Branch `main`
2. Descarga el `.ipa` de Artifacts
3. Opcional: sube a TestFlight desde Codemagic (**Publishing** → App Store Connect) o manualmente con Transporter

### Paso 8 — Activar CD automático

Tras builds manuales OK:

1. Merge `develop` → `main` en GitHub (PR recomendado)
2. Cada push a `main` disparará Android + iOS automáticamente (según yaml)

Para integración continua en `develop`: sigue usando **GitHub Actions** (no Codemagic).

### Paso 9 — Post-build (stores)

| Artefacto | Siguiente paso manual |
|-----------|----------------------|
| `.aab` | [Google Play Console](https://play.google.com/console) → crear app → **Pruebas internas** → subir AAB |
| `.ipa` | [App Store Connect](https://appstoreconnect.apple.com/) → TestFlight → subir build |

Ver `docs/TASKS.md` → **CI/CD y releases**.

---

## Valores de referencia del proyecto

| Concepto | Valor |
|----------|--------|
| Repo GitHub | `Japegomez/meal_planner` |
| Project path Codemagic | `meal_planner` |
| Android package | `com.japegomez.meal_planner` |
| iOS bundle ID | `com.japegomez.mealPlanner` |
| Keystore ref | `meal_planner_keystore` |
| Rama CD | `main` |
| Rama CI | `develop` |
