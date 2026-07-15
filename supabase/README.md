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
- Restricción de aplicación: **Ninguna** (las Edge Functions de Supabase no tienen egress IP estático; la restricción por IP no aplica).
- Restricción de API: **Cloud Vision API** y **Cloud Translation API** (según funciones que uses).
- Usa un proyecto y API key **dedicados por entorno** (dev/staging/prod) si es posible.
- Configura **cuotas y alertas** en Google Cloud para detectar uso anómalo.
- Restringir solo las APIs permitidas **no protege** ante una filtración de la clave: trata `GOOGLE_API_KEY` como secreto y rota si se expone.

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

## Edge Function: asistente IA de recetas

La función `recipe-assistant` genera fichas de receta completas o estima la información nutricional por ración usando un proveedor LLM compatible con la API de OpenAI.

**Proveedor recomendado:** [Cerebras](https://cloud.cerebras.ai) con `gpt-oss-120b` (JSON Schema nativo, 1M tokens/día gratis, ~30 RPM).

**Secrets (Supabase):**

| Secret | Valor por defecto (código) | Descripción |
|---|---|---|
| `LLM_API_KEY` | — | API key del proveedor |
| `LLM_BASE_URL` | `https://generativelanguage.googleapis.com/v1beta/openai/` | Endpoint OpenAI-compatible |
| `LLM_MODEL` | `gemini-2.5-flash` | Modelo a invocar |
| `LLM_MAX_TOKENS` | `8192` (receta) / `1024` (nutrición) | Opcional; límite de salida |

Para cambiar de proveedor, solo actualiza estos secrets; el código de la función y la app no cambian.

### Cerebras (recomendado)

1. Crea una API key en [cloud.cerebras.ai](https://cloud.cerebras.ai) (prefijo `csk_`).
2. Configura los secrets (no hace falta redesplegar la función):

```bash
npx supabase secrets set \
  LLM_API_KEY=csk_tu_clave \
  LLM_BASE_URL=https://api.cerebras.ai/v1 \
  LLM_MODEL=gpt-oss-120b \
  --project-ref hxtynisikjpwlvpdgdbt
```

Límites free orientativos: **1M tokens/día**, ~30 RPM, ~60K TPM. Soporta `json_schema` estándar (la función usa `strict: false`).

### Google Gemini (alternativa)

```bash
npx supabase secrets set \
  LLM_API_KEY=tu_clave_google \
  LLM_BASE_URL=https://generativelanguage.googleapis.com/v1beta/openai/ \
  LLM_MODEL=gemini-2.5-flash \
  --project-ref hxtynisikjpwlvpdgdbt
```

### Probar con Groq

1. Crea una API key en [console.groq.com/keys](https://console.groq.com/keys) (empieza por `gsk_`).
2. Configura los secrets (no hace falta redesplegar la función):

```bash
supabase secrets set \
  LLM_API_KEY=gsk_tu_clave \
  LLM_BASE_URL=https://api.groq.com/openai/v1 \
  LLM_MODEL=openai/gpt-oss-20b
```

| Modelo Groq | Cuándo usarlo |
|---|---|
| `openai/gpt-oss-20b` | **Recomendado** para el asistente: soporta JSON Schema (salida estructurada de recetas). |
| `llama-3.3-70b-versatile` | Más capacidad de razonamiento; prueba si `gpt-oss-20b` no te convence. |
| `llama-3.1-8b-instant` | Más rápido y barato en cuota; mejor para nutrición simple. |

Límites gratis orientativos: ~30 RPM, ~1.000 peticiones/día (varía por modelo). Para volver a Gemini, repite `supabase secrets set` con los valores de Google.

La función exige JWT de usuario autenticado. La app la invoca al crear una receta con el asistente o al completar la ficha nutricional de una receta existente.

## Pendiente (Fase 1 — plan §3d en adelante)

- Google Sign-In nativo: 3 clientes OAuth en Google Cloud + proveedor en Supabase
- Apple Sign-In en Supabase Auth
- Vincular Firebase Console (`flutterfire configure`) si aún no está en todos los entornos
