# MealPlanner — Requisitos Funcionales y Arquitectura

> **Versión:** 1.0 — Fase 6 en `main`; offline móvil, asistente IA y modo cocina (implementado, validación pendiente)
> **Fecha:** Agosto 2026
> **Estado:** F1–F15 en producción de código; apps en Play (closed testing) y TestFlight como **Böl**. **Modo cocina** implementado en código (sesión persistente, banner, notificación Android, Live Activity iOS); pendiente validación manual en dispositivo y perfil de la extensión en builds. También: onboarding spotlight, offline Drift (DB cifrada SQLCipher; migración plaintext con `VACUUM INTO` + `rekey` y reset si es ilegible), filtro multi-etiqueta, modo oscuro, asistente IA (nutrición estable + enteros), **migración aditiva hogar↔individual** (024), **compartir recetas por enlace** (025 + token-gate `038`/`039`), **fork atómico + rebuild compra con `is_checked`** (026), **remediación seguridad aplicada en remoto** (`037`–`045`: RLS, `REVOKE` a `anon`, cuota IA por IP). Hotfix **v1.2.4**.

---

## Índice

1. [Visión del producto](#1-visión-del-producto)
2. [Stack tecnológico](#2-stack-tecnológico)
3. [Módulos y requisitos funcionales](#3-módulos-y-requisitos-funcionales)
   - 3.1 [Autenticación y perfiles](#31-autenticación-y-perfiles)
   - 3.2 [Hogar compartido](#32-hogar-compartido)
   - 3.3 [Recetario](#33-recetario)
   - 3.4 [Planificador semanal](#34-planificador-semanal)
   - 3.5 [Lista de la compra](#35-lista-de-la-compra)
   - 3.6 [Acceso offline (móvil)](#36-acceso-offline-móvil)
   - 3.7 [Modo cocina](#37-modo-cocina)
4. [Modelo de datos](#4-modelo-de-datos)
5. [Arquitectura Flutter](#5-arquitectura-flutter)
6. [Navegación](#6-navegación)
7. [Roadmap — Fase 2 (red social)](#7-roadmap--fase-2-red-social)

---

## 1. Visión del producto

MealPlanner (marca visible **Böl**) es una app móvil (iOS y Android) que permite a usuarios individuales o grupos familiares:

- **Gestionar un recetario personal** con instrucciones, ingredientes e información nutricional.
- **Planificar las comidas de cada semana** asignando recetas a slots de desayuno, comida y cena.
- **Generar automáticamente la lista de la compra** consolidando los ingredientes de todas las recetas planificadas.
- **Compartir el planificador** con otros miembros del hogar en tiempo real.

En una fase posterior se añadió una red social para descubrir y compartir recetas públicamente (Fase 6, completada).

---

## 2. Stack tecnológico

| Capa | Tecnología | Justificación |
|---|---|---|
| App móvil | **Flutter** (Dart) | Un solo codebase para iOS y Android, renderizado propio de alta calidad, excelentes animaciones |
| Gestión de estado | **Riverpod** | Solución reactiva y testeable, primera opción en ecosistema Flutter/Supabase |
| Navegación | **go_router** | Navegación declarativa, soporte deep links, mantenida por Google |
| Backend / BaaS | **Supabase** | PostgreSQL real (relaciones complejas entre recetas, ingredientes y planificador), Auth incluida, Storage para fotos, Realtime para el hogar compartido |
| Moderación de imágenes | **Supabase Edge Functions** + **Google Cloud Vision API** (SafeSearch) | Validación server-side al elegir foto de receta o avatar; rechazo de contenido adulto/explícito |
| Almacenamiento de fotos | **Supabase Storage** | Bucket privado por usuario |
| Glosario (local) | **`shared_preferences`** | Entradas personalizadas del glosario culinario en el dispositivo |
| Autenticación | **Supabase Auth** | Email/contraseña + OAuth (Google y Sign in with Apple) en Fase 1 |
| CI/CD y builds | **Codemagic** | Builds en la nube para iOS y Android, submit automatizado a las stores |
| Crash reporting | **Sentry** | Captura de excepciones, breadcrumbs, performance traces y alertas; SDK Flutter oficial |
| Analytics | **Firebase Analytics (GA4)** | Eventos de producto; en Android declara uso de ID de publicidad solo para **analíticas** (`AD_ID` en manifiesto) |
| Logs en cliente | **`logger`** (Dart) | Logs con niveles (`debug`→`error`), pretty-print en dev, redirigibles a Sentry en prod |
| Actualizaciones forzadas | **`upgrader`** | Diálogo nativo cuando existe una versión mínima requerida en la store |
| Valoración en tienda | **`in_app_review`** | Prompt nativo semanal (cooldown 7 días) al entrar en el home tras onboarding; CTA manual «Valorar la app» en Perfil abre la ficha de la store |
| Conectividad | **`connectivity_plus`** | Detecta pérdida de red; banner «sin conexión» y bloqueo de acciones que requieren Supabase (solo iOS/Android) |
| Caché offline (móvil) | **Drift** + **sqlite3** (SQLite3MultipleCiphers) | SQLite local cifrado en iOS/Android: espejo de recetario, planificador y lista de compra; cola de operaciones pendientes |
| Almacenamiento seguro | **`flutter_secure_storage`** | Token de sesión en Keychain (iOS) / Keystore (Android) en lugar de SharedPreferences |

---

## 3. Módulos y requisitos funcionales

### 3.1 Autenticación y perfiles

**RF-AUTH-01** El usuario puede registrarse con email y contraseña.  
**RF-AUTH-02** El usuario puede iniciar sesión con email y contraseña.  
**RF-AUTH-03** El usuario puede solicitar restablecimiento de contraseña por email.  
**RF-AUTH-04** El usuario puede iniciar sesión con **Google** (OAuth 2.0 vía Supabase, disponible en iOS y Android). Si el perfil aún no tiene avatar, se importa la foto de Google (best-effort; no sobrescribe un avatar ya elegido).  
**RF-AUTH-05** El usuario puede iniciar sesión con **Apple** (*Sign in with Apple*, obligatorio en iOS cuando se ofrece cualquier otro proveedor OAuth, según las App Store Review Guidelines).  
**RF-AUTH-06** Al autenticarse por primera vez (cualquier método) se crea automáticamente un perfil con nombre de usuario y avatar opcional.  
**RF-AUTH-07** El usuario puede editar su nombre de usuario y avatar desde la pantalla de perfil (`/home/profile/edit`). La foto se elige **solo desde la galería** (sin cámara); al seleccionarla, la app la valida con moderación de contenido antes de aceptarla. El usuario puede **eliminar** la foto y volver al avatar por defecto.  
**RF-AUTH-08** El usuario puede cerrar sesión manualmente desde el perfil.  
**RF-AUTH-09** La sesión se mantiene al minimizar o cambiar de app; expira cuando caduca el refresh token de Supabase (~1 semana), tras **>10 minutos en background** (cierre automático al volver), o cuando el usuario cierra sesión manualmente.  
**RF-AUTH-10** Si la sesión caduca, la pantalla de login muestra un aviso informativo («Tu sesión ha caducado. Inicia sesión de nuevo.»); no se muestra en el primer uso ni tras cierre manual.  
**RF-AUTH-11** El usuario puede activar/desactivar el **modo oscuro** con un toggle en Perfil. Por defecto la app sigue el modo del sistema; al cambiar el toggle, la preferencia manual se persiste en el dispositivo (`shared_preferences`) y prevalece sobre el ajuste del sistema.  
**RF-AUTH-12** El perfil puede marcarse como administrador de app (`profiles.is_admin`). Solo bootstrap/service role o un admin existente pueden cambiar ese flag (trigger `profiles_guard_admin`). Los payloads de cliente no envían `is_admin`. Los clientes **no** leen la columna `is_admin` (GRANT SELECT limitado, `043`); el flag propio se obtiene con la RPC `auth_is_admin()`.  
**RF-UX-01** Tras el primer acceso autenticado, la app muestra un **tour de onboarding** (11 pasos) con overlay tipo spotlight: resalta controles concretos (FABs, buscadores, acciones de compra/comunidad, secciones de perfil), tarjeta explicativa contextual, navegación con flechas y opción Omitir. Persistencia por usuario; la barra inferior queda bloqueada hasta finalizar u omitir.  
**RF-UX-02** La app puede solicitar valoración en la store como máximo **una vez por semana** (prompt nativo vía `in_app_review` al entrar en el home tras completar onboarding; cooldown 7 días en secure storage).  
**RF-UX-03** Desde Perfil, el usuario puede abrir la ficha de la app en la store («Valorar la app» / `openStoreListing`).  
**RF-UX-04** Desde Perfil, el usuario puede **enviar feedback** (categorías: problema, sugerencia, otro; mensaje ≥ 10 caracteres) a la tabla `user_feedback`.  
**RF-UX-05** Un usuario con `profiles.is_admin = true` ve un **panel de control** en Perfil para listar feedback, filtrar por estado/categoría y marcar ítems como resueltos o ignorados. La ruta `/home/profile/admin/*` solo es accesible tras cargar el perfil y confirmar `is_admin`.  

> **Nota de implementación — avatares (migración `007_storage_avatars`):** bucket privado `avatars` con path `{user_id}/avatar.jpg`. La columna `profiles.avatar_url` almacena el path (o una URL `http…` si proviene de Google); la app resuelve URL firmada al cargar paths de Storage. RLS permite a miembros del mismo hogar leer perfiles y avatares ajenos (lista de miembros). Al elegir avatar (galería), `PhotoModerationService` invoca la Edge Function `moderate-image` (JWT de usuario); si SafeSearch detecta contenido adulto/explícito, se muestra un diálogo y no se acepta la imagen. Eliminar foto limpia `avatar_url` y, si aplica, borra el objeto en Storage (`deleteAvatar`).

> **Nota de implementación — feedback y admin (migraciones `028`–`032`, `043`):** `profiles.is_admin` (boolean, default false); `user_feedback` (category `issue|feature|other`, status `pending|resolved|ignored`, RLS insert propio / select propio o admin / update solo admin). Función `auth_is_admin()` + trigger de guardia en INSERT/UPDATE. `anon`/`authenticated` no tienen SELECT sobre `is_admin`.

> **Nota de implementación — Google (nativo):** Flutter usa `google_sign_in` para el flujo nativo del SDK de Google y `supabase_flutter` recibe la sesión con `signInWithIdToken`. En Google Cloud se crean **3 clientes OAuth** (Web, Android, iOS). Supabase Auth se configura con el Client ID + Secret del cliente **Web** y **Skip nonce check** activado (iOS). Android requiere SHA-1 del keystore debug/release **y** del certificado de **App signing** de Google Play en el cliente OAuth Android y en Firebase (sin ello, `ApiException: 10` / `DEVELOPER_ERROR`). Tras registrar huellas, regenerar `google-services.json` (`flutterfire configure`) y verificar que `oauth_client` no está vacío. Errores de configuración se mapean a `AuthGoogleSignInConfigurationException` en `auth_error_mapper.dart`. Guía: `docs/OAUTH_SETUP.md`.
>
> **Apple:** `sign_in_with_apple` + configuración en Supabase y entitlements de Xcode (`com.apple.developer.applesignin`).

---

### 3.2 Hogar compartido

Un **hogar** es un espacio compartido que agrupa un planificador semanal y una lista de la compra comunes entre varios usuarios.

**RF-HH-01** Un usuario puede crear un hogar y se convierte en su administrador.  
**RF-HH-02** El sistema genera un **código de invitación** único (alfanumérico, **8 caracteres** en códigos nuevos; los de 6 existentes siguen válidos) para cada hogar.  
**RF-HH-03** Cualquier usuario registrado puede unirse a un hogar introduciendo el código de invitación. Los intentos fallidos se limitan en servidor (`042`: intervalo mínimo, bloqueo tras 5 fallos en 5 minutos).  
**RF-HH-04** El administrador puede revocar el código de invitación y generar uno nuevo.  
**RF-HH-04b** El administrador puede **invitar por WhatsApp** (u otras apps vía `share_plus`) compartiendo un **enlace HTTPS** `…/h/<invite_code>` que abre la app en la pantalla de unirse con el código pre-rellenado (App Links / Associated Domains). Sin la app instalada, la landing `share-landing` muestra el nombre del hogar (OG) y solo el CTA de instalación (sin “Abrir en Böl”).
> **Nota de implementación — RPCs (migraciones `006`, `037`, `042`–`044`):** `create_household(name)`, `join_household(code)` y `regenerate_invite_code(household_id)` son `SECURITY DEFINER` con `GRANT` a `authenticated` (no a `anon`). El INSERT de miembros solo pasa por esas RPCs (`037`). Códigos nuevos de 8 caracteres (sin ambiguos); `join_household` hace rate-limit y devuelve NULL si el código es inválido.
>
> **UI Flutter:** `HouseholdRepository` + `currentHouseholdProvider`; miembros vía `householdMembersByIdProvider(householdId)` (family, evita dependencias circulares en Riverpod).

**RF-HH-05** El administrador puede expulsar a un miembro del hogar.  
**RF-HH-06** Un usuario puede abandonar el hogar.  
**RF-HH-07** Todos los miembros del hogar ven y editan el mismo planificador y la misma lista de la compra en tiempo real.  
**RF-HH-08** Un usuario sin hogar tiene su propio planificador y lista personal (modo individual).  
**RF-HH-09** Al **crear** o **unirse** a un hogar, el planificador individual del usuario (semana actual y futuras) se **fusiona de forma aditiva** en el planificador del hogar; la lista de la compra del hogar se **recalcula** desde ese plan.  
**RF-HH-10** Al **abandonar** el hogar, se hace un **snapshot** del planificador del hogar (semana actual y futuras) sobre el individual (sustituye esas semanas) y se recalcula la lista individual; recetas ajenas pasan a texto libre.  
**RF-HH-11** Un miembro puede abrir en solo lectura una receta de otro miembro del hogar y **añadirla a su recetario** (fork explícito vía `fork_recipe_into_my_book`).
**RF-HH-12** Mientras el usuario pertenece a un hogar, el **recetario listado** (pantalla Recetario, picker y panel del planificador) muestra las recetas de **todos los miembros** (vista conjunta). La propiedad sigue en `recipes.user_id`: solo el dueño edita/elimina; el resto ve solo lectura (+ fork). Al abandonar el hogar, la lista vuelve a las recetas propias (RLS deja de permitir SELECT de las ajenas; sin migración de ownership).

> **Nota de implementación — migración de plan (024 + 026 + `044`):** RPCs internas `merge_user_plans_into_household`, `snapshot_household_plans_to_user`, `rebuild_shopping_from_plans` (solo invocadas desde `create_household` / `join_household` / `leave_household`; **sin** `EXECUTE` para `anon` ni `authenticated`). `rebuild_shopping_from_plans` **preserva `is_checked`** de ítems automáticos que siguen existiendo (`plan_slot_id` + `ingredient_id`); ítems nuevos empiezan en `false`; manuales no se tocan. RLS `shares_household_with` para SELECT de recetas/ingredientes/pasos/nutrición/fotos entre co-miembros. Fork a recetario propio: RPC atómica `fork_recipe_into_my_book` (026, token obligatorio en enlace privado `039`) para hogar / pública / enlace activo.

---

### 3.3 Recetario

El **recetario** es la colección personal de recetas de cada usuario. Las recetas pueden ser **privadas** o **públicas** (Fase 6).

#### Campos de una receta

| Campo | Tipo | Obligatorio |
|---|---|---|
| Nombre | Texto | Sí |
| Foto | Imagen | No |
| Raciones | Número entero | Sí |
| Tiempo de preparación | Minutos (entero) | No |
| Tiempo de cocción | Minutos (entero) | No |
| Etiquetas | Lista de strings | No |
| Pasos de elaboración | Lista ordenada de textos | Sí (mínimo 1 no opcional) |
| Ingredientes | Lista (ver abajo) | Sí (mínimo 1 no opcional ni al gusto) |
| Consejos | Texto libre (trucos, variaciones) | No |
| Información nutricional | Objeto (ver abajo) | No |

#### Campos de un ingrediente

| Campo | Descripción | Ejemplos |
|---|---|---|
| Nombre | Nombre del ingrediente | "Pechuga de pollo", "Pimiento rojo" |
| Cantidad | Número (solo dígitos; opcional) | 500, 1, 0.5 |
| Unidad | Unidad en **singular** (lista predefinida o libre) | `g`, `kg`, `ml`, `l`, `unidad`, `hoja`, `diente`, `chorrito`, `pizca`, `cucharada`, etc. |
| Categoría | Agrupación para la lista de la compra (no visible en ficha); clave estable p. ej. `vegetables` | Verduras, Lácteos, Carnes y pescados, etc. (15 categorías localizadas) |
| Valores por defecto (nuevo ingrediente) | Unidad: `unidad`; categoría: `vegetables` (Verduras) | Preseleccionados en formulario y al deserializar cola offline |
| Opcional | El ingrediente puede omitirse al cocinar / en la compra | `is_optional` (autor); `is_included` (usuario en su ficha) |
| Al gusto | Sin cantidad/unidad; no se añade a la lista de la compra | `is_to_taste` (p. ej. sal, pimienta) |

#### Campos de información nutricional (por ración)

`calorías (kcal)`, `proteínas (g)`, `carbohidratos (g)`, `grasas (g)`, `fibra (g)`

#### Requisitos funcionales

**RF-REC-01** El usuario puede crear una receta rellenando el formulario con los campos anteriores. La receta debe tener al menos un ingrediente **no opcional** (ni al gusto) y al menos un paso de elaboración **no opcional**.  
**RF-REC-02** El usuario puede editar cualquier campo de una receta existente.  
**RF-REC-03** El usuario puede eliminar una receta (con confirmación). Si la receta está en el planificador, los slots quedan vacíos.  
**RF-REC-04** El usuario puede buscar recetas de su recetario por nombre.  
**RF-REC-05** El usuario puede filtrar recetas por etiqueta, seleccionando **varias etiquetas a la vez** (chips de multi-selección); una receta se muestra solo si contiene **todas** las etiquetas seleccionadas (AND). Disponible en recetario, selector/panel de recetas del planificador y pantalla de exploración.  
**RF-REC-06** Los ingredientes se pueden reordenar dentro de una receta.  
**RF-REC-07** Los pasos de elaboración se pueden reordenar.  
**RF-REC-08** La foto se sube a Supabase Storage y se asocia a la receta por URL. Al elegir la imagen en el formulario, la app la valida con moderación de contenido antes de mostrar el preview o permitir guardar.  
**RF-REC-09** El usuario puede ver el detalle completo de una receta desde el recetario o desde el planificador.  
**RF-REC-10** El usuario puede marcar un ingrediente como **opcional** al crear/editar la receta. En la ficha de su receta puede **incluir o excluir** cada opcional (checkbox en lugar de viñeta). Si está excluido, se muestra tachado y no se añade a la lista de la compra al planificar. Los ingredientes obligatorios se muestran con viñeta verde.  
**RF-REC-11** Al eliminar una receta del recetario, el panel lateral del planificador y los slots de la semana se actualizan de inmediato (invalidación de `recipesProvider` y `planSlotsProvider`).  
**RF-REC-12** El recetario es privado por usuario fuera de un hogar: al cambiar de sesión, los providers de recetas se recargan según `authStateProvider`. **Excepción (RF-HH-12):** con hogar activo, la lista es la unión de recetas de los miembros (edición solo de las propias).
**RF-REC-13** El usuario puede marcar un ingrediente como **al gusto** (`is_to_taste`). No requiere cantidad ni unidad; en ficha se muestra como «nombre al gusto» y no se sincroniza a la lista de la compra.  
**RF-REC-14** El usuario puede añadir **consejos** opcionales a la receta (`recipes.tips`); se muestran en ficha y detalle público si no están vacíos.  
**RF-REC-15** Los pasos de elaboración pueden marcarse como **opcionales** (`recipe_steps.is_optional`); en ficha y detalle público se muestran con el prefijo **Opcional:** en negrita seguido de la descripción.  
**RF-REC-16** Las unidades se almacenan en singular; si la cantidad es > 1, el plural se deriva de `unitPluralMap` (`unit_mappings.dart`).  
**RF-REC-17** Formato de etiqueta en ficha y lista de compra (`ingredient_label.dart`): peso/volumen pegado a la cantidad con «de» + nombre en minúsculas (`200g de pasta`, `125ml de leche`); resto de unidades con espacio y «de» (`2 unidades de huevos`, `4 ramas de apio`). La categoría del ingrediente no se muestra en la ficha.  
**RF-REC-18** El formulario de creación/edición debe mantenerse fluido en recetas largas: edición in-place sin rebuild global por tecla; listas de ingredientes y pasos con render perezoso (`SliverReorderableList`); auto-scroll al reordenar arrastrando cerca del borde de la pantalla (long-press en la fila o asa de arrastre).  
**RF-REC-19** En las tarjetas del recetario y de exploración, las etiquetas de receta se muestran en una fila con **scroll horizontal** para no alargar la ficha verticalmente.  
**RF-REC-20** Desde el recetario, el usuario puede abrir un **glosario culinario** (FAB con icono de libro, encima de «Nueva receta») con términos y definiciones predefinidos (p. ej. ahumar, al dente, caramelizar, tamizar), buscador y posibilidad de añadir o eliminar entradas personalizadas (persistidas en el dispositivo).  
**RF-REC-21** Las fotos de receta y los avatares de perfil se moderan al seleccionarse (no al guardar): la app envía la imagen a la Edge Function `moderate-image`, que consulta Google Cloud Vision SafeSearch. Si el contenido es adulto, violento o explícito (`LIKELY`/`VERY_LIKELY`), se rechaza con un aviso al usuario; si el servicio falla, la imagen no se acepta (fail-closed).  
**RF-REC-22** La marca visible de la app es **Böl** (`AppBranding.displayName`); nombre e icono en iOS/Android/web/desktop y textos de login/registro/onboarding. Logo lettermark basado en la **ö** (círculo + dos hojas). El identificador técnico del paquete (`meal_planner` / `com.japegomez.meal_planner`) no cambia. Los deep links de producción usan **HTTPS App Links / Associated Domains** (el esquema custom `bol://` está deprecado y retirado de los manifiestos).  
**RF-REC-23** Al añadir un ingrediente en el formulario de receta, la unidad por defecto es **`unidad`** y la categoría por defecto es **Verduras** (`vegetables`). La deserialización offline (`RecipeFormDataCodec`) aplica los mismos defaults si el payload no incluye esos campos (salvo «al gusto» o unidad personalizada).  
**RF-REC-24** El usuario puede crear una receta con **asistente de IA** (opción en el FAB del recetario): indica qué le apetece, qué tiene en la nevera, pega una receta, **adjunta como máximo cuatro fotos** (galería o cámara; payload `imageBase64` por imagen) y/o **dicta** con reconocimiento de voz nativo del dispositivo. En el sheet, las acciones (cámara, galería, micrófono) están a la **derecha**; si hay fotos adjuntas, el placeholder del campo de texto pide **indicaciones para procesar la foto**. La Edge Function `recipe-assistant` (`generate_recipe`) genera/adapta la ficha y **pre-rellena** el formulario de creación (el usuario revisa y guarda). Regla de imagen: solo foto → extracción de la receta; foto + texto → usar ambos; solo texto → comportamiento previo. Si el input es una receta pegada (o legible en la imagen), se conservan todos los ingredientes (excepto agua solo de cocción) y se dividen los pasos. Los nombres de ingrediente se normalizan a singular con mayúscula inicial.  
**RF-REC-25** El usuario puede **completar la información nutricional** de una receta existente con IA desde el detalle o el formulario de edición (`generate_nutrition`); los valores estimados por ración se pueden guardar sin reescribir el resto de la receta. Si ya hay valores, se **adjuntan** a la petición (`existingNutrition`) y el modelo debe **conservarlos** cuando sean coherentes con la receta. Los valores nutricionales son **enteros ≥ 0** end-to-end: `NutritionFormData` (`int?` + `normalizeNutritionValue`: redondeo, rechaza negativos y no finitos), schema LLM, mapper y formulario (solo dígitos). El proveedor LLM es configurable por secrets (`LLM_*`; recomendado Gemini `gemini-3.5-flash-lite` en un proyecto GCP sin facturación, separado del de Translation/Vision). Generación de receta y nutrición comparten el mismo modelo.
**RF-REC-26** El asistente IA mitiga abuso y gasto **en servidor** (`check_and_increment_ai_usage`; el cliente **no** llama a Gemini). Límites (secrets `AI_ASSISTANT_*`, producción 13/08/2026): **20 llamadas/usuario/día** (receta, nutrición, `translate-recipe` y `moderate-image` comparten contador), cooldown **5 s**, tope **global 500/día**, tope **50/día por IP** (hash SHA-256; sin IP se omite el gate). Agotar global o IP → `service_at_capacity`. Complementan (no sustituyen) cuotas del proveedor `LLM_*`. No hay contabilidad de tokens ni coste en €; solo recuento de llamadas. `translate-titles` no entra en esta cuota.

---

### 3.4 Planificador semanal

El planificador muestra una semana con 7 días × 3 slots: **Desayuno**, **Comida** y **Cena**. En móvil la UI es una **lista vertical por día** con un panel lateral del recetario (buscador + drag-and-drop) que se **superpone** a la lista (no reduce el ancho de los días).

**RF-PLAN-01** La semana comienza en lunes.  
**RF-PLAN-02** El usuario puede navegar hacia semanas pasadas y futuras con flechas de paginación.  
**RF-PLAN-03** Cada slot puede contener **una o varias comidas** (recetas del recetario o entradas de texto libre).  
**RF-PLAN-04** Para asignar una receta a un slot, el usuario la selecciona del recetario (modal con buscador) o la arrastra desde el panel lateral.  
**RF-PLAN-05** Al asignar una receta, el usuario puede ajustar el **número de raciones** para esa ocasión (por defecto las raciones de la receta) mediante un stepper **− / número / +** en el diálogo de confirmación. Los ingredientes de la lista de la compra se escalan proporcionalmente.  
**RF-PLAN-06** El usuario puede eliminar una comida concreta de un slot sin afectar al resto del mismo slot.  
**RF-PLAN-07** Al eliminar una receta del planificador, sus ingredientes generados por esa asignación se eliminan de la lista de la compra (por `plan_slot_id`).  
**RF-PLAN-08** Desde el planificador, el usuario puede pulsar la receta de un slot (chip ampliado) para abrir su ficha en el recetario. Las entradas de texto libre no navegan.  
**RF-PLAN-09** En modo hogar, todos los miembros ven y modifican el mismo planificador en tiempo real (Supabase Realtime).  
**RF-PLAN-10** El usuario puede marcar **Son sobras** desde el selector de recetas (opción al mismo nivel que texto libre): elige una receta **sin** diálogo de raciones; los ingredientes **no** se añaden a la lista de la compra. El diálogo de raciones de una asignación normal ya no incluye el checkbox de sobras.  
**RF-PLAN-11** El usuario puede añadir una **entrada de texto libre** a un slot (sin receta asociada): se guarda en `plan_slots.notes`, no genera ítems en la lista de la compra y se distingue visualmente de recetas y sobras.  
**RF-PLAN-12** El día actual de la semana visible se destaca visualmente en el planificador (fondo verde más oscuro, borde y etiqueta «Hoy») para localizarlo de un vistazo.  
**RF-PLAN-13** El usuario puede **arrastrar comidas ya asignadas** entre slots del planificador (mismo día u otro; online y offline en modo individual).  
**RF-PLAN-14** El usuario puede **copiar o compartir** el planificador semanal visible como texto plano (AppBar del planificador; mismo patrón que exportar lista de la compra).
**RF-PLAN-15** Al asignar o mover una receta a un **día calendario ya pasado** (respecto a hoy local), la app muestra un aviso y **no añade** los ingredientes de esa asignación en la lista de la compra. Al mover una receta **desde hoy o un día futuro hacia un día pasado**, se **eliminan** los ingredientes que fueron generados por esa asignación (dejando el planificador y la lista de la compra sincronizados, ya que la asignación abandona el periodo activo). Mover de un día pasado a hoy/futuro vuelve a sincronizar ingredientes si la comida no es sobras.

> **Nota de implementación — slots (migración `009_plan_slots_extras`):** `plan_slots.is_leftover boolean DEFAULT false`; `plan_slots.notes text` (nullable). Chips en UI: receta normal (`primaryContainer`), sobras (`tertiaryContainer` + icono), texto libre (naranja suave + icono); título en **1 línea** + raciones cortas (`servingsCountShort`, p. ej. `2 r.`). Panel `RecipePalette`: overlay sin `padding` derecho en la lista; scrollbar visible a la izquierda. Selector (`RecipePickerSheet`): acciones «texto libre» y «sobras» al mismo nivel; en modo sobras la lista no muestra raciones; el diálogo de raciones solo pide cantidad. El sheet se cierra antes de await del guardado del slot.

---

### 3.5 Lista de la compra

La lista de la compra está asociada al hogar (o al usuario individual) y **no está vinculada a una semana específica**: es una lista activa que se va actualizando.

**RF-SHOP-01** Cuando se añade una receta al planificador, sus ingredientes **incluidos** (`is_included = true`) y **no al gusto** (`is_to_taste = false`) se agregan automáticamente a la lista de la compra (escalados según raciones y **redondeados a enteros**). Los opcionales excluidos en la ficha no se sincronizan.  
**RF-SHOP-02** Los ingredientes se agrupan visualmente por su **categoría** (Verduras, Lácteos, etc.).  
**RF-SHOP-03** Si el mismo ingrediente aparece en varias comidas planificadas, cada asignación se persiste con su `plan_slot_id`, pero la **UI consolida** filas de receta con mismo nombre, categoría y unidad (normalizando singular/plural) sumando cantidades al mostrar y al compartir. Marcar como comprado o eliminar aplica al grupo consolidado; la edición manual queda deshabilitada en filas fusionadas.  
**RF-SHOP-04** El usuario puede añadir ítems manualmente (sin estar vinculados a ninguna receta).  
**RF-SHOP-05** El usuario puede editar la cantidad/unidad/nombre de cualquier ítem.  
**RF-SHOP-06** El usuario puede marcar ítems como **comprados** (tachado visual). Los ítems comprados se colapsan al final de su categoría.  
**RF-SHOP-07** El usuario puede desmarcar un ítem comprado.  
**RF-SHOP-08** El usuario puede eliminar un ítem individual de la lista.  
**RF-SHOP-09** El usuario puede **limpiar toda la lista** con un botón de confirmación.  
**RF-SHOP-10** El usuario puede **exportar la lista** como texto plano y compartirla por WhatsApp u otras apps del sistema (usando el `share_plus` de Flutter).  
**RF-SHOP-11** En modo hogar, todos los miembros ven la misma lista en tiempo real y pueden marcar/desmarcar ítems.

> **Nota de implementación — lista de la compra:** `ShoppingRepository` + `ShoppingItemsNotifier` (`shopping_provider.dart`). Modelos Supadart en `core/supabase/models/`. Realtime: canal `shopping_items:{listId}`. Al añadir desde planificador: `_syncShoppingListAdd` inserta filas con `plan_slot_id` solo si `ingredient.is_included` y no `is_to_taste`. Etiquetas con `formatShoppingItemLabel` (misma regla que ficha de receta). Consolidación visual: `consolidateShoppingItems` agrupa por nombre + categoría + `normalizeUnit(unit)`; toggle/delete propagan a todos los IDs del grupo. Al quitar slot: `_syncShoppingListRemove` borra por `plan_slot_id` o resta cantidades legacy; la UI se refresca con `reload()` al cambiar el planificador o al abrir la tab Compra. Compartir en iOS requiere `sharePositionOrigin` en `share_plus`.

---

### 3.6 Acceso offline (móvil)

> **Alcance:** iOS y Android únicamente. En **web** no hay caché local ni modo offline (`kIsWeb`); la app requiere conexión a Supabase. La sesión sigue persistiendo en web vía `flutter_secure_storage` / almacenamiento del navegador según plataforma.

**RF-OFF-01** Si el usuario **está autenticado** y pierde la conexión en móvil, la app muestra un diálogo informativo **una vez por sesión offline** (se resetea al volver online) con las limitaciones según el modo (individual vs hogar).  
**RF-OFF-02** En **modo individual** sin conexión, el usuario puede **consultar y editar** recetario, planificador y lista de la compra; los cambios se encolan localmente y se sincronizan con Supabase al reconectar.  
**RF-OFF-03** En **modo hogar** sin conexión, el usuario puede **consultar la última versión en caché** del recetario, planificador y lista de la compra, pero **no editar** (evita conflictos con Realtime de otros miembros).  
**RF-OFF-04** Sin conexión, la pestaña **Explorar** queda deshabilitada.  
**RF-OFF-05** Sin conexión, **no se pueden subir fotos** de receta (fail-closed, coherente con moderación server-side).  
**RF-OFF-06** Un banner persistente «Sin conexión» se muestra en la parte superior de la app mientras no hay red (solo móvil).  
**RF-OFF-07** Al recuperar la conexión, `SyncService` reproduce las operaciones pendientes en orden y resuelve IDs temporales locales.

> **Nota de implementación — caché local:** `lib/core/local_db/` (`AppDatabase` Drift, `LocalCacheStore`, conexión nativa SQLite cifrada con sqlite3mc + clave en Keychain/Keystore). Migración de ficheros plaintext previos vía `VACUUM INTO` + `PRAGMA rekey`; si el fichero no abre, se borra la caché y se regenera desde el servidor. Cola en tabla local `pending_operations`. Providers: `isOfflineProvider`, `canEditOfflineProvider`. UI: `OfflineEntryListener`, `ConnectivityBanner`, gating en formularios y `home_shell.dart`. **No** se usa Drift/WASM en web.

---

### 3.7 Modo cocina

Desde la ficha de una receta, el usuario puede iniciar una **sesión de cocina** guiada paso a paso. La sesión persiste en el dispositivo y puede minimizarse sin perder el progreso.

**RF-COOK-01** En la ficha de receta aparece el botón **Cocinar receta** (o **Continuar cocinando** si esa receta ya está en curso).  
**RF-COOK-02** Solo puede haber **una sesión de cocina activa** a la vez. Si el usuario intenta cocinar otra receta, la app pide confirmación para terminar la sesión anterior.  
**RF-COOK-03** La interfaz expandida muestra el **tiempo transcurrido** (excluyendo pausas), el paso actual y permite **navegar** entre pasos (adelante y atrás).  
**RF-COOK-04** El **primer paso** es siempre **Comprobar ingredientes**, con la lista de ingredientes de la receta (snapshot al iniciar).  
**RF-COOK-05** Un paso se marca como **completado** (tick verde en el grafo lateral) solo al **avanzar al siguiente** con la flecha derecha; navegar hacia atrás o saltar a un paso no completa pasos intermedios.  
**RF-COOK-06** La interfaz puede **minimizarse** a un banner sobre la barra de navegación inferior: título a la izquierda, tiempo centrado, botones de pausa/terminar/expandir a la derecha.  
**RF-COOK-07** El usuario puede **pausar y reanudar** la sesión; el cronómetro no cuenta el tiempo pausado.  
**RF-COOK-08** Para **terminar** la sesión, el usuario debe **mantener pulsado** el botón de parar (~1,6 s) con indicador de progreso circular, seguido de un diálogo de confirmación.  
**RF-COOK-09** La sesión se **persiste localmente** (`SharedPreferences`) y se **restaura** al reabrir la app (paso actual, pasos completados, tiempos y estado de pausa).  
**RF-COOK-10** En **Android**, mientras la sesión está activa, se muestra una **notificación persistente** en pantalla de bloqueo con cronómetro, texto del paso y acciones pausar/continuar/terminar.  
**RF-COOK-11** En **iOS 16.1+**, mientras la sesión está activa, se muestra una **Live Activity** (extensión WidgetKit `CookingActivity`) con tiempo, paso y acciones interactivas (iOS 17+) o deep links (fallback). El título y el texto del paso usan color de etiqueta del sistema (`.primary`) para legibilidad sobre `systemBackground` desde el primer render.  
**RF-COOK-12** En **web** y escritorio, la UI de cocina funciona con normalidad; notificaciones y Live Activity son **no-op** (sin acceso a APIs nativas).

> **Nota de implementación — modo cocina:** `lib/features/cooking/` (`CookingSession`, `cookingSessionProvider`, `CookingScreen`, `CookingBanner`). Integración en `home_shell.dart` (Stack) y `recipe_detail_screen.dart`. Plataforma: `CookingNotificationService` (Android), `CookingLiveActivityService` + extensión `ios/CookingActivity/` (iOS). App Group `group.com.japegomez.mealPlanner.cooking`. Target `CookingActivity` registrado en `project.pbxproj` para builds Codemagic. Perfil de aprovisionamiento App Store para `com.japegomez.mealPlanner.CookingActivity` pendiente de configuración manual.

---

## 4. Modelo de datos

Esquema PostgreSQL para Supabase. Todos los IDs son `uuid` generados por `gen_random_uuid()`.

```sql
-- Gestionado por Supabase Auth
-- auth.users (id, email, created_at, ...)

-- Perfil público del usuario
CREATE TABLE profiles (
  id          uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username    text NOT NULL,
  avatar_url  text,
  is_admin    boolean NOT NULL DEFAULT false,
  created_at  timestamptz DEFAULT now()
);

-- Feedback in-app (moderación admin)
CREATE TABLE user_feedback (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  category   text NOT NULL CHECK (category IN ('issue', 'feature', 'other')),
  message    text NOT NULL CHECK (char_length(trim(message)) >= 10),
  status     text NOT NULL DEFAULT 'pending'
               CHECK (status IN ('pending', 'resolved', 'ignored')),
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Hogares
CREATE TABLE households (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name         text NOT NULL,
  invite_code  text UNIQUE NOT NULL,  -- 8 caracteres en códigos nuevos (042); 6 legacy válidos
  created_by   uuid REFERENCES profiles(id),
  created_at   timestamptz DEFAULT now()
);

-- Miembros del hogar
CREATE TABLE household_members (
  household_id  uuid REFERENCES households(id) ON DELETE CASCADE,
  user_id       uuid REFERENCES profiles(id) ON DELETE CASCADE,
  role          text NOT NULL DEFAULT 'member', -- 'admin' | 'member'
  joined_at     timestamptz DEFAULT now(),
  PRIMARY KEY (household_id, user_id)
);

-- Recetas
CREATE TABLE recipes (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid REFERENCES profiles(id) ON DELETE CASCADE,
  title         text NOT NULL,
  photo_url     text,
  servings      int NOT NULL DEFAULT 1,
  prep_time     int,  -- minutos
  cook_time     int,  -- minutos
  tags          text[] DEFAULT '{}',
  is_public     boolean DEFAULT false,  -- para Fase 2
  created_at    timestamptz DEFAULT now(),
  updated_at    timestamptz DEFAULT now()
);

-- Ingredientes de una receta
CREATE TABLE ingredients (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id   uuid REFERENCES recipes(id) ON DELETE CASCADE,
  name        text NOT NULL,
  quantity    numeric,         -- puede ser decimal (0.5, 1.5...)
  unit        text,            -- 'g', 'kg', 'unidad', 'cucharada', etc.
  category    text,            -- 'Verduras', 'Lácteos', etc.
  position    int NOT NULL DEFAULT 0,
  is_optional boolean NOT NULL DEFAULT false,  -- migración 015
  is_included boolean NOT NULL DEFAULT true    -- migración 016; solo relevante si is_optional
);

-- Pasos de elaboración
CREATE TABLE recipe_steps (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id   uuid REFERENCES recipes(id) ON DELETE CASCADE,
  position    int NOT NULL,
  description text NOT NULL
);

-- Información nutricional (por ración)
CREATE TABLE nutrition_info (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id     uuid UNIQUE REFERENCES recipes(id) ON DELETE CASCADE,
  calories      numeric,   -- kcal
  protein       numeric,   -- g
  carbohydrates numeric,   -- g
  fat           numeric,   -- g
  fiber         numeric    -- g
);

-- Planificador semanal
CREATE TABLE weekly_plans (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Una de las dos FKs es NOT NULL según si el usuario tiene hogar o no
  household_id  uuid REFERENCES households(id) ON DELETE CASCADE,
  user_id       uuid REFERENCES profiles(id) ON DELETE CASCADE,
  week_start    date NOT NULL,  -- siempre lunes (ISO week)
  created_at    timestamptz DEFAULT now(),
  UNIQUE (household_id, week_start),
  UNIQUE (user_id, week_start),
  CHECK (
    (household_id IS NOT NULL AND user_id IS NULL) OR
    (household_id IS NULL AND user_id IS NOT NULL)
  )
);

-- Slots del planificador
CREATE TABLE plan_slots (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id      uuid REFERENCES weekly_plans(id) ON DELETE CASCADE,
  day_of_week  int NOT NULL,   -- 1=lunes … 7=domingo
  meal_type    text NOT NULL,  -- 'breakfast' | 'lunch' | 'dinner'
  recipe_id    uuid REFERENCES recipes(id) ON DELETE SET NULL,
  servings     int NOT NULL DEFAULT 1,  -- raciones ajustadas al planificar
  position     int NOT NULL DEFAULT 0,  -- orden de las recetas dentro del slot
  is_leftover  boolean NOT NULL DEFAULT false,  -- migración 009: omite sync con lista de la compra
  notes        text                            -- migración 009: entrada de texto libre (sin recipe_id)
  -- Sin UNIQUE(plan_id, day_of_week, meal_type): un slot admite múltiples recetas
);

-- Lista de la compra
CREATE TABLE shopping_lists (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id  uuid REFERENCES households(id) ON DELETE CASCADE,
  user_id       uuid REFERENCES profiles(id) ON DELETE CASCADE,
  created_at    timestamptz DEFAULT now(),
  CHECK (
    (household_id IS NOT NULL AND user_id IS NULL) OR
    (household_id IS NULL AND user_id IS NOT NULL)
  )
);

-- Ítems de la lista de la compra
CREATE TABLE shopping_items (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shopping_list_id uuid REFERENCES shopping_lists(id) ON DELETE CASCADE,
  name             text NOT NULL,
  quantity         numeric,
  unit             text,
  category         text,
  is_checked       boolean DEFAULT false,
  is_manual        boolean DEFAULT false,  -- true si fue añadido manualmente
  -- Referencia opcional al slot que lo generó (para poder restar al quitar receta)
  plan_slot_id     uuid REFERENCES plan_slots(id) ON DELETE SET NULL,
  ingredient_id    uuid REFERENCES ingredients(id) ON DELETE SET NULL,
  created_at       timestamptz DEFAULT now()
);
```

### Diagrama simplificado

```
profiles ──┬── recipes ──┬── ingredients
           │             ├── recipe_steps
           │             └── nutrition_info
           │
           ├── household_members ── households
           │
           ├── weekly_plans ──── plan_slots ── recipes
           │         │
           └── shopping_lists ── shopping_items
```

---

## 5. Arquitectura Flutter

### Estructura de carpetas (Feature-First)

```
lib/
├── main.dart
├── app.dart                   # MaterialApp + router + providers globales
│
├── core/
│   ├── supabase/              # Cliente Supabase, constantes
│   ├── local_db/              # AppDatabase (Drift), LocalCacheStore, conexión nativa
│   ├── offline/               # isOfflineProvider, canEditOfflineProvider, excepciones
│   ├── sync/                  # SyncService, cola pending_operations
│   ├── moderation/            # PhotoModerationService, diálogos de rechazo
│   ├── theme/                 # ThemeData, colores, tipografía, theme_mode_provider
│   ├── utils/                 # Formatters, helpers, extensiones
│   └── widgets/               # ConnectivityBanner, OfflineEntryListener, etc.
│
├── features/
│   ├── auth/
│   │   ├── data/              # auth_repository.dart
│   │   ├── domain/            # auth_state.dart, auth_exception.dart
│   │   └── presentation/      # login, register, forgot_password, auth_provider
│   │
│   ├── profile/
│   │   ├── data/              # profile_repository.dart
│   │   └── presentation/      # profile_screen, edit_profile_screen, profile_provider
│   │
│   ├── household/
│   │   ├── data/              # household_repository.dart
│   │   ├── domain/            # household_member_info.dart
│   │   └── presentation/      # household, create, join screens + household_provider
│   │
│   ├── recipes/
│   │   ├── data/              # recipes_repository.dart
│   │   ├── domain/            # recipe_model.dart, ingredient_model.dart
│   │   └── presentation/      # recipe_list, recipe_detail, recipe_form
│   │
│   ├── planner/
│   │   ├── data/              # planner_repository.dart
│   │   ├── domain/            # slot_item.dart, planner_constants.dart
│   │   └── presentation/      # planner_screen, recipe_picker, meal_slot, recipe_palette, servings_dialog
│   │
│   ├── shopping/
│   │   ├── data/              # shopping_repository.dart
│   │   └── presentation/      # shopping_list_screen, shopping_provider, add_edit_item_sheet, shopping_item_tile
│   │
│   └── social/
│       ├── data/              # social_repository.dart
│       └── presentation/      # explore, feed, public profile, ratings, fork
│
└── router/
    └── app_router.dart        # go_router: rutas y guards de auth
```

### Paquetes principales

| Paquete | Uso |
|---|---|
| `supabase_flutter` | Cliente oficial Supabase |
| `flutter_riverpod` | Gestión de estado |
| `go_router` | Navegación declarativa |
| `google_sign_in` | Google Sign-In nativo → `signInWithIdToken` en Supabase |
| `sign_in_with_apple` | Sign in with Apple (obligatorio en iOS con OAuth) |
| `image_picker` | Selección de foto de receta |
| `share_plus` | Exportar lista de la compra y compartir enlaces de recetas |
| `app_links` | Deep links HTTPS (Firebase Hosting) y esquema `bol://` |
| `intl` | Formateo de fechas (semanas) |
| `flutter_slidable` | Swipe en ítems de lista |
| `cached_network_image` | Caché de fotos de recetas y avatares |
| `sentry_flutter` | Crash reporting y performance traces |
| `firebase_core` + `firebase_analytics` | Analytics de producto (GA4) |
| `logger` | Logs estructurados con niveles en cliente |
| `upgrader` | Diálogo de actualización forzada desde la store |
| `in_app_review` | Prompt nativo semanal + apertura de ficha en store desde Perfil |
| `connectivity_plus` | Detección de estado de red (móvil) |
| `drift` + `sqlite3` (sqlite3mc) | Caché SQLite cifrada offline en iOS/Android |
| `flutter_secure_storage` | Almacenamiento seguro de tokens (Keychain / Keystore) |

> **Web:** `supabase_flutter` arrastra `passkeys_web` (WebAuthn). Incluir `web/passkeys_bundle.js` en `index.html` antes de `flutter_bootstrap.js`.

### Flujo de datos clave: añadir receta al planificador

```
Usuario selecciona receta + slot + raciones
        │
        ▼
PlanSlotsNotifier.addSlot(...)
        │
        ├─► PlannerRepository.addSlot(...)           → Supabase: plan_slots
        │
        └─► PlannerRepository._syncShoppingListAdd(...) → Supabase: shopping_items
              (escala × servings/recipe.servings; una fila por ingrediente con plan_slot_id)
        │
        └─► shoppingItemsProvider.reload()
```

### Realtime (hogar compartido)

Supabase Realtime usa canales de Postgres CDC. Se suscriben dos streams:

```dart
// En HouseholdPlannerNotifier
supabase
  .channel('planner:${householdId}')
  .onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'plan_slots',
    filter: PostgresChangeFilter(type: FilterType.eq, column: 'plan_id', value: planId),
    callback: (payload) => _refreshSlots(),
  )
  .subscribe();

// En ShoppingItemsNotifier
supabase
  .channel('shopping_items:${listId}')
  .onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'shopping_items',
    filter: PostgresChangeFilter(type: FilterType.eq, column: 'shopping_list_id', value: listId),
    callback: (payload) => _reloadFromServer(),
  )
  .subscribe();
```

---

## 6. Navegación

```
/                         → Redirect según auth
/auth/login
/auth/register
/auth/forgot-password
/share/r/:token           → Resolver enlace privado de receta
/p/:id                    → Redirect a detalle público
/r/:token                 → Redirect a resolver privado
/home                     → Shell con bottom nav (Explorar | Recetario | Planificador | Compra | Perfil)
  /home/explore           → Exploración de recetas públicas
    /home/explore/feed    → Feed de usuarios seguidos
    /home/explore/user/:userId → Perfil público
    /home/explore/:id     → Detalle de receta pública (valorar, fork)
  /home/recipes           → Lista del recetario
    /home/recipes/glossary → Glosario culinario (términos + entradas personalizadas)
    /home/recipes/:id     → Detalle de receta (toggle visibilidad pública/privada)
    /home/recipes/new     → Formulario nueva receta
    /home/recipes/:id/edit
  /home/shopping          → Lista de la compra
  /home/planner           → Planificador semanal
  /home/profile           → Perfil (avatar, hogar, cerrar sesión)
    /home/profile/edit
    /home/profile/household
      /home/profile/household/create
      /home/profile/household/join
```

---

## 7. Red social (Fase 6 — implementada)

Migraciones `013_social` y `014_recipe_forked_from`. Feature en `lib/features/social/`.

- **RF-SOC-01** El usuario puede marcar una receta como pública y visible para todos (formulario y detalle). Recetas forkeadas (`forked_from_id`) no se pueden publicar.
- **RF-SOC-02** Pantalla de exploración (`/home/explore`) con buscador, filtro **multi-etiqueta** (AND, `list_public_recipes` con `p_tags text[]` y `@>`), chips de orden recientes/top, scroll infinito (**10** recetas por página) e indicador «Ordenado por: …» (icono de orden) debajo de las etiquetas. Orden por defecto: fecha de creación descendente. Cada tarjeta muestra foto cuadrada **84×84**, datos compactos (título, autor con área táctil ampliada, valoración, raciones) y **etiquetas en fila a ancho completo** bajo la foto (scroll horizontal). Nombre del autor enlazado al perfil público, con tipografía destacada.
- **RF-SOC-03** El usuario puede guardar una receta pública de **otro** usuario en su recetario (fork atómico `fork_recipe_into_my_book`); no puede forkear la propia. Queda privada y no republicable. Si tiene ingredientes opcionales, se muestra un aviso y el usuario puede editar la inclusión en su ficha.
- **RF-SOC-04** Valoración 1–5 estrellas (una por usuario y receta; no en recetas propias).
- **RF-SOC-05** Seguir usuarios (desde perfil público; acceso al perfil desde el nombre del autor en tarjeta o detalle) y feed en `/home/explore/feed` con filtro multi-etiqueta, orden por fecha de creación e indicador «Ordenado por: Más reciente».
- **RF-SOC-06** Perfil público con avatar, nombre, recetas publicadas y valoración media. Sin campo bio (no está en `profiles`).
- **RF-SOC-07** En el detalle de receta pública: texto «Receta creada por » (sin enlace) + nombre del autor (enlace al perfil), o «Receta creada por ti» si es la propia receta; fecha de creación visible junto a valoración y raciones.
- **RF-SOC-08** El usuario puede **compartir una receta por enlace HTTPS** (WhatsApp u otras apps vía `share_plus`):
  - Receta **privada propia**: enlace opaco `/r/<token>`; caduca a **30 días**; se reutiliza mientras esté activo; la receta **no** se hace pública. El dueño puede **revocar** el enlace. La lectura y el fork exigen el token (`get_shared_recipe` / `fork_recipe_into_my_book` con `p_share_token`; migraciones `038`/`039`/`040`).
  - Receta **pública** (propia o de Explore): enlace estable `/p/<recipe_id>`.
  - Abrir el enlace exige **sesión**; tras login se muestra la ficha (solo lectura si no es propia) con opción de **fork**.
  - **Compartir:** enlace HTTPS + texto (sin adjuntar foto). Landing `share-landing` publica HTML de título en Storage (solo CTA **Instalar la app**; sin “Abrir en Böl”). Firebase Hosting redirige `/r/*`, `/p/*` y `/h/*`. Migraciones `025`, `032`, `034`, `036`–`045`.
  - En app: `ShareUrls` (base Firebase Hosting; también `householdInviteLink`); pending link en `FlutterSecureStorage`; token de share vía `go_router` `extra` (no query); tests `share_urls_test.dart`.

```text
/share/r/:token           → Resolver enlace privado → /home/recipes/:id
/p/:id                    → Redirect → /home/explore/:id
/r/:token                 → Redirect → /share/r/:token
/h/:code                  → Redirect → /home/profile/household/join?code=
```
