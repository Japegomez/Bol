# Supabase — MealPlanner

## Proyecto remoto

| Campo | Valor |
|---|---|
| Nombre | `meal_planner` |
| Región | `eu-west-1` |
| Project ref | `hxtynisikjpwlvpdgdbt` |
| URL | `https://hxtynisikjpwlvpdgdbt.supabase.co` |

Migraciones `001`–`016` aplicadas (tablas, RLS, RPCs hogar, buckets Storage, Realtime, eliminación de cuenta, red social Fase 6, forked recipes, ingredientes opcionales).

## Variables para Flutter

En **Settings → API** copia:

- `Project URL` → `SUPABASE_URL`
- `anon public` → `SUPABASE_ANON_KEY`

Pásalas al ejecutar/build (recomendado: archivo `dart_defines.json`):

```bash
cd meal_planner
flutter run -d emulator-5554 --dart-define-from-file=dart_defines.json
```

Ver [`../docs/TASKS.md`](../docs/TASKS.md) → **Prueba local (emulador Android)**.

## Aplicar migraciones (referencia)

Si necesitas reaplicar en otro entorno, con [Supabase CLI](https://supabase.com/docs/guides/cli):

```bash
supabase link --project-ref hxtynisikjpwlvpdgdbt
supabase db push
```

O aplica cada archivo en `migrations/` desde el SQL Editor, en orden `001` → `016`.

## Generar tipos Dart (Supadart)

La CLI oficial de Supabase ya no genera Dart. Usamos [Supadart](https://github.com/mmvergara/supadart).

**Requisitos:** migraciones `001`–`016` aplicadas (ya están en el proyecto remoto).

```bash
cd meal_planner
# Añade SUPABASE_SERVICE_ROLE_KEY en .env (solo para generar; no va en la app)

# CMD (Anaconda, etc.)
tool\generate_models.bat

# PowerShell
.\tool\generate_models.ps1

# Manual
dart pub get && dart run supadart
```

- Credenciales en `meal_planner/.env`: `SUPABASE_URL` + **`SUPABASE_SERVICE_ROLE_KEY`** (Dashboard → Settings → API)
- La anon key **no** sirve para Supadart desde 2025; la service role es solo para este comando local
- Salida: `meal_planner/lib/core/supabase/models/`
- Tras cambiar el esquema: reaplica migraciones y vuelve a ejecutar `supadart`

## Storage y Realtime

- `005_shopping.sql`: bucket `recipe-photos` + Realtime en `plan_slots` y `shopping_items`
- `007_storage_avatars.sql`: bucket privado `avatars` (2 MB, jpeg/png/webp) + RLS para miembros del hogar
- `010_delete_account_rpc.sql`: RPC `delete_user_account()` — supresión RGPD (borra `auth.users` y datos en cascada)
- `013_social.sql`: `recipe_ratings`, `follows`, RLS recetas públicas, RPC `list_public_recipes`, lectura storage fotos/avatares de autores públicos
- `014_recipe_forked_from.sql`: `forked_from_id`; recetas forkeadas no pueden ser públicas
- `015_ingredients_optional.sql`: `ingredients.is_optional`
- `016_ingredients_included.sql`: `ingredients.is_included` (inclusión en ficha y sync compra)

## Edge Function: moderación de imágenes

La función `moderate-image` analiza fotos de recetas y avatares con Google Cloud Vision SafeSearch antes de aceptarlas en la app.

**Requisitos:** API key de Google Cloud con [Cloud Vision API](https://console.cloud.google.com/apis/library/vision.googleapis.com) y, para traducción de recetas, [Cloud Translation API](https://console.cloud.google.com/apis/library/translate.googleapis.com) habilitadas en el mismo proyecto, con **facturación activada** (tier gratuito generoso en ambas).

**Configuración de la API key (importante):**
- Restricción de aplicación: **Ninguna** (las funciones corren en servidores de Supabase, no en el navegador).
- Restricción de API: **Cloud Vision API** y **Cloud Translation API** (según funciones que uses).

Secreto compartido en Supabase: `GOOGLE_API_KEY`.

```bash
supabase link --project-ref hxtynisikjpwlvpdgdbt
# Crea un .env.local (gitignored) con GOOGLE_API_KEY=tu_api_key
supabase secrets set --env-file .env.local
supabase functions deploy moderate-image --no-verify-jwt=false
supabase functions deploy translate-recipe
supabase functions deploy translate-titles
```

`translate-recipe` traduce la receta completa (título, tips, nombres de ingredientes y pasos) y la cachea en `recipe_translations`. `translate-titles` traduce en lote solo los títulos visibles en listas (Descubrir, Feed, recetario) y los cachea en `recipe_title_translations`. Unidades, categorías y tags son claves estables y se localizan en el cliente (no se traducen con Google).

La función exige JWT de usuario autenticado (comportamiento por defecto). La app invoca la función al seleccionar una imagen en el formulario de receta o en editar perfil.

## Pendiente (Fase 1 — plan §3d en adelante)

- Google Sign-In nativo: 3 clientes OAuth en Google Cloud + proveedor en Supabase
- Apple Sign-In en Supabase Auth
- Vincular Firebase Console (`flutterfire configure`) si aún no está en todos los entornos
