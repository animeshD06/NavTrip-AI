---
name: Analog Journal
colors:
  surface: '#f9f9f8'
  surface-dim: '#dadad9'
  surface-bright: '#f9f9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f4f4f3'
  surface-container: '#eeeeed'
  surface-container-high: '#e8e8e7'
  surface-container-highest: '#e2e2e2'
  on-surface: '#1a1c1c'
  on-surface-variant: '#57423c'
  inverse-surface: '#2f3130'
  inverse-on-surface: '#f1f1f0'
  outline: '#8b716a'
  outline-variant: '#dec0b7'
  surface-tint: '#a53c19'
  primary: '#781f00'
  on-primary: '#ffffff'
  primary-container: '#9a3412'
  on-primary-container: '#ffbda9'
  inverse-primary: '#ffb59f'
  secondary: '#625e59'
  on-secondary: '#ffffff'
  secondary-container: '#e9e1db'
  on-secondary-container: '#68635f'
  tertiary: '#3f3f3e'
  on-tertiary: '#ffffff'
  tertiary-container: '#565656'
  on-tertiary-container: '#cdcbca'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdbd1'
  primary-fixed-dim: '#ffb59f'
  on-primary-fixed: '#3a0a00'
  on-primary-fixed-variant: '#842503'
  secondary-fixed: '#e9e1db'
  secondary-fixed-dim: '#ccc5c0'
  on-secondary-fixed: '#1e1b18'
  on-secondary-fixed-variant: '#4a4642'
  tertiary-fixed: '#e4e2e1'
  tertiary-fixed-dim: '#c8c6c5'
  on-tertiary-fixed: '#1b1c1b'
  on-tertiary-fixed-variant: '#474746'
  background: '#f9f9f8'
  on-background: '#1a1c1c'
  surface-variant: '#e2e2e2'
typography:
  display-lg:
    fontFamily: Instrument Serif
    fontSize: 48px
    fontWeight: '400'
    lineHeight: 52px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Instrument Serif
    fontSize: 36px
    fontWeight: '400'
    lineHeight: 40px
  headline-md:
    fontFamily: Instrument Serif
    fontSize: 32px
    fontWeight: '400'
    lineHeight: 36px
  headline-sm:
    fontFamily: Instrument Serif
    fontSize: 24px
    fontWeight: '400'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  caption:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  unit: 4px
  gutter: 24px
  margin-mobile: 20px
  margin-desktop: 64px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

This design system is built for a travel itinerary experience that feels like a physical heirloom. It moves away from the sterile, plastic feel of modern utility apps toward a **Tactile / Skeuomorphic** aesthetic inspired by traditional scrapbooking, travel journals, and architectural sketches. 

The target audience is the thoughtful traveler who values the process of planning as much as the journey itself. The UI should evoke a sense of permanence, warmth, and curated chaos. Key visual identifiers include:
- **Organic Imperfection:** Elements like "taped" photos or "hand-written" notes are slightly rotated (between -2° and 2°) to break the digital grid.
- **Materiality:** High use of paper grain textures, subtle ring-binder shadows, and ink-bleed effects on typography.
- **Split-Screen Storytelling:** Large-scale photography is paired directly with utilitarian data, creating a balance between inspiration and organization.

## Colors

The palette is rooted in natural, earth-bound pigments and physical mediums.

- **Surface (#f5f5f4):** A warm stone paper that serves as the foundation. It should never be pure white.
- **Primary (#9a3412):** A rich terracotta, used for "stamped" accents, key CTAs, and active timeline markers. It mimics red clay or traditional wax seals.
- **On-Surface (#1c1917):** A warm near-black, representing carbon ink. Avoid pure blacks to maintain the organic feel.
- **Secondary (#44403c):** A muted stone-grey for secondary metadata and icons, providing enough contrast without competing with the primary terracotta.

## Typography

The typography strategy relies on the high contrast between the editorial elegance of **Instrument Serif** and the functional clarity of **Inter**.

- **Headlines:** Always set in Instrument Serif. Large display titles should use a slight negative letter spacing to mimic tight editorial typesetting. 
- **Body:** Inter provides a neutral, highly legible counterpoint to the more decorative headlines. 
- **Labels:** Use Inter in Bold/Semi-bold with increased letter spacing and uppercase styling to create "tab" or "index" effects.
- **Styling:** For a journal-like feel, use italics for captions and secondary notes to simulate a shift in handwriting.

## Layout & Spacing

This design system uses a **Fluid Grid** for content but maintains strict "paper edges" through generous margins.

- **The Split-Screen:** On desktop, use a 50/50 split where the left side is a "fixed" high-impact image or map, and the right side is a scrollable journal entry. 
- **The Vertical Spine:** Timelines are anchored by a 2px vertical "spine" (Terracotta) with ringed dots. This spine acts as a visual guide for the user’s eye.
- **Breakpoints:**
  - **Mobile (< 600px):** Single column, margins reduced to 20px. Photos appear as full-bleed or "taped-in" polaroids.
  - **Tablet (600px - 1024px):** 12-column fluid grid.
  - **Desktop (> 1024px):** Split-view logic or a centered 12-column grid with a max-width of 1280px.

## Elevation & Depth

Depth is created through physical metaphors rather than digital light sources.

- **Ring Shadows:** Use a specific shadow profile for "raised" items (like polaroids or sticky notes) that is slightly offset to the bottom right, with a soft, multi-layered blur to simulate thick paper.
- **Tonal Layering:** The primary surface is the "Desk" (slightly darker stone). The active content sits on "Paper" (Primary Surface color).
- **Z-Index Play:** Elements should overlap. A photo might slightly obscure the corner of a text block, and the "Timeline Spine" should feel like it is punched through the paper.

## Shapes

The shape language is a mix of geometric precision for buttons and "torn" or organic edges for containers.

- **Pill Shapes:** All buttons and interactive chips use the maximum roundedness (Pill-shaped) to provide a soft, friendly touchpoint that contrasts with the sharp-edged "paper" cards.
- **Card Elements:** Most cards maintain a standard 0.5rem radius, but for "Polaroid" or "Sticky Note" styles, the corners should remain crisp or only slightly softened.
- **Rotations:** Apply `rotate(1deg)` or `rotate(-1.5deg)` to image containers and sticky-note components to evoke a hand-placed feel.

## Components

### Buttons
- **Primary:** Terracotta (#9a3412) background, Pill-shaped, On-Primary (White/Stone) text.
- **Secondary:** Outlined with a 1.5px stroke in near-black, Pill-shaped.

### The Polaroid Card
A container with a white border (4px-8px) and a bottom-heavy margin for "captions." Always includes a subtle `drop-shadow` and a 1-degree rotation.

### Timeline Spine
A vertical line in Terracotta. Points on the timeline are circles with a Terracotta border and a Surface-colored center (ring-binder effect).

### Input Fields
Underlined only (no full border) to mimic a ruled notebook. The underline should be a subtle stone-grey, turning Terracotta on focus.

### Sticky Notes
Square components using a pale yellow or light terracotta tint, with a "peel" shadow in the bottom corner and hand-written style italics.

### List Items
Separated by a thin, dotted horizontal line (mimicking perforated paper).