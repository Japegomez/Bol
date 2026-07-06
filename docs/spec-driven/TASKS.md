# Tareas - MealPlanner

> Actualizado: 06/07/2026 — GitHub Pages clásico desde `/docs`; eliminado workflow `pages.yml`
> Metodología: Kanban personal. Actualizar al inicio y al final de cada sesión de trabajo.

---

## Estado del proyecto

| Fase                    | Estado     | Descripción                                                                   |
| ----------------------- | ---------- | ----------------------------------------------------------------------------- |
| Fase 1 — Setup          | Completada | Flutter, Supabase, OAuth, CI/CD Codemagic, builds Android + iOS verificados  |
| Fase 2 — Auth y perfiles| Completada | F1 auth, F2 perfil y F3 hogar en UI; modo individual en planificador y lista |
| Fase 3 — Recetario      | Completada | CRUD recetas, ingredientes, pasos, fotos, nutrición (F4–F5)                  |
| Fase 4 — Planificador   | Completada | Vista semanal vertical, slots, drag-and-drop, sobras, texto libre, Realtime |
| Fase 5 — Lista compra   | Completada | Vista agrupada, CRUD, sync planificador↔lista por `plan_slot_id`, exportación, Realtime hogar |
| Fase 6 — Red social     | Completada | Recetas públicas, exploración, valoraciones, seguimiento, feed, perfiles públicos (en `main`) |

---

## Fase 1 — Setup

### Setup inicial del proyecto

- [x] Inicializar proyecto Flutter: `flutter create meal_planner`
- [x] Configurar `flutter_lints` y `analysis_options.yaml`
  - Excluye `build/**` y `.dart_tool/**` del analyzer (evita escanear artefactos de dependencias en CI)
- [x] Definir estructura de carpetas Feature-First (`lib/core/`, `lib/features/`, `lib/router/`)
- [x] Instalar dependencias base (`supabase_flutter`, `flutter_riverpod`, `go_router`)
  - También instaladas: Sentry, Firebase Analytics, logger, secure storage, connectivity, upgrader, in_app_review, google_sign_in, sign_in_with_apple
- [x] Crear repositorio en GitHub y primer commit
  - Remote `origin` → `https://github.com/Japegomez/meal_planner.git`
- [x] Configurar GitHub Actions básico (análisis estático + `flutter test` en cada PR)
  - Comando: `flutter analyze --fatal-infos lib test` (solo código de la app, no `build/`)
- [x] Añadir `.env.example` y `dart_defines.example.json` (`SUPABASE_*`, `SENTRY_DSN`, `GOOGLE_*`)
  - Valores reales en `dart_defines.json` / `.env` local (gitignored); Codemagic como Environment Variables

### Prueba local (emulador Android)

- [x] Documentar flujo de ejecución local con `dart_defines.json`
- [x] Verificar app en emulador Android (manual)

**Preparación (una vez):**

```powershell
cd meal_planner
copy dart_defines.example.json dart_defines.json
# Editar dart_defines.json: SUPABASE_URL, SUPABASE_ANON_KEY, GOOGLE_*
flutter emulators --launch Pixel_8   # o ▶ en Android Studio → Device Manager
```

Esperar arranque completo. `flutter emulators` lista AVDs instalados; `flutter devices` solo muestra dispositivos **encendidos**:

```powershell
adb devices          # debe mostrar emulator-5554   device
flutter devices
```

**Ejecutar la app:**

```powershell
flutter run -d emulator-5554 --dart-define-from-file=dart_defines.json
```

Alternativa web (requiere **hot restart** tras cambios en providers o `index.html`):

```powershell
flutter run -d web-server --web-port=8080 --dart-define-from-file=dart_defines.json
```

Web: `web/index.html` incluye `passkeys_bundle.js` (dependencia transitiva de `supabase_flutter` / WebAuthn).

Variables: `--dart-define-from-file=dart_defines.json` → leídas por `lib/core/config/env.dart` en compile time.

### Setup Supabase

