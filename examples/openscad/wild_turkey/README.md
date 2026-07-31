# Low-Poly Wild Turkey (Male Gobbler, Repose)

A low-poly 3D model of a male wild turkey (*Meleagris gallopavo*) standing calmly — tail down and trailing, feathers smooth, wings tucked. Designed in OpenSCAD with a faceted, geometric style.

**File:** `wild_turkey.scad`  
**STL:** `wild_turkey.stl` (~706KB, 1,244 facets)  
**Volumes:** 2 (ground + turkey as one connected mesh)  
**Screenshots:** `screenshots_final/` (6 orthographic views — Z=up convention)

## Design Philosophy

**Low-poly aesthetic: suggest features, don't model them slavishly.** Use bold, simple shapes (scaled spheres, tapered cylinders) to hint at organic forms rather than replicate them. The result reads clearly at a glance without needing high polygon counts.

## Pose: Repose (Standing Calmly)

This model captures the turkey in a natural resting posture — **not** the display/strutting pose:

- **Tail:** Angles down and back at ~30° below horizontal, feathers smooth and overlapping (not fanned). In repose, the tail trails behind rather than erecting into a vertical fan.
- **Wings:** Tucked against the body, represented as angled bulges along the upper sides rather than individual feathers.
- **Body:** Streamlined and compact — no puffed-out chest or ruffled feathers.
- **Neck:** Upright, extended naturally.

This contrasts with the display pose where the tail fans vertically (160°+), feathers ruffle to appear larger, wings spread or drag, and the body puffs out.

## Reference Images

Reference photos of turkeys in standing/repose pose (not strutting):

| # | Description | Source |
|---|-------------|--------|
| 1 | Eastern wild turkey standing, body streamlined, tail down | [Wikimedia Commons](https://upload.wikimedia.org/wikipedia/commons/4/4d/Wild_turkey_eastern_us.jpg) |
| 2 | Male turkey at Cincinnati Zoo, standing normally | [Wikimedia Commons](https://upload.wikimedia.org/wikipedia/commons/9/9d/Turkey1_CincinnatiZoo.jpg) |
| 3 | Male turkey head close-up, red/blue coloration | [Wikimedia Commons](https://upload.wikimedia.org/wikipedia/commons/2/2f/Tom_Turkey_(33152863363).jpg) |
| 4 | Male turkey in snow, tail trailing, wings tucked | [Wikimedia Commons](https://upload.wikimedia.org/wikipedia/commons/5/54/Meleagris_gallopavo_01.jpg) |
| 5 | Wild turkey male, head detail | [Wikimedia Commons](https://upload.wikimedia.org/wikipedia/commons/c/cd/Wild_Turkey-27527-1.jpg) |

## Research Sources

Anatomy and identification references used during modeling:

| Source | URL |
|--------|-----|
| Cornell Lab of Ornithology — Wild Turkey ID | https://www.allaboutbirds.org/guide/Wild_Turkey/id |
| Audubon Field Guide — Wild Turkey | https://www.audubon.org/field-guide/bird/wild-turkey |
| Animal Diversity Web — *Meleagris gallopavo* | https://animaldiversity.org/accounts/Meleagris_gallopavo/ |
| National Wild Turkey Federation — Anatomy | https://www.nwtf.org/content-hub/wild-turkey-anatomy |
| Wikipedia — Wild turkey | https://en.wikipedia.org/wiki/Wild_turkey |
| Tennessee Wildlife — Turkey ID Tutorial | https://www.tn.gov/twra/hunting/big-game/turkey/wild-turkey-identification-tutorial.html |
| Texas Parks & Wildlife — Know Your Turkey Parts | https://tpwmagazine.com/hunting/know-your-turkey-parts/ |

## Model Features

| Feature | Implementation |
|---------|---------------|
| **Body** | Elongated oval — scaled sphere with layered shapes (breast, back, sides, undertail) |
| **Tail** | 12 feathers at ~30° down, narrow spread (40°), copper-tipped, anchored to body rear |
| **Wings** | Tucked — three bulges per side (shoulder, trailing edge, tip), flush against body |
| **Neck** | Upright, 18° forward lean, bare red with caruncle bumps |
| **Head** | Compact, red face, blue crown, dark eyes, curved beak |
| **Snood** | Fleshy dangler from forehead, hangs forward with bulbous tip |
| **Wattle** | Bulbous red growth under beak/chin |
| **Beard** | 5 black strands hanging from chest (center longest) |
| **Legs & feet** | Reddish legs with spurs, foot pads on ground, 4-toed spread (3 forward angled, 1 back claw) |

## Coordinate Convention

```
Z+ = up        Y+ = forward (head)        X+ = right
```

Ground plane at `Z = -1`. The model faces +Y.

## Color Palette (OpenSCAD Preview)

Colors are visible in OpenSCAD's preview mode (F5). The CGAL render (F6) is monochrome.

| Part | RGB | Hex approx |
|------|-----|------------|
| Body | 0.18, 0.12, 0.10 | `#2E1F19` |
| Breast (bronze) | 0.35, 0.22, 0.12 | `#59381F` |
| Neck/head (red) | 0.72, 0.18, 0.14 | `#B72E24` |
| Head crown (blue) | 0.38, 0.52, 0.68 | `#6185AD` |
| Beak | 0.62, 0.58, 0.46 | `#9E9475` |
| Tail (dark) | 0.16, 0.12, 0.09 | `#291F17` |
| Tail tips (copper) | 0.55, 0.28, 0.14 | `#8C4724` |
| Wings | 0.16, 0.12, 0.10 | `#291F1A` |
| Beard | 0.08, 0.08, 0.08 | `#141414` |
| Legs | 0.60, 0.44, 0.38 | `#997061` |
| Feet | 0.52, 0.40, 0.34 | `#856656` |
