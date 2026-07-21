# Recipe WhatsApp share links (private token + public deep link)

**Date:** 2026-07-21  
**Status:** Implemented (device QA pending)  
**Scope:** Share recipes via WhatsApp (or system share sheet); open recipe detail in app when logged in; fork option; Firebase Hosting + App/Universal Links
**Live host:** `https://mealplanner-a818e.web.app`  
**Android SHA-256 in assetlinks:** Play app signing key (closed testing / production installs)

## Problem

Users want to send an individual recipe over WhatsApp even when it is not public. Recipients should land on the recipe detail in the app and be able to fork it into their book. Today there is no share URL for recipes, no App/Universal Links for recipe routes, and RLS blocks non-public recipes outside owner/household.

## Goals

1. Owner can **share a private recipe** without setting `is_public = true`.
2. Anyone can **share a public recipe** (own or from Explore) via a stable link.
3. Opening the link requires **authentication**; after login, show recipe detail (read-only if not owned) with **fork** when applicable.
4. Private share links **expire after 30 days**; while valid, reuse the same URL; after expiry, generate a new one (no mid-life revoke).
5. Host links on **Firebase Hosting** (`*.web.app` first; custom domain later optional).

## Non-goals

- Revoking an active private link before expiry.
- Opening shared recipes without login.
- Rich WhatsApp OG previews beyond a minimal landing.
- Advanced click analytics.
- Sharing shopping lists (already exists) or household invite-by-link.

## Decisions

| Topic | Choice |
| --- | --- |
| Access gate | Logged-in users only |
| Private recipes | Opaque share token; recipe stays `is_public = false` |
| Public recipes | Stable deep link by `recipe_id` (no token table) |
| Private link lifetime | 30 days from creation |
| Link management | Reuse active link; create new only when none/expired; no revoke UI |
| Hosting | Firebase Hosting (existing Firebase project) |
| Domain | Start with `*.web.app`; custom domain optional later |
| OS routing | Universal Links (iOS) + App Links (Android) |
| Recipient action | Read-only detail + fork into own book (existing fork flows) |

## URL shapes

| Kind | Path | Lifetime |
| --- | --- | --- |
| Private share | `https://<firebase-host>/r/<token>` | 30 days |
| Public share | `https://<firebase-host>/p/<recipe_id>` | Stable while recipe remains public |

Do **not** put raw private `recipe_id` in a guessable public URL for non-public recipes.

## Data model

### `recipe_share_links`

Suggested columns:

- `id` (uuid, pk)
- `recipe_id` (fk → `recipes`, cascade on delete)
- `token` (text, unique, opaque URL-safe)
- `created_by` (uuid, fk → auth user / profiles)
- `created_at` (timestamptz)
- `expires_at` (timestamptz) — `created_at + 30 days`

Constraints / rules:

- Only the recipe owner can insert rows for that recipe.
- At most one **active** link per recipe (`expires_at > now()`); enforce in RPC or partial unique index if practical.
- No delete/revoke API in MVP; expiry is the invalidation path.

### Access resolution

- RPC (preferred) e.g. `resolve_recipe_share(token text)`:
  - Requires `auth.uid()`.
  - Validates token exists and `expires_at > now()`.
  - Ensures recipe still exists.
  - Returns recipe payload needed for read-only detail (or `recipe_id` + app loads detail).
- Public path `/p/:id`: use existing public-recipe read paths (RLS `is_public`); if not public → error state.

Fork: reuse existing `forkIntoMyBook` / social fork after resolve; block self-fork.

## App UX

### Owner — private recipe detail

1. **Share** action.
2. Ensure active link (reuse or create).
3. System share sheet (`share_plus`) with recipe title + private URL.

### Anyone — public recipe detail (Explore or owned public)

1. **Share** action.
2. Build public URL `/p/<recipe_id>`.
3. System share sheet with title + URL.

### Recipient

1. Opens HTTPS link (WhatsApp or elsewhere).
2. Firebase landing tries to hand off to the app; if not installed, minimal CTA to store / open app.
3. App receives deep link.
4. If logged out → login, then continue to target.
5. Show recipe detail (read-only if not owned) + **Save to my recipe book** (fork) when allowed.
6. Error screens: expired/invalid token, recipe deleted, recipe no longer public (`/p/...`).

## Firebase Hosting + OS association

