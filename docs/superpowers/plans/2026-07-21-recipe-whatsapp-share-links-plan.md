# Implementation plan: Recipe WhatsApp share links

**Date:** 2026-07-21  
**Spec:** `docs/superpowers/specs/2026-07-21-recipe-whatsapp-share-links-design.md`  
**Base URL:** `https://mealplanner-a818e.web.app` (Hosting live)  
**Status:** Implemented — device QA pending (Play closed testing / TestFlight)

## Split of work

| Who | Work |
| --- | --- |
| **You (manual)** | Enable Firebase Hosting; provide Apple Team ID + Android SHA-256; enable Associated Domains in Apple/Xcode; deploy hosting when asked; apply Supabase migration to remote; device QA on WhatsApp |
| **Agent (code)** | Migration + RPCs/RLS; Flutter share UI + deep link routes; Firebase Hosting site + well-known files (once IDs provided); Android intent-filters; iOS entitlements template |

---

## Phase 0 — Manual prerequisites (you)

1. [x] Firebase Console → enable **Hosting** on `mealplanner-a818e`
2. [x] `firebase login` + `firebase init hosting` (sin GitHub Actions)
3. [x] First deploy live: `https://mealplanner-a818e.web.app`
4. [x] Credentials for well-known files:
   - Apple Team ID: `BUT9B76X33`
   - Android Play **app signing** SHA-256: `93:93:68:AB:D8:E4:0B:54:0B:AD:E3:4F:56:F1:C4:80:D5:AD:C4:1D:4D:41:11:2F:BA:EF:DB:4E:AD:F4:30:52`
   - [ ] App Store / Play Store URLs if known (else placeholders)
   - [ ] Optional: add local **debug** SHA-256 later if App Links must also work with `flutter run` builds
5. [x] Apple Developer: enable **Associated Domains** on App ID `com.japegomez.mealPlanner`

---

## Phase 1 — Supabase — done

- [x] Migration `025_recipe_share_links.sql`
- [x] RLS read via active share link + owner manage rows
- [x] RPCs `get_or_create_recipe_share_link` / `resolve_recipe_share`
- [x] Applied on remote

## Phase 2 — Flutter app — done

- [x] `ShareUrls` + `RecipeShareRepository`
- [x] Share UI on owned detail + public Explore detail
- [x] `share_plus` + `app_links` / `DeepLinkListener` (pending link after login)
- [x] l10n (es/en/ca/gl/eu/pt)

## Phase 3 — Firebase Hosting — done

- [x] `public/index.html` landing + `/.well-known/*`
- [x] `firebase.json` (SPA rewrite; do not ignore `.well-known`)
- [x] Deployed to `mealplanner-a818e.web.app`

## Phase 4 — Native OS association — done

- [x] Android App Links intent-filters + `recetea://` VIEW filter
- [x] iOS Associated Domains in `Runner.entitlements`

## Phase 5 — Verify

1. [ ] Device QA: WhatsApp → closed-testing build → detail → fork
2. [ ] Expired private link message
3. Optional later: unit tests for URL builders / token reuse
