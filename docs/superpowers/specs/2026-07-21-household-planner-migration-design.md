# Household planner/shopping migration (additive)

**Date:** 2026-07-21  
**Status:** Approved for implementation  
**Scope:** Create / join / leave household; planner + shopping; cross-member recipe read + fork

## Problem

Switching from individual to household mode re-scopes the UI to empty household planner/shopping without migrating solo data. Users perceive data loss. Multiple joiners with different plans need an additive merge. Leaving should bring a household snapshot back to individual mode. Members must open recipes planned by others that are not in their recipe book.

## Goals

1. On **create** and **join**: merge the user’s individual planner (current week + future weeks) into the household planner **additively** (multiple items per meal already supported).
2. **Recalculate** household shopping list from the resulting plan (do not migrate orphan manual shopping rows).
3. On **leave**: **snapshot** household planner (current + future weeks) onto the user’s individual planner (replace those weeks), then recalculate individual shopping from that plan.
4. On leave, slots whose recipes the user cannot keep as `recipe_id` become **free-text** notes with the title.
5. From the household planner chip: open recipe **read-only**; explicit **“Add to my recipe book”** (fork). Allow household members to **read** recipes owned by other members (RLS).

## Non-goals

- Shared household recipe book (all recipes always listed for everyone).
- Migrating past weeks.
- Migrating shopping items that are not derived from plan slots.
- Asking the user conflict-by-conflict for overlapping meals.

## Decisions

| Topic | Choice |
| --- | --- |
| Create/join | Additive merge of plan slots |
| Weeks | Current week + future weeks only |
| Shopping | Recalculate from merged/snapshot plan |
| Leave | Snapshot household → individual (replace those weeks) |
| Foreign recipes on leave | Convert to free-text with title |
| Access to others’ recipes | Read from planner; explicit fork to own book |
| Implementation | Atomic Supabase RPCs |

## Behavior details

### Create household
1. Create household + admin membership (existing).
2. For each individual `weekly_plans` with `week_start >= current_week_monday`: ensure household plan for that week; copy all `plan_slots` into it (new IDs, same day/meal/position/recipe/servings/leftover/notes).
3. Rebuild household shopping from all plan slots on household plans (current+future) via existing ingredient rules (`is_included`, not `is_to_taste`, skip leftovers).

### Join household
Same merge into the **existing** household plans, then rebuild household shopping.

### Leave household
1. For each household plan week `week_start >= current_week_monday`: upsert individual plan for that week; **replace** slots (delete existing individual slots for that week, insert copies from household).
2. If `recipe_id` is not owned by the leaving user (and not otherwise keepable), set `recipe_id` null and put recipe title into `notes` (free-text).
3. Rebuild individual shopping from the new individual plan slots.
4. Remove membership (existing leave logic).

### Recipe access
- RLS: household members can `SELECT` recipes where `user_id` is another member of the same household.
- UI: opening a non-owned recipe from planner shows read-only detail + “Add to my recipe book” (existing fork/save flow if present, or equivalent copy).

## Acceptance criteria

- [ ] Create household with a dinner planned tonight → dinner appears on household planner; shopping reflects it.
- [ ] Second user joins with their own lunch same day → both lunch items appear; shopping recalculated.
- [ ] Leave household → individual planner matches household snapshot for current/future weeks; foreign recipes become notes; shopping recalculated.
- [ ] Member can open another member’s planned recipe read-only and fork it into their book.
- [ ] Past individual weeks remain untouched in DB while in household mode.

## Out of scope follow-ups

- Soft warning UI before create/join explaining merge.
- Deduplicating identical recipe+servings slots on merge.
