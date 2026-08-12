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
# Crea un .env.local (gitignored) con las claves sensibles
# echo "GOOGLE_API_KEY=tu_api_key" > .env.local
supabase secrets set --env-file .env.local
supabase functions deploy moderate-image --no-verify-jwt=false
supabase functions deploy translate-recipe
supabase functions deploy translate-titles
```

`translate-recipe` traduce la receta completa (título, tips, nombres de ingredientes y pasos) y la cachea en `recipe_translations`. `translate-titles` traduce en lote solo los títulos visibles en listas (Descubrir, Feed, recetario) y los cachea en `recipe_title_translations`. Unidades, categorías y tags son claves estables y se localizan en el cliente (no se traducen con Google).

## Edge Function: asistente IA de recetas

La función `recipe-assistant` genera fichas de receta completas o estima la información nutricional por ración usando un proveedor LLM compatible con la API de OpenAI.

La función valida el JWT de Supabase, extrae el `user_id` real y aplica cuota por usuario y tope global antes de llamar al proveedor LLM.

### Modo `generate_recipe` (texto y/o imagen)

El cliente puede enviar solo texto, solo una imagen, o ambos:

```json
{
  "mode": "generate_recipe",
  "prompt": "versión vegana para 2",
  "imageBase64": "<base64>",
  "imageMimeType": "image/jpeg"
}
```

- `prompt` y `imageBase64` son opcionales por separado, pero hace falta **al menos uno**.
- MIME permitidos: `image/jpeg`, `image/png`, `image/webp`. Límite ~1.5 MB decodificados (base64).
- Sin texto + imagen → el modelo extrae la receta de la foto.
- Texto + imagen → usa ambos (adaptar, nevera, etc.).
- El modelo debe soportar visión (Gemini Flash / Flash-Lite vía endpoint OpenAI-compatible).

### Proveedor recomendado: Google Gemini 3.5 Flash-Lite

**Mejor calidad-precio para es/en/ca/eu/gl/pt** en free tier (visión + texto). El endpoint es compatible con la API de OpenAI, así que solo cambian los secrets.

> **Importante (julio 2026):** `gemini-2.5-flash` devuelve `404 NOT_FOUND` en proyectos/cuentas nuevas ("no longer available to new users"). Usa `gemini-3.5-flash-lite` (recomendado) o `gemini-3.5-flash` (más calidad).

> **Trampa de facturación — IMPORTANTE:** Si habilitaste la facturación de Google Cloud para Translation API o Vision API, ese proyecto pasa al tier de pago de Gemini automáticamente. Para mantener el free tier de Gemini (sin billing), **usa dos proyectos GCP distintos**:
>
> - Proyecto A (billing ON): solo `GOOGLE_API_KEY` para Translation + Vision.
> - Proyecto B (billing OFF): solo `LLM_API_KEY` para Gemini. **Nunca actives billing en este proyecto.**

Configura los secrets del asistente apuntando al proyecto B. **IMPORTANTE**: no pases `LLM_API_KEY` directamente como argumento CLI (quedaría expuesto en el historial de shell y logs). Usa el archivo `.env.local` (ya incluido en `.gitignore`) y cárgalo con `--env-file`:

```bash
# Crear .env.local (gitignored) con la clave sensible
echo "LLM_API_KEY=tu_clave_proyecto_gemini_sin_billing" > .env.local

# Configurar todos los secrets de una sola vez (LLM_API_KEY desde .env.local)
npx supabase secrets set \
  --env-file .env.local \
  LLM_BASE_URL=https://generativelanguage.googleapis.com/v1beta/openai/ \
  LLM_MODEL=gemini-3.5-flash-lite \
  --project-ref hxtynisikjpwlvpdgdbt
```

Alternativa con más calidad (mismo endpoint, solo cambia el modelo):

```bash
npx supabase secrets set LLM_MODEL=gemini-3.5-flash --project-ref hxtynisikjpwlvpdgdbt
```

### Secrets de proveedor LLM

| Secret | Valor por defecto (código) | Descripción |
|---|---|---|
| `LLM_API_KEY` | — | API key del proveedor (obligatorio) |
| `LLM_BASE_URL` | `https://generativelanguage.googleapis.com/v1beta/openai/` | Endpoint OpenAI-compatible |
| `LLM_MODEL` | `gemini-3.5-flash-lite` | Modelo a invocar (`gemini-3.5-flash` si quieres más calidad) |
| `LLM_MAX_TOKENS` | `8192` (receta) / `4096` (nutrición) | Opcional; límite de tokens de salida |

Para cambiar de proveedor, solo actualiza estos secrets; el código de la función y la app no cambian.

### Secrets de cuota

