# Design System Document

## 1. Overview & Creative North Star: "The Architectural Command"

This design system is built to transform complex fleet management data into a high-end, authoritative editorial experience. We reject the "generic SaaS" look of cluttered tables and heavy borders. Instead, we embrace **Architectural Command**: a philosophy where space, tonal layering, and sophisticated typography create a sense of calm, professional control.

The system breaks the standard grid through **Intentional Asymmetry**. Dashboards should not feel like a rigid spreadsheet; they should feel like a premium financial journal. We use deep navy foundations and high-contrast accents to ensure that "Utility" never feels "Basic." By utilizing depth and subtle glassmorphism, we provide the user with a mental map of their fleet that feels physical, reliable, and premium.

---

## 2. Colors & Surface Philosophy

Our palette is anchored in deep, authoritative blues (`primary: #00236f`) and elevated by functional, vibrant triggers.

### The "No-Line" Rule
**Prohibit 1px solid borders for sectioning.**
Structural boundaries must be defined solely through background color shifts or tonal transitions. Use `surface-container-low` for large section backgrounds and `surface-container-lowest` for the primary work area to create natural separation without visual noise.

### Surface Hierarchy & Nesting
Treat the UI as a series of nested physical layers:
* **Base Layer:** `surface` (#f8f9ff) - The canvas.
* **Sectioning:** `surface-container-low` (#eff4ff) - Large logical groups.
* **Primary Interaction:** `surface-container-lowest` (#ffffff) - Cards and data entries.
* **Elevated Details:** `surface-container-high` (#dce9ff) - Tooltips or fly-out menus.

### The "Glass & Gradient" Rule
To avoid a flat, "out-of-the-box" appearance:
* **Glassmorphism:** For floating overlays (e.g., a "Vehicle Status" hover card), use `surface_variant` at 70% opacity with a `backdrop-blur: 12px`.
* **Signature Textures:** Main Action CTAs should use a subtle linear gradient from `primary` (#00236f) to `primary_container` (#1e3a8a) at 135 degrees. This adds "soul" and depth to the most important touchpoints.

---

## 3. Typography: Editorial Authority

We use a dual-typeface system to balance high-end aesthetics with extreme data legibility.

* **Display & Headlines (Manrope):** Our "Voice." Manrope’s geometric yet warm proportions provide a modern, architectural feel. Use `display-md` for high-level fleet KPIs to make numbers feel monumental.
* **Body & Labels (Inter):** Our "Engine." Inter is used for all functional data. Its tall x-height ensures that complex vin numbers or GPS coordinates remain legible at `body-sm` sizes.
* **The Hierarchy Rule:** Always pair a `headline-sm` (Manrope) with a `label-md` (Inter) in all-caps for metadata. This contrast between "The Title" and "The Detail" mimics premium editorial layouts.

---

## 4. Elevation & Depth: Tonal Layering

Traditional drop shadows are a fallback; **Tonal Layering** is the standard.

* **The Layering Principle:** Achieve depth by stacking tiers. Place a `surface-container-lowest` card on a `surface-container-low` background. The contrast in brightness provides a "soft lift" that is easier on the eyes than a shadow.
* **Ambient Shadows:** If a floating element (like a modal) is required, use a shadow with a blur of `32px`, an offset of `y: 8px`, and an opacity of `6%`. Use the `on-surface` color (#0b1c30) for the shadow tint—never pure black.
* **The "Ghost Border" Fallback:** If a border is essential for accessibility, use `outline-variant` (#c5c5d3) at **15% opacity**. High-contrast, 100% opaque borders are strictly forbidden.

---

## 5. Components

### Buttons
* **Primary:** Gradient of `primary` to `primary_container`. Border radius: `md` (0.375rem). Use `on-primary` for text.
* **Secondary:** `secondary_container` background with `on-secondary-container` text. No border.
* **Tertiary/Alert:** For financial positives, use a custom green (derived from the "finance" request). For alerts, use `tertiary` (#4b1c00) or `error` (#ba1a1a).

### Input Fields
* **Styling:** Background of `surface_container_low`. No border on rest. On focus, a 2px "Ghost Border" of `primary` at 40% opacity.
* **Labels:** Always use `label-md` in `on-surface-variant`.

### Cards & Lists (Fleet Data)
* **Constraint:** **Strictly forbid divider lines.**
* **Separation:** Use a vertical spacing of `spacing.4` (1rem) or a subtle background toggle (zebra striping) using `surface` and `surface_container_low`.
* **Fleet Status Chips:** Use `full` (9999px) roundedness. Use `tertiary_fixed` for warning states (Laranja/Orange) and `primary_fixed` for active states.

### Management-Specific Components
* **The "Status Bar":** A thin, top-aligned gradient bar on cards using `tertiary` (alert) or `primary` (active) to show vehicle health at a glance without cluttering the card face.
* **Metric Blocks:** Large `display-sm` numbers paired with `label-sm` descriptors, utilizing `spacing.2` for tight, professional grouping.

---

## 6. Do's and Don'ts

### Do
* **Use White Space as a Tool:** Use `spacing.8` (2rem) between major dashboard modules to allow the user's eyes to rest.
* **Intentional Asymmetry:** Align primary KPIs to the left and secondary utility actions to the far right with significant "void" space between them.
* **Color as Information:** Use `tertiary` (#4b1c00) strictly for actionable alerts (e.g., "Brake Pad Wear").

### Don't
* **Don't use "Default" Shadows:** Avoid the standard CSS `0 2px 4px rgba(0,0,0,0.5)`. It feels cheap. Use the Ambient Shadow rules.
* **Don't Box Everything:** Avoid wrapping every piece of data in a bordered container. Let the typography and `surface` shifts do the heavy lifting.
* **Don't Use Pure Black:** All "dark" elements must be `on-background` (#0b1c30), maintaining the sophisticated navy undertone of the system.
