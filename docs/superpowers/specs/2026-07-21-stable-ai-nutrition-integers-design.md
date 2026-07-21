# Stable AI nutrition + integer-only values

**Date:** 2026-07-21  
**Status:** Approved for planning  
**Scope:** Recipe assistant nutrition generation + nutrition form input

## Problem

After creating a recipe, if the user edits it and asks the assistant again to complete nutrition per serving, the AI recalculates from scratch and often changes existing values. Nutrition fields also allow decimals; the product requirement is whole numbers only.

## Goals

1. When requesting nutrition from the assistant, **attach existing nutrition values** if any are present.
2. Instruct the model: if those values are **coherent** with the recipe (title, servings, ingredients), **return them unchanged**; only adjust when there is a clear error or missing fields.
3. **Disallow decimal nutrition values** end-to-end for assistant output and manual form entry (integers ≥ 0).

## Non-goals

- Skipping the AI call entirely when nutrition is already complete.
- Migrating the DB column types (numeric storage may remain; app treats values as integers).
- Changing UI copy beyond what is needed for input constraints.

## Decisions

| Topic | Decision |
| --- | --- |
| Preserve behavior | Option A — send existing values; keep if coherent; fix only if clearly wrong / empty |
| Implementation shape | Prompt + request payload + client rounding / integer UI |
| Integers | Apply to `generate_nutrition`, nutrition embedded in `generate_recipe`, mapper, and form fields |

## Behavior

### `generate_nutrition` request

Client sends (in addition to title, servings, ingredients):

```json
"existingNutrition": {
  "calories": 320,
  "protein": 12,
  "carbohydrates": 40,
  "fat": 8,
  "fiber": 3
}
```

- Omit the object (or send only non-null fields) when nothing is filled yet.
- Values sent as integers (round before send if needed).

### Edge Function

- Accept optional `existingNutrition` on `generate_nutrition`.
- Include it in the user prompt when present (clearly labeled as current per-serving values).
- Extend `NUTRITION_SYSTEM_PROMPT` (and recipe-mode nutrition rule) so that:
  - If existing values are reasonable for the recipe, return them **unchanged**.
  - Fill null/missing fields.
  - Change existing numbers only when they are clearly inconsistent with ingredients/servings.
- Change nutrition JSON schema fields from `number` to `integer` (minimum 0, still nullable where already allowed).
- Validate integers in schema validation / post-parse if applicable.

### Client mapping & save

- `nutritionFromAssistantJson`: parse and **round** to `int` (non-negative); reject/coerce decimals.
- Form nutrition fields: `TextInputType.number` without decimals; digit-only (or equivalent) input formatters; store as `int?`.
- Both call sites (recipe form + recipe detail “complete nutrition”) pass current nutrition into `generateNutrition`.

## Acceptance criteria

- [ ] Re-running “complete nutrition with AI” on a recipe that already has coherent nutrition returns the same integer values (barring intentional clear-error corrections).
- [ ] Existing values are present in the Edge Function user prompt / request body when the form or detail has them.
- [ ] Assistant nutrition responses are integers (schema + mapper).
- [ ] Manual nutrition fields cannot enter decimals.
- [ ] New recipes created via `generate_recipe` also get integer nutrition.

## Out of scope follow-ups

- Deterministic server-side merge that always overwrites LLM output with prior values.
- Soft warning when AI proposes a large change vs existing values.
