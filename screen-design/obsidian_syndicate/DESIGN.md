---
name: Obsidian Syndicate
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#3a3939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#201f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353534'
  on-surface: '#e5e2e1'
  on-surface-variant: '#e7bcba'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#ae8885'
  outline-variant: '#5d3f3d'
  surface-tint: '#ffb3af'
  primary: '#ffb3af'
  on-primary: '#68000e'
  primary-container: '#d90429'
  on-primary-container: '#ffeae8'
  inverse-primary: '#bf0022'
  secondary: '#c3c7cc'
  on-secondary: '#2c3135'
  secondary-container: '#43474c'
  on-secondary-container: '#b2b5bb'
  tertiary: '#80cfff'
  on-tertiary: '#00344b'
  tertiary-container: '#0074a0'
  on-tertiary-container: '#e0f1ff'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdad7'
  primary-fixed-dim: '#ffb3af'
  on-primary-fixed: '#410005'
  on-primary-fixed-variant: '#930018'
  secondary-fixed: '#dfe3e8'
  secondary-fixed-dim: '#c3c7cc'
  on-secondary-fixed: '#181c20'
  on-secondary-fixed-variant: '#43474c'
  tertiary-fixed: '#c5e7ff'
  tertiary-fixed-dim: '#80cfff'
  on-tertiary-fixed: '#001e2d'
  on-tertiary-fixed-variant: '#004c6b'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353534'
typography:
  display-lg:
    fontFamily: IBM Plex Sans
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
  display-lg-mobile:
    fontFamily: IBM Plex Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg:
    fontFamily: IBM Plex Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: IBM Plex Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 30px
  headline-sm:
    fontFamily: IBM Plex Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
  body-lg:
    fontFamily: IBM Plex Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: IBM Plex Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: IBM Plex Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: IBM Plex Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: IBM Plex Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  label-sm:
    fontFamily: IBM Plex Sans
    fontSize: 10px
    fontWeight: '500'
    lineHeight: 14px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.25rem
---

## Brand & Style

This design system delivers a high-stakes, suspense-driven social deduction experience tailored natively for modern Arabic-speaking players. The aesthetic fuses tactical film-noir minimalism with the opulent, lethal underworld of high-roller secret societies.

### Target Audience & Emotional Driver
- **Audience:** Discerning mobile gamers, social strategists, and live party groups engaging in real-time deception, voting, and private role reveals.
- **Atmosphere:** Tense, cinematic, whispered luxury, and calculated danger. Every screen must feel like an invitation to a secret high-stakes backroom.

### Visual Style
- **Cinematic Noir & Minimalist Brutalism:** Deep obsidian voids, razor-sharp structural boundaries, and subtle crimson atmospheric embers.
- **Playing-Card Motif:** Micro-embellishments and card corner indices framing secretive role cards, dossier dossiers, and voting ballots.
- **RTL-First Precision:** Right-to-left layout geometry strictly observed across all visual hierarchies, alignment anchors, gesture directions, and motion paths.

## Colors

The color system is unapologetically nocturnal and high-contrast, designed to prevent optical fatigue in low-light party conditions while elevating critical game actions through crimson urgency.

### Core Architecture
- **Obsidian Black Canvas (`#0D0D0D`):** The primary canvas ground, representing secrecy and shadows.
- **Charcoal Card & Surface Fill (`#1A1A1A` / `#161616`):** Stacked structural layers for interactive cards, role dossiers, and modal sheets.
- **Syndicate Crimson (`#D90429`):** Reserved strictly for high-stakes focal points: the "Eliminate" trigger, timers under 10 seconds, traitor confirmations, and primary CTAs.
- **Crisp Pure White (`#FFFFFF`):** High-priority text, player names, and stark card iconography.
- **Muted Slate Silver (`#8E9297`):** Metadata, timer bases, spectator statuses, and inactive tab states.

### Contrast & Application Rules
- Never use gray backgrounds behind Crimson actions. Place Crimson solely against `#0D0D0D` or `#161616`.
- Decorative playing-card pips (Spades, Diamonds) in inactive states must sit at 20% opacity using `#8E9297` to maintain stealth.
- Critical active states utilize a controlled red aura (crimson glow at 25% opacity) to denote immediate turn ownership or targeted status.

## Typography

The design system employs **IBM Plex Sans** (supporting the Arabic script with tailored contextual glyphs). Its engineering heritage and technical geometric cadence yield clean letterforms, robust counter-spaces, and optimal readability during high-velocity round-based gameplay.

### Arabic Typesetting Rules
- **Right Alignment Standard:** All body text and title hierarchies default to `text-align: right`. Center alignments are strictly reserved for standalone numeric clocks, modal decision alerts, and lone card values.
- **No Faux Italics:** Italic styles are strictly prohibited for Arabic scripts. Distinction is achieved through weight shifts (`Medium` to `Bold`) or color tinting via `#8E9297`.
- **Numbers:** Use clear Western Arabic numerals (0, 1, 2...) for instantaneous legibility during rapid timed phases, while preserving RTL layout flow.
- **Line Heights:** Generous line heights accommodate Arabic ascenders and descenders (such as *Khaf*, *Yeh*, and *Reh* accents) without visual clipping.