- [x] Crear proyecto en Supabase (región `eu-west-1`) — proyecto `meal_planner`, ref `hxtynisikjpwlvpdgdbt`
- [x] Crear migración `001_profiles`: tabla `profiles`, trigger `auth.users` → `profiles`
- [x] Crear migración `002_households`: tablas `households` y `household_members`
- [x] Crear migración `003_recipes`: tablas `recipes`, `ingredients`, `recipe_steps`, `nutrition_info`
- [x] Crear migración `004_planner`: tablas `weekly_plans` y `plan_slots`
- [x] Crear migración `005_shopping`: tablas `shopping_lists` y `shopping_items`
- [x] Configurar Row Level Security (RLS) en todas las tablas
  - Política: usuario solo accede a sus propios datos o a los del hogar al que pertenece
- [x] Crear índices de rendimiento (recetas por usuario, plan por semana, lista de compra activa)
- [x] Configurar Supabase Storage: bucket `recipe-photos` (privado, acceso por usuario)
- [x] Activar Supabase Realtime en `plan_slots` y `shopping_items` (para hogares compartidos)
- [x] Configurar Google Sign-In nativo en Google Cloud (3 clientes OAuth: Web, Android, iOS)
  - Web: Client ID + Secret → Supabase Auth; redirect URI de Supabase
  - Android: package `com.japegomez.meal_planner` + SHA-1 debug y release
  - iOS: bundle `com.japegomez.mealPlanner`
- [x] Configurar proveedor Google en Supabase Auth (Client ID + Secret del cliente **Web**; activar **Skip nonce check**)
- [x] Configurar proveedor OAuth Apple en Supabase Auth (Key ID + Team ID de Apple Developer)
- [x] Generar modelos Dart con **Supadart** (`meal_planner/lib/core/supabase/models/`)

### Servicios externos (observabilidad y UX)

- [x] Instalar y configurar **Sentry** (`sentry_flutter`)
  - Inicializar en `main.dart` con `SentryFlutter.init`; DSN en variable de entorno `SENTRY_DSN`
  - `tracesSampleRate: 0.2` en producción; `1.0` en desarrollo
  - Añadir `SENTRY_DSN` a Codemagic Environment Variables
- [x] Integrar **Firebase Analytics** en código (`firebase_core`, `firebase_analytics`, `AnalyticsService`)
  - Init en `main.dart`; sin API keys en `--dart-define` (config vía `firebase_options.dart`)
  - Android: permiso `AD_ID` en manifiesto + `google_analytics_adid_collection_enabled` (analíticas, no anuncios); declarar **Sí → Analíticas** en Play Console
  - Quitar `posthog_flutter` y variables `POSTHOG_*`
- [x] Vincular proyecto Firebase (manual)
  - Proyecto `mealplanner-a818e`; apps Android + iOS
  - `flutterfire configure` → `lib/core/firebase/firebase_options.dart`
  - Archivos commiteados: `google-services.json`, `GoogleService-Info.plist`
  - **No** requiere grupo env `firebase` en Codemagic (van en el repo)
- [x] Configurar **`logger`** (Dart)
  - Instancia global en `lib/core/utils/logger.dart`
  - En producción: `error`/`warning` → breadcrumbs Sentry vía `SentryLogOutput`
- [x] Instalar **`flutter_secure_storage`**
  - Sesión Supabase en Keychain/Keystore: `SecureLocalStorage` + `SecureGotrueAsyncStorage` (`supabase_client.dart`)
- [x] Instalar **`connectivity_plus`**
  - `connectivityProvider` (Riverpod) + banner «Sin conexión» global en `app.dart` (`ConnectivityBanner`)
- [x] Instalar **`upgrader`**
  - `UpgradeAlert` envuelve la app en `app.dart`
- [x] Instalar **`in_app_review`**
  - `ReviewPromptService` en `lib/core/review/review_prompt_service.dart`
  - Cooldown 6 días en secure storage; llamar `onFirstWeekCompleted()` desde el planificador (Fase 4)

### Setup CI/CD (Codemagic) ✅

> Guía de referencia: [`docs/CODEMAGIC.md`](CODEMAGIC.md)

#### Repo y pipelines