| Secret | Default en código | Descripción |
|---|---|---|
| `AI_ASSISTANT_DAILY_LIMIT` | `20` | Llamadas máximas por usuario y día (genera receta + nutrición cuentan juntas) |
| `AI_ASSISTANT_MIN_INTERVAL_SECONDS` | `5` | Cooldown mínimo entre llamadas del mismo usuario (anti-bucle) |
| `AI_ASSISTANT_GLOBAL_DAILY_LIMIT` | `500` | Tope global diario de todas las llamadas de todos los usuarios; protege ante picos que agoten el RPM/tokens-día del proveedor. |
| `AI_ASSISTANT_IP_DAILY_LIMIT` | `50` | Tope diario por IP (hash SHA-256; no se guarda la IP en claro). Holgado para Wi‑Fi compartido / CGNAT. Al agotarse responde `service_at_capacity`, igual que el tope global. |

```bash
# Ejemplo activando el tope global (ajusta el número a tu cuota del proveedor)
# Si ya configuraste LLM_API_KEY previamente, estos secrets adicionales se pueden
# pasar directamente (no son tan sensibles como claves API):
npx supabase secrets set \
  AI_ASSISTANT_DAILY_LIMIT=20 \
  AI_ASSISTANT_MIN_INTERVAL_SECONDS=5 \
  AI_ASSISTANT_GLOBAL_DAILY_LIMIT=500 \
  AI_ASSISTANT_IP_DAILY_LIMIT=50 \
  --project-ref hxtynisikjpwlvpdgdbt
```

Nuevos códigos de error de cuota (distintos de `rate_limited`, que sigue siendo el 429 del *proveedor* LLM):

| Código | HTTP | Causa |
|---|---|---|
| `too_fast` | 429 | Cooldown: otra petición del mismo usuario hace menos de `AI_ASSISTANT_MIN_INTERVAL_SECONDS` |
| `daily_limit_reached` | 429 | El usuario agotó su cuota diaria |
| `service_at_capacity` | 503 | Se alcanzó el tope global diario o el tope por IP |
| `quota_check_failed` | 503 | Error interno al consultar la cuota; rechazado fail-closed |

### Migraciones de base de datos requeridas (022 y 023)

Las migraciones `022_ai_assistant_usage.sql` y `023_ai_assistant_usage_gate_order.sql` crean las tablas `ai_assistant_usage` y `ai_assistant_global_usage` y la función RPC `check_and_increment_ai_usage` con el orden de gates correcto. **Ambas deben aplicarse antes de redesplegar la función**, de lo contrario la función devolverá `quota_check_failed` en cada petición.

```bash
supabase link --project-ref hxtynisikjpwlvpdgdbt
supabase db push
supabase functions deploy recipe-assistant
```

### Alternativas de proveedor (fallback / emergencia)

Si necesitas cambiar de proveedor, actualiza los secrets `LLM_*`; el código no cambia.

#### Cerebras `gpt-oss-120b`

> **Nota:** el free trial de Cerebras (julio 2026) son solo **$5 de crédito con tarjeta que caducan en 30 días** y **5 RPM / 30K TPM**. El plan de pago (Developer PAYGO) es $0.35/$0.75 por 1M tokens con 1K RPM. No hay tier de uso gratuito indefinido.

```bash
# Actualizar .env.local con la clave de Cerebras
echo "LLM_API_KEY=csk_tu_clave" > .env.local

npx supabase secrets set \
  --env-file .env.local \
  LLM_BASE_URL=https://api.cerebras.ai/v1 \
  LLM_MODEL=gpt-oss-120b \
  --project-ref hxtynisikjpwlvpdgdbt
```

#### DeepSeek V4 Flash

Precio más bajo del mercado ($0.14/$0.28 por 1M tokens, contexto 1M). Buena calidad en es/en/pt; menos datos públicos para eu/gl/ca.

```bash
# Actualizar .env.local con la clave de DeepSeek
echo "LLM_API_KEY=tu_clave_deepseek" > .env.local

npx supabase secrets set \
  --env-file .env.local \
  LLM_BASE_URL=https://api.deepseek.com/v1 \
  LLM_MODEL=deepseek-chat \
  --project-ref hxtynisikjpwlvpdgdbt
```

#### Groq

```bash
# Actualizar .env.local con la clave de Groq
echo "LLM_API_KEY=gsk_tu_clave" > .env.local

npx supabase secrets set \
  --env-file .env.local \
  LLM_BASE_URL=https://api.groq.com/openai/v1 \
  LLM_MODEL=openai/gpt-oss-20b \
  --project-ref hxtynisikjpwlvpdgdbt
```

| Modelo Groq | Cuándo usarlo |
|---|---|
| `openai/gpt-oss-20b` | Generación de recetas (soporta JSON Schema). |
| `llama-3.1-8b-instant` | Nutrición simple (más rápido y barato). |

La función exige JWT de usuario autenticado. La app la invoca al crear una receta con el asistente o al completar la ficha nutricional de una receta existente.

## Pendiente (Fase 1 — plan §3d en adelante)

- Google Sign-In nativo: 3 clientes OAuth en Google Cloud + proveedor en Supabase
- Apple Sign-In en Supabase Auth
- Vincular Firebase Console (`flutterfire configure`) si aún no está en todos los entornos
