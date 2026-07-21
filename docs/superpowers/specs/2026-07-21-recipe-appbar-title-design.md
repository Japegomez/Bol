# Recipe AppBar title — margin, scrim, and collapse overflow

**Date:** 2026-07-21  
**Status:** Approved for planning  
**Scope:** Recipe detail screens (own + public)

## Problem

On the recipe detail screen, the title sits in a `FlexibleSpaceBar` over the user-configured recipe photo:

1. The expanded title has almost no horizontal margin.
2. Black text on a busy photo is hard to read (no contrast layer).
3. When the user scrolls, the title collapses into the pinned AppBar. Long titles overlap the leading (back) and trailing (edit / delete / save) action buttons.

The same `FlexibleSpaceBar` pattern exists on the public recipe detail screen and has the same issues.

## Goals

- Add horizontal margin around the title over the hero image.
- Add a semi-transparent dark scrim behind the title for contrast against any photo.
- When collapsed, keep the title from overlapping AppBar actions: single line + ellipsis.
- Apply the same treatment to own and public recipe detail screens.

## Non-goals

- Changing recipe data, photo upload, or navigation.
- Redesigning the rest of the detail layout (cook button, tags, ingredients).
- Multi-line collapsed titles or dynamic font scaling.

## Design decisions

| Topic | Decision |
| --- | --- |
| Contrast | Option A — dark semi-transparent scrim behind the title (expanded and collapsed) |
| Long titles (collapsed) | Option A — truncate with ellipsis (`maxLines: 1`) |
| Scope | Own recipe detail **and** public recipe detail |
| Structure | Reusable widget (e.g. `RecipeAppBarTitle`) used by both screens |

## Behavior

### Expanded (hero photo visible)

- Title rendered with horizontal padding (~16–20 logical pixels).
- Dark scrim behind the text (approx. black at 45–55% opacity), sized to the text block (not a full-width bar unless needed for padding).
- Title may wrap to more than one line while expanded if the `FlexibleSpaceBar` layout allows it; prefer readable size matching current typography.

### Collapsed (pinned AppBar)

- Same scrim treatment for consistency.
- `maxLines: 1`, `TextOverflow.ellipsis`.
- Horizontal insets must leave room for leading and trailing actions so the title never paints under the icons.

## Implementation outline

1. Add a small reusable widget (suggested path: `meal_planner/lib/features/recipes/presentation/widgets/recipe_app_bar_title.dart`) that wraps the title `Text` with padding + scrim decoration and ellipsis rules for the collapsed case.
2. Wire it into:
   - `meal_planner/lib/features/recipes/presentation/recipe_detail_screen.dart` (`FlexibleSpaceBar.title`)
   - `meal_planner/lib/features/social/presentation/public_screens.dart` (`FlexibleSpaceBar.title` on public detail)
3. Use `FlexibleSpaceBar.titlePadding` (and/or widget padding) so collapsed layout respects leading/trailing icon slots.
4. No business-logic or provider changes.

## Acceptance criteria

- [ ] Own recipe detail: title has visible horizontal margin over the photo.
- [ ] Own recipe detail: title remains readable over light and dark photos thanks to the scrim.
- [ ] Own recipe detail: scrolling collapses the title into the AppBar without overlapping back / edit / delete.
- [ ] Long titles show ellipsis when collapsed.
- [ ] Public recipe detail shows the same margin, scrim, and collapse behavior (including save action when present).
- [ ] No regressions to cook / publish / fork flows.

## Out of scope follow-ups

- Shared `SliverAppBar` builder for both screens (only extract the title widget for now).
- Themed scrim color tokens if a broader design system pass happens later.
