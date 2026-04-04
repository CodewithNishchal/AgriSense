# Design System: Editorial Agronomy

**Creative north star:** *The Digital Greenhouse* — intentional layering and asymmetric depth; glassmorphism over earthy backgrounds; premium editorial typography so data reads as insight, not chore.

**Canonical reference:** All Flutter UI work in [`frontend/`](frontend/) should align with this document. Token names below map to implementation in [`frontend/lib/core/theme/`](frontend/lib/core/theme/) (e.g. `app_theme.dart`, color extensions).

---

## 1. Overview

Agriculture is organic; smart farming is precision. This system avoids clinical “dashboard” templates in favor of a high-end editorial experience: **breathing room** (spacing scale), **high-contrast type**, and **no cheap section borders**—separation through tone, space, and material depth.

---

## 2. Colors & Surface Philosophy

Palette: deep, obsidian-like greens and vibrant biological chartreuse.

### The “No-Line” Rule

- **Do not** use 1px solid borders to section content.
- **Separation via tone:** `surface_container_low` vs `background`.
- **Separation via space:** spacing tokens **16 (4rem)** or **12 (3rem)** for mental grouping.

### Surface Hierarchy (stack materials)

| Layer | Role |
|-------|------|
| **Base** | `background` — `#121410` |
| **Sectioning** | `surface_container_low` — large grouped areas |
| **Cards** | `surface_container` / `surface_container_high` — interactive units |

### Glass & Gradient

- **Glassmorphism:** floating nav / quick actions — `surface_variant` at **60% opacity** + **20px** backdrop blur.
- **Primary CTA gradient:** not flat — from `primary` `#88dc63` to `primary_container` `#6ebf4a` at **135°** for a lush, living texture.

### Key tokens (reference)

- `background`: `#121410`
- `primary`: `#88dc63`
- `primary_container`: `#6ebf4a`
- `on_surface`: `#e3e3dc` (no pure white body text)
- `outline_variant`: `#40493c` (ghost border base)

---

## 3. Typography

**Dual font strategy**

| Role | Font | Usage |
|------|------|--------|
| Display & headlines | **Manrope** | Editorial voice — `display-lg` hero stats, `headline-md` sections, `headline-sm` card titles |
| Labels & micro-copy | **Inter** | `label-md` sensors/buttons, `label-sm` paired with display stats |

**Hierarchy**

- `headline-sm` for card titles — authoritative, bold.
- Pair **`display-md`** (Manrope) with **`label-sm`** (Inter) for insight units (e.g. **24°C** + “Temperature”).

**Contrast:** `on_surface` on surfaces — clarity without harsh white.

---

## 4. Elevation & Depth

Depth via light and material, not arbitrary lines.

- **Tonal layering / reverse nesting:** place `surface_container_highest` inside `surface_container_low` for soft indentation (no heavy shadow).
- **Ambient float shadow (modals, hovered cards):** blur **32px**, offset **y: 8**, color **`on_background` @ 6%** opacity — not 100% black.
- **Ghost border (accessibility only):** `outline_variant` **#40493c** at **20%** opacity — suggestion, not a wall.
- **Radii:** **`xl` (1.5rem)** for main containers/cards — organic softness. **`full` (9999px)** for primary buttons and status chips only.

---

## 5. Components

### Buttons

- **Primary:** gradient `primary` → `primary_container`, text `on_primary_fixed`, shape **`full`**.
- **Secondary:** `surface_container_highest` + `on_surface` text — **no border**.

### Smart farming cards

- **No divider lines.**
- `surface_container`, **`xl`** rounding, internal padding **`6` (1.5rem)**.
- Group data with **background shifts**, not lines.

### Chips (crop/field filters)

- **Unselected:** `surface_container_highest`
- **Selected:** `primary` background, `on_primary` text

### Form fields

- Background: `surface_container_lowest`
- Focus: ghost border **`primary` @ 40%** opacity
- Error: `error` text + background shift to **`error_container` @ 10%** opacity

### Insight unit (data visualization)

- **`display-sm`** value above **`label-md`** category.
- On **glassmorphism** when overlaid on field imagery.

---

## 6. Spacing & Layout

- **Editorial** top-level section margins: token **`24` (6rem)** where specified.
- **Asymmetry:** encouraged (e.g. large sensor left, small trend stack right).
- **Navigation:** glassmorphism so **lush green imagery** can show through.

### List separation

- **Don’t** use divider lines between list items.
- Use **`2` (0.5rem)** vertical gap + subtle background change.

---

## 7. Do’s & Don’ts

### Do

- Use asymmetrical layouts.
- Use glassmorphism on nav bars for imagery bleed.
- Use **`24 (6rem)`** for top-level section margins.

### Don’t

- Use 100% opaque black shadows.
- Use divider lines for list separation.
- Use **pure white** for body text — use **`on_surface`** (`#e3e3dc`).

---

## 8. Flutter implementation notes (non-normative)

Map tokens to `ThemeData`, `ColorScheme`, `TextTheme`, and `BoxDecoration`:

- Load **Manrope** and **Inter** via `google_fonts` (already in [`frontend/pubspec.yaml`](frontend/pubspec.yaml)).
- Gradients: `LinearGradient` with `begin`/`end` aligned to **135°**.
- Glass: `BackdropFilter` + `ImageFilter.blur` (~20 logical px) + semi-transparent fill.
- Replace hard borders with `SizedBox` spacing + `Color` layering per hierarchy table.

---

## 9. Related documents

- [frontendplan.md](frontendplan.md) — screens and Flutter scope
- [integrationplan.md](integrationplan.md) — API alignment
