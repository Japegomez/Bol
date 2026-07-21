# Leftovers option at free-text level in recipe picker

**Date:** 2026-07-21  
**Status:** Implemented (on `develop`)  
**Scope:** Planner recipe picker UX for leftovers

## Problem

“Son sobras” lived inside the servings dialog after choosing a recipe. Users want it as a first-class action next to “Añadir texto libre”, then pick a recipe without choosing servings.

## Decisions

| Topic | Choice |
| --- | --- |
| Placement | Same level as free-text row in `RecipePickerSheet` |
| Servings for leftovers | Use recipe default `servings` (stored on slot; not synced to shopping) |
| Servings dialog | Remove leftover checkbox; leftovers only via new option |
| Flow | Tap “Son sobras” → list without servings subtitle → tap recipe → add slot `isLeftover: true` |
| Sheet dismiss | Close picker **before** awaiting `addSlot` (also for normal servings + free text) |

## Behavior

1. Picker shows two header actions: free text + leftovers (subtitle = shopping hint).
2. Activating leftovers enters leftover mode (row highlighted); recipe tiles omit `servingsCount`.
3. Selecting a recipe in leftover mode closes the sheet immediately and adds the slot (no servings dialog).
4. Normal recipe tap opens servings dialog (servings only); on confirm, sheet closes immediately then saves.
5. Free-text flow: after dialog confirm, sheet closes immediately then saves.

## Non-goals

- Changing shopping sync rules for leftovers (already skipped).
- Changing leftover chip rendering on planner slots.

## Related docs

- `REQUIREMENTS.md` — RF-PLAN-10 / RF-PLAN-11  
- `TASKS.md` — F7 gestión de slots  
