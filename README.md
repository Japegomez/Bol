<div align="center">

<img src="meal_planner/web/icons/Icon-512.png" alt="Böl logo" width="180"/>

# Böl

### Planifica tu semana. Comparte tu recetario. Cocina mejor.

_Aplicación móvil multiplataforma para organizar comidas, listas de la compra y recetas con ayuda de IA_

---

[![Flutter](https://img.shields.io/badge/Flutter-Dart-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3FCF8E?style=flat-square&logo=supabase&logoColor=white)](https://supabase.com/)
[![Firebase](https://img.shields.io/badge/Firebase-Hosting_+_Analytics-FFCA28?style=flat-square&logo=firebase&logoColor=white)](https://firebase.google.com/)
[![Sentry](https://img.shields.io/badge/Sentry-Observability-362D59?style=flat-square&logo=sentry&logoColor=white)](https://sentry.io/)
[![CodeRabbit](https://img.shields.io/badge/CodeRabbit-PR_reviewer-FF570A?style=flat-square&logo=coderabbit&logoColor=white)](https://www.coderabbit.ai/)

**Disponible en las principales tiendas**

[![Google Play](https://img.shields.io/badge/Google_Play-Böl-414141?style=for-the-badge&logo=google-play&logoColor=white)](https://play.google.com/store/apps/details?id=com.japegomez.meal_planner)
[![App Store](https://img.shields.io/badge/App_Store-Böl-0D96F6?style=for-the-badge&logo=app-store&logoColor=white)](https://apps.apple.com/es/app/b%C3%B6l/id6785110375)

---

</div>

## 📋 Visión del proyecto

**Böl** es una app de planificación de comidas centrada en tres ideas: un **recetario propio** claro, un **planificador semanal** visual y una **lista de la compra** siempre sincronizada. Encima de esa base añade hogar compartido en tiempo real, modo cocina paso a paso, comunidad ligera, **alergias e intolerancias en el perfil** (el asistente de IA las respeta al crear recetas) y un **asistente de IA** que entiende texto, fotos de recetas y dictado por voz.

El producto está pensado para uso real en casa: offline en modo individual, invitaciones al hogar por enlace, compartir recetas por WhatsApp/App Links y privacidad cuidada (RLS en Supabase, enlaces privados con token, moderación de imágenes, consentimientos y eliminación de cuenta).

---

## 🧭 Metodología: Spec-Driven Development

El desarrollo de **Böl** se ha llevado a cabo bajo la filosofía de **Spec-Driven Development**: requisitos y tareas formales como fuente de verdad, decisiones documentadas y revisión continua.

| Documento | Propósito |
| -------------------------------- | -------------------------------------------------------------------------------- |
| 📄 **`docs/spec-driven/REQUIREMENTS.md`** | Visión, stack, RF por módulo, decisiones de producto y seguridad |
| ✅ **`docs/spec-driven/TASKS.md`** | Backlog vivo por fases, estado de avance y próximas validaciones |
| 📌 **`supabase/README.md`** | Proyecto, migraciones, Edge Functions, secrets y cuotas de IA |
| 🔒 **`SECURITY.md`** | Cómo reportar vulnerabilidades en privado |
| 🔒 **Páginas legales** | Privacidad / términos publicados en `japegomez.github.io/Bol` |

### Flujo de trabajo con agentes

- **Cursor** (IDE agentico): planificación por sesión, edición incremental y verificación contra docs.
- **CodeRabbit**: revisor automático de PRs y commits en [GitHub](https://github.com/Japegomez/Bol) (comentarios, bugs y sugerencias).
- **GitFlow**: `main` (releases), `develop` (integración), `feature/*`.

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENTE (Flutter + Riverpod)             │
│  ┌──────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ UI +     │→ │ Providers /  │→ │ Repositorios y sync  │  │
│  │ deep links│  │ estado local │  │ (offline + Realtime) │  │
│  └──────────┘  └──────────────┘  └──────────────────────┘  │
└────────────────────────────┬────────────────────────────────┘
                             │ Supabase client (JWT + RLS)
┌────────────────────────────▼────────────────────────────────┐
│                    BACKEND (Supabase)                        │
│  ┌──────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ Auth     │  │ PostgreSQL   │  │ Edge Functions       │  │
│  │ OAuth    │  │ + RLS + RPC  │  │ recipe-assistant ·   │  │
│  │          │  │              │  │ share-landing · mods │  │
│  └──────────┘  └──────────────┘  └──────────────────────┘  │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────┐
│          SERVICIOS EXTERNOS E INFRAESTRUCTURA                │
│  Gemini (AI Studio) · Google Vision · Firebase Hosting ·    │
│  Codemagic · Sentry · CodeRabbit · GitHub                    │
└─────────────────────────────────────────────────────────────┘
```

### Principios

- **Offline-first** en modo individual con **Drift** (SQLite) y cola de sincronización.
- **Tiempo real** en hogar compartido con Supabase Realtime.
- **Seguridad**: RLS por fila, RPCs privilegiadas sin `EXECUTE` para `anon`, secretos en Supabase (nunca en la app). Los informes de vulnerabilidades van por [`SECURITY.md`](SECURITY.md), no por issues públicos.
- **Deep links universales**: HTTPS App Links / Associated Domains (`/r`, `/p`, `/h`). El esquema custom `bol://` está **deprecado**; sigue implementado en `AppBranding`, `ShareUrls`, tests y la Live Activity iOS.

---

## 🤖 IA en la app

La parte de IA está aislada en el backend para controlar costes y permisos.

### 1) Asistente de recetas (texto + foto + dictado)

**Cliente**
- Bottom sheet en el recetario (`recipe_assistant_prompt_sheet.dart`).
- Entrada: texto, **hasta 4 fotos** (galería/cámara) o **dictado nativo** (`speech_to_text` en el dispositivo).
- El dictado rellena el campo de texto; las imágenes se comprimen y se envían como base64.

**Backend: Edge Function `recipe-assistant`**
- Endpoint OpenAI-compatible hacia **Google Gemini** (por defecto `gemini-3.5-flash-lite`, configurable con secrets `LLM_*`).
- Modos:
  - `generate_recipe`: texto, imagen o ambos → receta estructurada (JSON schema) que pre-rellena el formulario.
  - `generate_nutrition`: estima kcal/macros por ración.
  - `generate_tags`: sugiere etiquetas del catálogo a partir de la ficha.
- Regla de intención:
  - Solo imagen → **extrae** la receta de la foto.
  - Imagen + texto → usa ambos (adaptar, escalar, etc.).
- **Alergias del perfil** (v1.3.0): al crear una receta nueva, el cliente envía `userAllergens` (`profiles.allergens`). La Edge Function omite o sustituye ingredientes conflictivos, auto-aplica las etiquetas `*_free` correspondientes y devuelve `allergenAdjustments` (notas en español). Si el alérgeno es core del plato (p. ej. huevo en tortilla), responde `allergen_conflict` y la app muestra un popup sin crear la receta.
- **Cuotas y límites** (servidor, `check_and_increment_ai_usage`; el mismo contador cubre receta, nutrición, `translate-recipe` y `moderate-image`): **20**/usuario/día, cooldown **5 s**, **500** global/día, **50**/IP/día (hash SHA-256). Agotar global o IP → `service_at_capacity`. Gemini solo desde la Edge Function.
- Errores localizados: offline, rate limit, cuota, imagen inválida/grande, speech no disponible, conflicto de alérgenos, etc.

### 2) Moderación de imágenes

- Edge Function `moderate-image` + **Google Cloud Vision SafeSearch**.
- Fotos de receta/avatar se validan al elegirlas (fail-closed si el servicio falla).

### 3) Traducción de recetas

- Edge Functions `translate-recipe` / `translate-titles` con Google Translate, cacheadas en PostgreSQL.
- `translate-recipe` entra en la cuota de IA; `translate-titles` no.

### Gestión de costes

- La app **nunca** ve la API key del LLM; todo va por Supabase.
- Free tier de Gemini en un proyecto GCP sin billing; Vision/Translate en otro proyecto.
- Cambiar de proveedor = cambiar secrets (`LLM_BASE_URL`, `LLM_MODEL`), sin tocar la app.

---

## ⚙️ Stack tecnológico

### App

| Tecnología | Rol |
| ---------------------- | ---------------------------------------------------- |
| 🐦 **Flutter / Dart** | Cliente iOS, Android, web y desktop |
| 🔄 **Riverpod** | Estado reactivo y providers |
| 🧭 **go_router** | Navegación + deep links |
| 💾 **Drift** | SQLite local, caché y modo offline |
| 🗣️ **speech_to_text** | Dictado nativo en el asistente |
| 📷 **image_picker** | Hasta 4 fotos de receta para la IA |
| 🔐 **flutter_secure_storage** | Sesión segura |
| 🌐 **app_links / share_plus** | Deep links y compartir |

### Backend e infraestructura

| Tecnología | Rol |
| ------------------------------ | ------------------------------------------------------------------- |
| 🟢 **Supabase** | Auth, PostgreSQL + RLS, Storage, Realtime, Edge Functions |
| 🐘 **PostgreSQL** | Migraciones y RPCs (hogar, share links, cuotas IA) |
| 🔥 **Firebase Hosting** | Landings y App Links (`/r`, `/p`, `/h`) |
| 🧠 **Gemini API** | Asistente multimodal |
| 👁️ **Google Cloud Vision** | Moderación de imágenes |
| 🌐 **Google Translate** | Traducción de recetas |

### DevOps y calidad

| Tecnología | Rol |
| ------------------------------ | ---------------------------------------------------------------- |
| 🧪 **GitHub Actions** | Job `quality` en PRs/`push` a `develop` y `main`: format, analyze, tests + umbral de coverage |
| 🤖 **Dependabot** | PRs semanales de `pub` y GitHub Actions hacia `develop` |
| 🐰 **CodeRabbit** | Revisión automática de PRs y commits |
| 📦 **Codemagic** | Builds Android (AAB) e iOS (IPA), submit a stores |
| 🛡️ **Sentry** | Errores y rendimiento |
| 📊 **Firebase Analytics** | Eventos de producto |
| 🌿 **GitFlow** | `main`, `develop`, `feature/*` |

---

## 🎯 Funcionalidades

### 🍽️ Recetario

- CRUD completo: foto moderada, ingredientes, pasos, nutrición y etiquetas
- Creación manual o con **asistente IA** (texto, dictado o hasta 4 fotos)
- Etiquetas con **orden estable** (mismo orden del catálogo en ficha, tarjetas y al guardar)
- Traducción de títulos y fichas según idioma
- Glosario culinario local

### 📅 Planificador

- Semana lunes–domingo, 3 slots/día (desayuno, comida, cena)
- Drag-and-drop, sobras, texto libre, raciones por ocasión
- Sincronización con la lista de la compra (incl. reglas de días pasados)
- Hogar compartido en tiempo real

### 🛒 Lista de la compra

- Generación automática desde el planner
- Agrupación visual, marcar hechos, editar manualmente
- Exportar/compartir por WhatsApp u otras apps

### 👨‍👩‍👧 Hogar y social

- Hogar con invitación por **enlace `/h/<codigo>`** (App Links); códigos **nuevos de 8 caracteres** (los de 6 siguen válidos) y tope de intentos al unirse
- Compartir recetas por enlace: `/r/<token>` (privado, caduca, **revocable**; lectura y fork exigen el token) y `/p/<id>` (pública)
- Explorar y feed: tarjetas alineadas con el recetario (foto cuadrada, raciones, valoración y autor)
- Perfiles públicos y valoraciones (las de recetas privadas no se listan a cualquiera)

### 🔥 Modo cocina

- Sesión paso a paso con timer y banner persistente
- Android: notificación; iOS: Live Activity

### 🔐 Cuenta y privacidad

- Email, Google y Sign in with Apple
- **Alergias e intolerancias** en el perfil (migración `048_profile_allergens`):
  - Edición con checklist en `/home/profile/allergies` (mismas claves `*_free` que las etiquetas de receta: sin gluten, sin huevo, sin cacahuetes, etc.)
  - Resumen de solo lectura en la pantalla de perfil
  - El asistente de IA las tiene en cuenta al **crear** una receta nueva (omite/sustituye ingredientes, avisa de los cambios o bloquea si el plato es imposible sin ese alérgeno)
- Offline individual, modo oscuro, eliminación de cuenta RGPD

---

## 📦 Distribución

| Plataforma | Enlace | Estado |
| ------------------ | ------------------------------------------------------------------------------------------ | ----------------------------------- |
| 🤖 **Google Play** | [Böl](https://play.google.com/store/apps/details?id=com.japegomez.meal_planner) | Prueba cerrada / publicación |
| 🍎 **App Store** | [Böl](https://apps.apple.com/es/app/b%C3%B6l/id6785110375) | Publicación |
| 🌐 **Web** | Firebase Hosting | Landing de compartición / soporte |

Los builds se generan con **Codemagic** en push a `main`. En GitHub, el check **`quality`** (format + analyze + tests/coverage) corre en PRs y pushes a `develop`/`main`.

---

## 📚 Documentación

| Recurso | Descripción |
| ----------------- | ---------------------------------------------------------------------- |
| `SECURITY.md` | Cómo reportar vulnerabilidades (no uses issues públicos) |
| `docs/spec-driven/REQUIREMENTS.md` | Especificaciones funcionales y no funcionales |
| `docs/spec-driven/TASKS.md` | Backlog vivo por fases y estado de avance |
| `supabase/README.md` | Backend, Edge Functions, secrets y despliegues |
| `meal_planner/README.md` | Setup local Flutter |

---

**Böl** · Planifica, comparte y cocina con IA

_Flutter · Supabase · Gemini · Firebase · Codemagic · Cursor · CodeRabbit_

---

Repositorio: [github.com/Japegomez/Bol](https://github.com/Japegomez/Bol)
