# Leftovers option at free-text level in recipe picker

**Date:** 2026-07-21  
**Status:** Approved for implementation  
**Scope:** Planner recipe picker UX for leftovers

## Problem

“Son sobras” lives inside the servings dialog after choosing a recipe. Users want it as a first-class action next to “Añadir texto libre”, then pick a recipe without choosing servings.

## Decisions

| Topic | Choice |
| --- | --- |
| Placement | Same level as free-text row in `RecipePickerSheet` |
| Servings for leftovers | Use recipe default `servings` (stored on slot; not synced to shopping) |
| Servings dialog | Remove leftover checkbox; leftovers only via new option |
| Flow | Tap “Son sobras” → list without servings subtitle → tap recipe → add slot `isLeftover: true` |

## Behavior

1. Picker shows two header actions: free text + leftovers (subtitle = shopping hint).
2. Activating leftovers enters leftover mode (row highlighted); recipe tiles omit `servingsCount`.
3. Selecting a recipe in leftover mode adds the slot and closes the sheet (no servings dialog).
4. Normal recipe tap still opens servings dialog (servings only).
5. Free-text flow unchanged.

## Non-goals

- Changing shopping sync rules for leftovers (already skipped).
- Changing leftover chip rendering on planner slots.