- Host static landing under existing Firebase project (`mealplanner-a818e`).
- Routes: `/r/<token>`, `/p/<recipe_id>` (SPA or simple redirect pages).
- Publish:
  - `/.well-known/apple-app-site-association`
  - `/.well-known/assetlinks.json`
- Flutter: handle incoming links (`app_links` or current stack) and map to go_router routes that resolve token or public id.
- Custom domain can be attached later to the same hosting site without changing token/public model.

## Security notes

- Tokens must be unguessable (UUID v4 or secure random).
- RLS: owners manage their share rows; recipients do not list others’ tokens.
- Private share grants **read** only via resolve path, not update/delete.
- Public links must re-check `is_public` at open time (unpublishing invalidates `/p/...`).

## Acceptance criteria

- [x] Owner shares a private recipe → WhatsApp receives HTTPS link; recipe remains non-public. *(code)*
- [x] Logged-in recipient opens valid private link → sees detail and can fork. *(code; device QA pending)*
- [x] Logged-out recipient opens link → login → then detail. *(code; device QA pending)*
- [x] Private link older than 30 days → clear expired message; owner can generate a new link on next share. *(code)*
- [x] Second share within 30 days reuses the same private URL. *(code)*
- [x] Public recipe (own or Explore) share opens `/p/<id>` for any logged-in user; fork works if not owned. *(code)*
- [x] Unpublish public recipe → `/p/<id>` fails gracefully. *(code; relies on existing public RLS)*
- [x] Deleted recipe → share resolve fails gracefully. *(code)*
- [x] App Links / Universal Links files published on Firebase host. *(device verification pending in closed testing)*

## What you must do manually (human)

Agent can write code, migrations, hosting site files, and app config. These steps need your accounts / Apple / Google / Firebase console:

### 1. Firebase Hosting (first time)

1. In [Firebase Console](https://console.firebase.google.com/) → project `mealplanner-a818e` → **Build → Hosting** → Get started (if not enabled).
2. Locally (once): `firebase login`, then from the hosting site folder: `firebase init hosting` targeting that project (or use an existing `firebase.json` hosting block).
3. Deploy when the landing is ready: `firebase deploy --only hosting`.
4. Note the live URL (`https://mealplanner-a818e.web.app` or the assigned `*.web.app` / `*.firebaseapp.com`) and keep it as the share base URL in app config.

### 2. Android App Links — signing certificate

1. Get the **SHA-256** of the keystore that signs the builds users install:
   - Debug (dev): `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey` (password `android`).
   - Release / Codemagic: from Play Console → App integrity / App signing, or from your CI keystore.
2. Put that fingerprint into `/.well-known/assetlinks.json` (`package_name`: `com.japegomez.meal_planner`).
3. Redeploy Hosting after any fingerprint change.
4. Optional verify: [Google Digital Asset Links API](https://developers.google.com/digital-asset-links/tools/generator).

### 3. iOS Universal Links — Apple Team ID + Associated Domains

1. Apple Developer → Membership → copy **Team ID**.
2. Provide Team ID for `apple-app-site-association` (`appID` = `TEAMID.com.japegomez.mealPlanner`).
3. In Xcode (or Apple Developer → Identifiers → App ID): enable **Associated Domains**.
4. Add capability / entitlement: `applinks:mealplanner-a818e.web.app` (and later custom domain if any).
5. Redeploy Hosting after AASA changes. AASA must be served with no redirects and correct content-type.

### 4. Store listings (when not installed)

1. Confirm Play Store URL and App Store URL (or TestFlight) for the landing “Install / Open” buttons.
2. Until published, landing can show a simple “Install Recetea” placeholder.

### 5. Supabase migration

1. Apply the new migration on the remote project when ready (`supabase db push` / dashboard), after review.
2. Smoke-test RPCs with a real logged-in user.

### 6. Manual QA

1. Share private + public recipes to WhatsApp on a real device.
2. Open link with app installed (logged in / logged out).
3. Open link with app not installed → landing.
4. Confirm expired private link after forcing `expires_at` in DB (or wait / SQL update in staging).

**Not required for MVP:** buying a custom domain. Attach one later in Firebase Hosting → Custom domain.

## Out of scope follow-ups

- Custom domain (`share.recetea.app` or similar).
- Explicit revoke / regenerate before expiry.
- WhatsApp link preview with recipe image (Open Graph).
- Share analytics dashboard.
