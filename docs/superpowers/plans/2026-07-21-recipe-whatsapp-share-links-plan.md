# Implementation plan: Recipe WhatsApp share links

**Date:** 2026-07-21  
**Spec:** `docs/superpowers/specs/2026-07-21-recipe-whatsapp-share-links-design.md`  
**Base URL (initial):** `https://mealplanner-a818e.web.app` (confirm after first Hosting deploy)

## Split of work

| Who | Work |
| --- | --- |
| **You (manual)** | Enable Firebase Hosting; provide Apple Team ID + Android SHA-256; enable Associated Domains in Apple/Xcode; deploy hosting when asked; apply Supabase migration to remote; device QA on WhatsApp |
| **Agent (code)** | Migration + RPCs/RLS; Flutter share UI + deep link routes; Firebase Hosting site + well-known files (once IDs provided); Android intent-filters; iOS entitlements template |

---

## Phase 0 — Manual prerequisites (you)

Do before or in parallel with Phase 1:

1. [ ] Firebase Console → enable **Hosting** on `mealplanner-a818e`
2. [ ] `firebase login` on your machine
3. [ ] Send agent:
   - Apple **Team ID**
   - Android **SHA-256** (debug and/or release as needed)
   - App Store / Play Store URLs if known (else placeholders)
4. [ ] Apple Developer: enable **Associated Domains** on App ID `com.japegomez.mealPlanner`

---

## Phase 1 — Supabase

1. Migration `025_recipe_share_links.sql` (or next number):
   - Table `recipe_share_links` as in spec
   - RLS: owner insert/select own rows
   - RPC `get_or_create_recipe_share_link(recipe_id)` → reuse active or create (30 days)
   - RPC `resolve_recipe_share(token)` → auth required; return recipe id/payload or error codes (expired/invalid/deleted)
2. Ensure resolve path grants **read-only** access for non-owners (SECURITY DEFINER carefully scoped, or temporary grant pattern).
3. Apply locally; you apply remotely after review.

## Phase 2 — Flutter app

1. Config: `shareBaseUrl` (Firebase Hosting URL).
2. Repository methods: get/create private link; resolve token; share helpers for public `/p/:id`.
3. UI: Share on owned private detail; Share on public detail (Explore + own public).
4. `share_plus` with title + URL (mirror shopping list pattern).
5. Deep link handling (`app_links`): map `/r/:token` and `/p/:id` → go_router.
6. Auth gate: if logged out, stash pending link → after login navigate to detail.
7. Detail: read-only + fork for non-owned; error UI for expired/invalid/unpublished.
8. l10n strings (es/en + other arb locales in repo).

## Phase 3 — Firebase Hosting site

1. Add `hosting/` (or `meal_planner/hosting/`) with:
   - Landing pages for `/r/**` and `/p/**` (open app / store CTA)
   - `/.well-known/assetlinks.json` (package `com.japegomez.meal_planner` + SHA-256)
   - `/.well-known/apple-app-site-association` (TeamID + `com.japegomez.mealPlanner`)
2. `firebase.json` hosting rewrites so paths serve the landing and well-known files correctly (AASA: no extension, no unexpected redirect).
3. You run: `firebase deploy --only hosting`.

## Phase 4 — Native OS association

1. Android: intent-filter `https` host = Firebase host, paths `/r/*`, `/p/*`, `autoVerify=true`.
2. iOS: Associated Domains entitlement `applinks:<firebase-host>`.
3. Keep existing `recetea://` for Live Activities unchanged.

## Phase 5 — Verify

1. Agent: unit/widget tests where practical (link reuse, URL builders, route parsing).
2. You: real-device WhatsApp matrix from acceptance criteria in the spec.

## Suggested order

`Phase 0 (you start)` → Phase 1 → Phase 2 → Phase 3 (fill well-known with your IDs) → you deploy Hosting → Phase 4 → Phase 5.

## Blocked on you until

- Team ID + SHA-256 for correct well-known files  
- First Hosting enable + deploy  
- Remote migration apply  