## Layout & Spacing

The layout model is anchored on an edge-aware 4-column fluid mobile grid, scalable to an 8-column layout for tablets in horizontal split-screen mode (e.g., party host / moderator view).

### RTL Geometry & Directionality
- **Spatial Orientation:** Visual flow runs strictly from right to left. Leading margins correspond to the physical right edge; trailing margins correspond to the physical left edge.
- **Player Grids & Turn Carousels:** Seated players populate clockwise starting from top-right. Carousels and swipe-to-reveal gesture mechanics initiate from right to left.
- **Component Padding:** Consistent 8-point spatial rhythm (`space-xs` through `space-xl`) regulates card padding, nested role tags, and bottom-sheet controls.

## Elevation & Depth

Visual hierarchy does not use diffuse multi-point drop shadows. Instead, it relies on crisp planar layering, razor-thin borders, and selective photonic illumination.

### Tonal Tiers
- **Tier 0 (Canvas):** `#0D0D0D` (Infinite void, table underlay).
- **Tier 1 (Resting Cards):** `#161616` bounded by a 1px border of `#262626`.
- **Tier 2 (Raised Elements & Dialogs):** `#1A1A1A` bounded by a 1px border of `#333333`.
- **Tier 3 (Active Role Card / Target Focus):** `#1A1A1A` framed by a 1px border of `#D90429` with a subtle static glow (`0 0 16px rgba(217, 4, 41, 0.25)`).

### Playing-Card Motifs & Depth
- Secret role cards use dual-faced layering: an ornate high-roller card-back in `#161616` featuring laser-thin slate borders, flipping over a 3D Y-axis transform to reveal the high-contrast role illustration and title.
- Overlays and backdrop dimmers use pure black with 80% opacity and a backdrop blur of `8px` to maintain focused suspense.

## Shapes

The shape architecture is intentionally disciplined, tactical, and architectural (`roundedness: 1` = `0.25rem` / `4px` base border radius).

### Geometric Rationale
- **Base Elements (Buttons, Inputs, Badges):** 4px corner radius. Suggests tactical hardware, secret documents, and clean-cut playing cards.
- **Structural Panels & Modal Sheets (`rounded-lg`):** 8px corner radius. Keeps edges crisp and severe.
- **Playing-Card Components:** Micro-notched or chamfered corner accents simulate high-grade casino stock. Circular avatars (player tokens) are the only spherical shapes across the system, contrasting sharply against the angular architecture.

## Components

### Buttons & Critical Triggers
- **Primary Assassin Action (CTA):** Background `#D90429`, text `#FFFFFF`, font `label-lg`, 4px radius. Zero drop shadow, 1px border `#FF2E4D` on hover/active. On press, triggers an immediate pulse animation.
- **Secondary / Alibi Action:** Background `#161616`, text `#FFFFFF`, border 1px solid `#333333`.
- **Destructive Ghost:** Transparent background, text `#D90429`, hover state highlights with 10% red wash.

### Role Dossier Cards (Playing-Card Motif)
- **Container:** Dual-tone background `#161616`, framed with a 1px slate-charcoal outline (`#262626`).
- **Corner Indices:** In both the top-right and bottom-left corners (mirrored across axes), display the player’s secret suit index (e.g., a miniature skull pip or crosshair along with the Arabic initial of their faction: "م" for Mafia, "مـ" for Citizen).
- **Active State:** When voting or marked, the card border transitions to `#D90429` with an atmospheric crimson drop glow.

### Lists & Player Roster
- **Item Container:** 56px height, seated on `#161616` with a bottom divider of 1px `#222222`.
- **Right Side (Leading):** Circular avatar (36px) framed with state ring (White = Alive, Red = Accused, Slate 50% = Deceased) followed immediately by Player Name in `headline-sm`.
- **Left Side (Trailing):** Accusation count badge or vote status indicator.

### Input Fields (Room Codes, Player Renaming)
- **Field Canvas:** `#121212`, 1px solid `#333333`, right-aligned text entry with placeholder in `#8E9297`.
- **Focus State:** 1px solid `#D90429`, with the input caret rendered in Crimson. Numeric entry fields (e.g., 6-digit lobby codes) use spaced monospace positioning with Western Arabic numerals.

### Checkboxes & Voting Radios
- **Control Box:** 20px square with a 2px radius, `#161616` background, 1px `#8E9297` border.
- **Selected State:** Fill `#D90429` with a crisp white checkmark (`#FFFFFF`) or white target pip for radio selectors.
- **Alignment:** Anchored to the right of the associated player label or option text, with `space-sm` offset.

### Suspense Elements (Custom Gamified Patterns)
- **Round Countdown Gauge:** Horizontal 2px razor bar traversing from right to left across the screen top. Fills with `#8E9297` during normal turns; blazes into pulsating `#D90429` below 10 seconds.
- **Role Reveal Shield:** A tactical tap-and-hold interaction requiring continuous physical contact on an Obsidian thumbprint icon before card details un-blur, securing roles against screen peeking during live party sessions.