- [x] `codemagic.yaml` — workflows Android AAB + iOS IPA
- [x] Grupos declarados: `supabase`, `sentry`, `google`
- [x] `working_directory: meal_planner` (monorepo)
- [x] Firma Android en Gradle (`CM_KEYSTORE_*` + ref `meal_planner_keystore`)
- [x] Firebase commiteado (sin grupo env)
- [x] Fix `flutter analyze` en CI/CD: `lib test` + `--fatal-infos` + `flutter clean` (Android e iOS)
- [x] Merge PR [#4](https://github.com/Japegomez/meal_planner/pull/4) (`develop` → `main`)

#### Codemagic y consolas (manual)

- [x] Cuenta [codemagic.io](https://codemagic.io) + repo `Japegomez/meal_planner` conectado
- [x] Project path = `meal_planner`; config = `codemagic.yaml` desde raíz
- [x] Grupo `supabase`: `SUPABASE_URL`, `SUPABASE_ANON_KEY` (Secure)
- [x] Grupo `sentry`: `SENTRY_DSN` (Secure)
- [x] Grupo `google`: `GOOGLE_WEB_CLIENT_ID`, `GOOGLE_IOS_CLIENT_ID` (Secure)
- [x] Keystore Android subido (ref `meal_planner_keystore`)
- [x] SHA-1 release del keystore → Google Cloud (cliente OAuth Android)
- [x] Apple Developer conectado en Codemagic (firma iOS)
- [x] Primer build **Android Release** en rama `main` OK
- [x] Primer build **iOS Release** en rama `main` OK
- [x] CD automático en push a `main` activo

**Opcional post-Fase-1:** protección de ramas `main` / `develop` en GitHub.

---

## Fase 2 — Autenticación y perfiles

### Migraciones de base de datos

- [x] Aplicar migraciones `001`–`005` en Supabase remoto y verificar RLS
- [x] Crear RPC `create_household(name text)` → devuelve el hogar con `invite_code` generado
  - Migración `006_household_rpcs.sql`; aplicada en remoto (27/06/2026)
- [x] Crear RPC `join_household(code text)` → valida código e inserta en `household_members`
- [x] Crear RPC `regenerate_invite_code(household_id uuid)` → solo admin del hogar
- [x] Migración `007_storage_avatars.sql`: bucket `avatars` + RLS perfiles/avatares entre miembros del hogar
  - Aplicada en remoto (27/06/2026)

### F1 - Autenticación

- [x] Instalar y configurar cliente Supabase en Flutter (`lib/core/supabase/supabase_client.dart`)
  - PKCE + `SecureLocalStorage` / `SecureGotrueAsyncStorage` (no SharedPreferences)
- [x] Pantalla de login (email + contraseña)
- [x] Pantalla de registro (email + contraseña + nombre de usuario)
  - `register_screen.dart`; aviso de confirmación por email
- [x] Pantalla de recuperación de contraseña (envío de email)
  - `forgot_password_screen.dart`
- [x] Login con Google nativo (`google_sign_in` + `signInWithIdToken` vía Supabase)
  - Google Cloud: 3 clientes OAuth (Web, Android con SHA-1, iOS)
  - Supabase: Client ID + Secret del cliente Web; **Skip nonce check** activo
  - Android: `serverClientId` = Web Client ID; cliente `GoogleSignIn` singleton en `AuthRepository`
  - iOS: `clientId` = iOS Client ID; URL scheme invertido en `Info.plist`
  - Variables: `GOOGLE_WEB_CLIENT_ID`, `GOOGLE_IOS_CLIENT_ID` en `--dart-define` / Codemagic
  - Builds Play (closed testing / producción): SHA-1 de **App signing** en Firebase + Google Cloud; `google-services.json` con `oauth_client` no vacío (PR #33)
  - Errores `PlatformException(sign_in_failed, …: 10…)` → `AuthGoogleSignInConfigurationException` (`auth_error_mapper.dart`); guía en `docs/OAUTH_SETUP.md`
- [x] Recetario aislado por usuario: `recipesProvider` / `recipeListProvider` observan `authStateProvider` (no cachean recetas de otro usuario al cambiar sesión)
- [x] Login con Apple (Sign in with Apple; paquete `sign_in_with_apple`)
  - Configurar entitlement `com.apple.developer.applesignin` en Xcode
  - Apple Developer: App ID con Sign In with Apple activo
  - Supabase: proveedor Apple con Client ID `com.tuapp.mealplanner`
- [x] Persistencia de sesión entre cierres de la app (`supabase_flutter` + `flutter_secure_storage`)
- [x] Redirección automática: autenticado → `/home/planner`, no autenticado → `/auth/login`
  - Guard en `AppRouter` con `authStateProvider` (Riverpod)
- [x] Creación automática de perfil al registrarse por primera vez (trigger o lógica en cliente)
  - Trigger `handle_new_user` en `001_profiles.sql`
- [x] Cerrar sesión desde perfil (con confirmación modal)
  - `profile_screen.dart` en tab Perfil (`/home/profile`); `signOut(manual: true)` para no mostrar aviso de caducidad
- [x] Mensajes de error amigables en login/registro (mapeo `AuthApiException` → `AuthException`)
- [x] Sesión persistente al minimizar la app (sin cierre automático en background)
  - `SessionLifecycleHandler` ya no hace `signOut` al pausar; eliminado `signOut()` en arranque de `main.dart`
- [x] Aviso en login cuando la sesión caduca por expiración del refresh token (`AuthUnauthenticated.sessionExpired`)
- [x] Campos de contraseña con icono mostrar/ocultar (`PasswordTextField`)

### F2 - Perfil de usuario

- [x] Pantalla de perfil (nombre, avatar, hogar actual)
  - `profile_screen.dart`; tab Perfil `/home/profile`
- [x] Pantalla de edición de perfil (nombre de usuario, avatar)
  - `edit_profile_screen.dart` → `/home/profile/edit`
- [x] Subida de avatar a Supabase Storage (bucket `avatars`; compresión antes de subir)
  - `ProfileRepository.uploadAvatar`; path `{userId}/avatar.jpg`; URL firmada al leer
  - Paquete `image_picker` para seleccionar foto de galería o cámara

### F3 - Hogar compartido

- [x] Pantalla de gestión del hogar (crear o unirse)
  - `household_screen.dart` → `/home/profile/household`
- [x] Crear hogar: formulario con nombre → llamada a RPC `create_household`
  - `create_household_screen.dart`
- [x] Mostrar código de invitación del hogar (copiable al portapapeles)
- [x] Unirse a hogar: input de código de 6 caracteres → RPC `join_household`
  - `join_household_screen.dart`
- [x] Regenerar código de invitación (solo admin del hogar)
- [x] Lista de miembros del hogar con rol (admin / miembro)
- [x] Expulsar miembro del hogar (solo admin, con confirmación modal)
- [x] Abandonar hogar (con confirmación modal)
- [x] Lógica de modo individual: si el usuario no tiene hogar, usa su propio planificador y lista
  - `weekly_plans` / `shopping_lists` por `user_id` en `PlannerRepository` y `ShoppingRepository`

---

## Fase 3 — Recetario

### F4 - CRUD de recetas

- [x] Pantalla de lista del recetario (cards con foto, nombre y tags)
  - `recipe_list_screen.dart`; rutas anidadas en rama `/home/recipes`
- [x] Buscador de recetas por nombre
  - Debounce 300 ms; estado vacío distinto si hay filtro activo sin resultados
- [x] Filtro de recetas por etiqueta
  - Chips horizontales con tags del usuario
- [x] Pantalla de detalle de receta (todos los campos, ingredientes, pasos, nutrición)
  - `recipe_detail_screen.dart` → `/home/recipes/:id`
- [x] Pantalla/formulario de creación de receta
  - [x] Campo: nombre (obligatorio)
  - [x] Campo: foto (opcional; `image_picker` + subida a Supabase Storage bucket `recipe-photos`)
  - [x] Campo: raciones (obligatorio)
  - [x] Campo: tiempo de preparación (minutos, opcional)
  - [x] Campo: tiempo de cocción (minutos, opcional)
  - [x] Campo: etiquetas (chips seleccionables + opción de escribir etiqueta libre)
  - [x] Lista de ingredientes con reordenación (`ReorderableListView`)
  - [x] Lista de pasos de elaboración con reordenación
  - [x] Sección de información nutricional (calorías, proteínas, carbohidratos, grasas, fibra)
  - `recipe_form_screen.dart` → `/home/recipes/new`
- [x] Pantalla/formulario de edición de receta (misma UI que creación)
  - `/home/recipes/:id/edit`
- [x] Eliminar receta (con confirmación modal; los slots que la referencian quedan vacíos)
  - `ON DELETE SET NULL` en `plan_slots.recipe_id`

### F5 - Ingredientes

- [x] Componente `IngredientRow`: nombre, cantidad, unidad, categoría
  - `widgets/ingredient_row.dart`
- [x] Selector de unidad (lista predefinida en **singular** + campo libre; mapeo plural en `unit_mappings.dart`):
  - Peso/volumen: `g`, `kg`, `ml`, `l` (pegados a la cantidad en ficha/compra: `200g de pasta`)
  - Conteo/relativas: `unidad`, `pizca`, `cucharadita`, `cucharada`, `vaso`, `taza`, `puñado`, `hoja`, `diente`, `chorrito`, `ramita`, `rebanada`, `lámina`, `rama`, `trozo`, `filete`, `rodaja`, `lata`, `bote`, `paquete`, `sobre`
  - Plural automático si cantidad > 1 según `unitPluralMap` (editable)
- [x] Selector de categoría de ingrediente:
  - `Carnes y pescados`, `Verduras`, `Frutas`, `Lácteos`, `Cereales`, `Legumbres`, `Especias`, `Aceites y vinagres`, `Conservas`, `Frutos secos`, `Bebidas`, `Panadería`, `Congelados`, `Salsas y condimentos`, `Otros`
- [x] Añadir/eliminar ingrediente desde el formulario de receta
  - Botones «Añadir ingrediente» / «Añadir paso» al final de cada lista (mejor UX en recetas largas)
- [x] Ampliar etiquetas sugeridas (dietas, alérgenos, estilos de cocina: sin lactosa, vegano, etc.)
- [x] Marcar ingrediente como **opcional** en formulario (`is_optional`; migración `015`)
- [x] Incluir/excluir opcionales en ficha de receta (`is_included`; checkbox; tachado si excluido; migración `016`)
  - Excluidos no se sincronizan a lista de la compra al planificar (`planner_repository._syncShoppingListAdd`)
- [x] Marcar ingrediente **al gusto** (`is_to_taste`; migración `017`): no va a lista de compra; en ficha muestra «nombre al gusto»
- [x] Campo **Consejos** en receta (`recipes.tips`; migración `017`); sección en ficha y detalle público
- [x] Pasos de elaboración **opcionales** (`recipe_steps.is_optional`; migración `017`); validación exige ≥1 paso no opcional; en ficha y detalle público se muestran con prefijo **Opcional:** en negrita (`RecipeStepText`)
- [x] Cantidad numérica obligatoria si el campo no está vacío (`FilteringTextInputFormatter` + validator)
- [x] Orden de ingredientes/pasos preservado al guardar (fix `onReorder` + `ValueKey` estable + `.order(ascending: true)`)
- [x] Formato de etiquetas unificado en ficha, compra y receta pública (`ingredient_label.dart`)
- [x] Validación al guardar: al menos **1 ingrediente no opcional** (ni al gusto) y **1 paso no opcional** (`RecipeFormData.validate`)
- [x] Lista de ingredientes en ficha: viñetas verdes (`IngredientBullet`); opcionales con **checkbox** en lugar de viñeta (columna alineada); categoría no se muestra en ficha
- [x] Rendimiento formulario en recetas largas: estado mutable in-place + `TextEditingController` (sin rebuild por tecla); `setData` en `recipeFormProvider`
- [x] `fetchRecipeDetail`: ingredientes, pasos, nutrición y foto en paralelo (`Future.wait`)
- [x] Formulario con `CustomScrollView` + `SliverReorderableList` (solo filas visibles); `RepaintBoundary` por fila; items de dropdown cacheados
- [x] Reordenar ingredientes/pasos: auto-scroll al arrastrar cerca del borde; long-press en fila o asa `drag_handle`; `proxyDecorator` con sombra

---

## Fase 4 — Planificador semanal

### Migraciones de base de datos

- [x] RPC `get_or_create_weekly_plan(week_start date)` → devuelve el plan de esa semana (crea si no existe)
  - Migraciones `008_planner_rpc.sql`, `011_planner_rpc_upsert.sql`, `012_planner_rpc_fix_ambiguous_week_start.sql` (upsert atómico vía RPC; parámetro `p_week_start`)
- [x] Migración `009_plan_slots_extras.sql`: columnas `is_leftover` (boolean) y `notes` (text) en `plan_slots`
  - Aplicada en remoto (27/06/2026)

### F6 - Vista semanal

- [x] Pantalla del planificador: **layout vertical móvil** (lista de días con desayuno/comida/cena apilados; sustituye el grid 7×3 del diseño inicial)
- [x] Panel lateral deslizable con recetario (buscador + tarjetas arrastrables)
  - Lista vía `recipesProvider`; se invalida al crear/borrar receta para no mostrar recetas eliminadas
- [x] Drag-and-drop de recetas desde el panel al planificador; autoscroll al acercarse a los bordes
- [x] Navegación entre semanas (flechas anterior / siguiente; etiqueta con rango de fechas)
- [x] Indicador visual de semana actual
- [x] Slot vacío: pulsar o soltar receta para añadir
- [x] Slot con receta(s): muestra nombre(s) con chips de color según tipo (receta / sobras / texto libre)
- [x] Slot con varias recetas: lista vertical con botón «Añadir»
- [x] Desde el planificador: pulsar una receta de un slot → navegar a detalle de receta

### F7 - Gestión de slots

- [x] Modal/pantalla de selección de receta para un slot (lista del recetario con buscador)
- [x] Botón «Añadir texto libre» para entradas sin receta (nombre + raciones; no va a lista de la compra)
- [x] Al seleccionar receta (tap o drag): diálogo de raciones con stepper **− / número / +** y checkbox **Son sobras** (omite ingredientes en lista de la compra)
  - `servings_dialog.dart` → `_ServingsStepper`
- [x] Confirmar asignación: inserta fila en `plan_slots` y sincroniza ingredientes en `shopping_items` (si hay receta y no es sobra)
- [x] Actualización optimista de la UI (sin recarga completa al añadir/quitar)
- [x] Eliminar comida concreta de un slot (botón ✕ + confirmación; no afecta a otras del mismo slot)
  - Borra `shopping_items` vinculados por `plan_slot_id`; fallback legacy resta cantidades en filas antiguas consolidadas
  - Tras añadir/quitar: `shoppingItemsProvider.reload()` + recarga al abrir tab Compra

### F8 - Realtime (hogar)

- [x] Suscripción Supabase Realtime a cambios en `plan_slots` del plan activo
- [x] Refrescar UI del planificador al recibir cambios de otros miembros del hogar

---

## Fase 5 — Lista de la compra

### F9 - Vista y gestión de la lista

- [x] Pantalla de lista de la compra agrupada por categoría de ingrediente
  - `shopping_list_screen.dart`; agrupación en `groupShoppingItemsByCategory`
- [x] Ítem de lista: nombre, cantidad, unidad, categoría, estado (comprado / pendiente)
  - `shopping_item_tile.dart`
- [x] Ítem marcado como comprado: aparece tachado y se colapsa al final de su categoría
- [x] Marcar/desmarcar ítem comprado
- [x] Añadir ítem manualmente (modal con campos: nombre, cantidad, unidad, categoría)
  - `add_edit_item_sheet.dart`
- [x] Editar ítem (swipe para editar o tap largo en el ítem)
- [x] Eliminar ítem individual (swipe + confirmación)
- [x] Botón «Limpiar lista» con confirmación modal (elimina todos los ítems)

### F10 - Automatización desde el planificador

- [x] Al añadir receta al planificador: insertar ingredientes en `shopping_items` escalados por `(raciones elegidas / raciones de la receta)`
  - Omitido si `is_leftover = true` o si el slot es texto libre (`recipe_id` null)
  - Omitido si `is_included = false` (ingredientes opcionales excluidos en la ficha)
  - Omitido si `is_to_taste = true` (ingredientes al gusto)
  - Cantidades escaladas redondeadas a **enteros** (`_scaleQuantity` en `planner_repository`)
  - Cada ingrediente se inserta con `plan_slot_id` (sin fusionar filas entre comidas distintas)
- [x] Al eliminar receta del planificador: eliminar ítems por `plan_slot_id` o restar cantidad en datos legacy consolidados
  - `_syncShoppingListRemove` en `PlannerRepository`

### F11 - Exportación

- [x] Botón «Compartir lista» en la pantalla de lista de la compra
- [x] Generar texto plano con los ítems agrupados por categoría
  - Formato: `• 500g de pechuga de pollo`, `• 2 unidades de huevos`, etc. (`formatShoppingItemLabel`)
- [x] Abrir diálogo de compartir del sistema (paquete `share_plus`): compatible con WhatsApp y otras apps
  - iOS/iPad: `sharePositionOrigin` obligatorio para que aparezca el share sheet

### F12 - Realtime (hogar)

- [x] Suscripción Supabase Realtime a cambios en `shopping_items` de la lista activa del hogar
  - `ShoppingItemsNotifier` → canal `shopping_items:{listId}`
- [x] Refrescar UI de la lista al recibir cambios de otros miembros del hogar

---

## CI/CD y releases

> Infraestructura de build (Fase 1) completada. `develop` integrado en `main` (PR #32, PR #33).

### Android — Google Play

- [x] Workflow Codemagic: push a `main` → build release (AAB + IPA); `develop` → CI en GitHub Actions
- [x] `codemagic.yaml`: publicación automática a track **internal** (`publishing.google_play`, draft)
- [x] Grupo env `google_play` + service account JSON en Codemagic
- [x] `versionCode`: `max(último en Play en todos los tracks, BUILD_NUMBER workflow) + 1` (PR #29)
- [x] Declaración ID de publicidad: **Sí → Analíticas** (Firebase Analytics; permiso `AD_ID` en manifiesto, PR #30)
- [x] Primera subida manual del AAB a **Pruebas internas** en Google Play Console (obligatorio la 1.ª vez)
- [x] App instalable vía enlace de testers internos
- [x] Completar ficha Play (textos, capturas, clasificación de contenido, política de privacidad)

### iOS — App Store / TestFlight

- [x] Apple Developer Program + firma iOS en Codemagic
- [x] Primer build iOS release en Codemagic (`.ipa` generado)
- [x] `codemagic.yaml`: publicación automática a **TestFlight** (`publishing.app_store_connect`)
- [x] Integración App Store Connect API en Codemagic (`Codemagic API Key`) + `APP_STORE_APPLE_ID` en yaml
- [x] Sincronización build number con TestFlight/App Store + `ITSAppUsesNonExemptEncryption=false`
- [x] Un solo artefacto IPA/AAB por workflow (evita subidas duplicadas)
- [x] App creada en App Store Connect
- [x] Testing interno TestFlight: Sign in with Apple, Google OAuth, flujo completo de la app
- [x] Completar ficha App Store Connect y **Submit for Review**

---

## UX — Cuenta y feedback

- [ ] Prompt de valoración en tienda (`in_app_review`) tras completar la primera semana planificada
  - Cooldown de 30 días entre prompts (guardar fecha del último en `flutter_secure_storage`)
  - Fallback: enlace manual «Valorar la app» en pantalla de ajustes → URL de la store
- [ ] Banner «Sin conexión» persistente cuando no hay red (`connectivity_plus`), con reintentos automáticos al recuperarla
- [ ] Diálogo de actualización forzada (`upgrader`) cuando el backend requiera versión mínima

---

## Backlog general (sin fase asignada)

- [x] Pantalla de Términos y Condiciones (texto estático)
  - Publicado en GitHub Pages: `docs/terminos.html`; en app: WebView `/legal/terms` → `LegalUrls.terms`
- [x] Pantalla de Política de Privacidad (texto estático)
  - Publicado en GitHub Pages: `docs/privacidad.html`; en app: WebView `/legal/privacy` → `LegalUrls.privacy`
- [x] **GitHub Pages** — documentos legales (`docs/index.html`, `terminos.html`, `privacidad.html`, `style.css`)
  - Despliegue **clásico** en el repositorio: **Settings → Pages → Deploy from a branch → `/docs`**
  - Sin workflow de GitHub Actions (eliminado `.github/workflows/pages.yml`)
  - URL base: `https://japegomez.github.io/meal_planner/` (override opcional: `--dart-define=LEGAL_BASE_URL=...`)
- [x] Flujo de eliminación de cuenta (derecho de supresión RGPD)
  - RPC `delete_user_account` (migración `010`); pantalla Perfil → Eliminar cuenta
  - Pendiente: aplicar migración `010` en Supabase remoto
- [ ] Onboarding para nuevos usuarios (pantallas de bienvenida / tutorial)
- [x] Icono de app y splash screen
  - `flutter_launcher_icons`; assets en `docs/store-assets/` (PR #15)
- [ ] README de desarrollo con instrucciones de setup local
- [ ] Protección de ramas `main` / `develop` en GitHub
- [ ] Tests unitarios: escalado de ingredientes, lógica de consolidación de lista de la compra

---

## Fase 6 — Red social

> Integrada en `main` (PR #31). Migraciones `013_social` y `014_recipe_forked_from` aplicadas en remoto (28/06/2026).

### Migraciones de base de datos

- [x] Añadir tabla `recipe_ratings` (usuario, receta, puntuación 1–5)
  - Migración `013_social.sql`
- [x] Añadir tabla `follows` (follower_id, following_id)
- [x] RPC `list_public_recipes(filters)` con paginación y ordenación por valoración / fecha
- [x] Actualizar RLS en `recipes`: lectura pública si `is_public = true` (+ ingredientes, pasos, nutrición, fotos y avatares de autores)
- [x] Migración `014_recipe_forked_from.sql`: columna `forked_from_id`; constraint que impide publicar recetas forkeadas

### F13 - Recetas públicas

- [x] Campo «Publicar receta» (toggle) en formulario de creación/edición
- [x] Aviso al publicar: la receta será visible para todos los usuarios
- [x] Cambiar visibilidad desde detalle de receta (toggle con confirmación publicar / hacer privada)
- [x] Recetas forkeadas no se pueden publicar (UI + backend)

### F14 - Descubrimiento

- [x] Pantalla de exploración de recetas públicas (buscador + filtros por etiqueta)
  - Tab **Explorar** (primera posición en bottom nav: Explorar | Recetario | **Planificador** | Compra | Perfil)
- [x] Paginación / scroll infinito
- [x] Tarjeta de receta pública: foto, nombre, autor, valoración media, etiquetas

### F15 - Interacción social

- [x] Guardar receta pública de otro usuario en el recetario propio (fork)
  - Si hay ingredientes opcionales: aviso informativo + botones **Cerrar** / **Editar receta** (`fork_optional_ingredients_dialog.dart`)
  - Fork copia todos los ingredientes; el usuario ajusta inclusión en su ficha
  - **No** se puede forkear la propia receta (UI + `social_repository.forkRecipe`)
- [x] Detalle de receta pública: «Receta creada por » + nombre (enlace) o «ti» si es propia
- [x] Valorar receta pública (1–5 estrellas; una valoración por usuario por receta)
- [x] Seguir a otro usuario
- [x] Feed: recetas recientes de usuarios a los que sigo (`/home/explore/feed`)
- [x] Perfil público: foto, nombre, recetas publicadas y valoración media (`/home/explore/user/:userId`)
  - Pendiente: campo bio en perfil (no existe en esquema `profiles`)
