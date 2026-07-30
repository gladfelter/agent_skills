# Visual Inspection Guide

## How to Read OpenSCAD Screenshots

OpenSCAD renders in a yellow-green color scheme (Cornfield default). Key visual cues:

- **Solid faces** — yellow-green filled regions
- **Holes** — white circles/pill shapes (background showing through)
- **Edges/contours** — darker lines where faces meet
- **Lighting gradient** — top of image is lighter, bottom is darker (fixed light direction)
- **Overlapping geometry** — darker where multiple faces stack

## What Each View Reveals

### Front View (+Z, looking down on XY plane)

This is the "bird's eye" view of the model. Best for:
- Overall layout and symmetry
- Hole placement and spacing
- Slot positions and orientations
- Feature alignment

**Check:**
- Are holes where they should be?
- Is the part symmetrical (if intended)?
- Are all features visible and correctly positioned?
- Are slots the right orientation (horizontal vs vertical pill)?

### Back View (−Z, looking up from below)

Shows the underside. Best for:
- Nut pockets and countersinks
- Features only visible from below
- Verifying no unwanted cutouts on the back

### Top View (+Y, looking at XZ plane)

Best for:
- Height/dimension in Z
- Side profile
- Overhangs and supports needed for printing
- Thin plates appear as horizontal lines

**Check:**
- Plate thickness is visible (not too thin to print)
- No unexpected features poking up or down
- Slots in the Z-direction show as vertical pills

### Bottom View (−Y, looking at XZ from below)

Same as top but from the other side. Best for:
- Bottom edge details
- Features that extend below the main body

### Left/Right Views (∓X, looking at YZ plane)

Best for:
- Depth of the part (Y dimension)
- Side profile and wall thickness
- Mounting features on the sides

**Check:**
- Wall thickness is adequate (≥2mm)
- Mounting tabs/ears extend far enough
- No floating or disconnected geometry

## Common Mistakes Visible in Screenshots

### Missing `difference()` — Holes Aparing as Solid

If holes should be there but the face is solid, the `difference()` operation may be missing or mis-nested.

**Fix:** Ensure the subtracted geometry is inside a `difference() {}` block.

### Parts Floating Apart

In the overview, parts should be touching or properly aligned. If there are gaps where parts should connect, check `translate()` coordinates.

**Fix:** Verify translation offsets match the intended assembly positions.

### Geometry Clipping / Negative Dimensions

White artifacts or missing corners indicate subtracted geometry is larger than the base shape, or dimensions are negative.

**Fix:** Check that all `cube()`, `cylinder()` sizes are positive. Verify that `difference()` children are fully contained within the parent.

### Inverted `difference()` — Hole Eats the Whole Part

If the rendered model is tiny or missing, the subtracted geometry may be larger than intended.

**Fix:** Check the order of operations in `difference()`. First child = base, remaining children = subtractions.

### Slot Orientation Wrong

A slot that should run vertically (pill shape tall) appears horizontally (pill shape wide), or vice versa.

**Fix:** Check which axis the slot rectangle is elongated along. The `cube()` or translate should extend along the intended axis.

### Plate Too Thin in Edge Views

From the top/bottom/left/right views, a flat plate appears as a thin line. If it's barely visible, the thickness may be too small for reliable printing.

**Fix:** Ensure `T` (thickness) ≥ 2mm for structural parts, ≥ 1.5mm for cosmetic parts.

## Dimension Verification

### Code + Screenshot Cross-Check (Primary Method)

The most reliable approach: **compare declared code values against visual ratios in the screenshot.**

1. From code: `FAN_SIZE = 120`, `FRAME = 12` → total = 144, opening ratio = 120/144 = 83%
2. From screenshot: does the opening look like ~83% of the plate? If it looks 70% or 90%, something is wrong.
3. From code: `FAN_MOUNT_SPACING = 105` on a 144mm plate → holes at 52.5/144 = 36% from center
4. From screenshot: do the holes sit at roughly that position?

This catches: wrong `difference()` child sizes, wrong `translate()` offsets, swapped dimensions.

### Scale Bar (Optional)

For a direct visual reference, include a scale bar in your render:

```openscad
use <lib/scad-utils/scale_bar.scad>;

// In your render block, add a 50mm reference bar in the corner:
scale_bar(length = 50, x = 50, y = -85, z_offset = 2);
```

The bar renders as a 50mm line with end ticks. You can visually compare it to features in the model.

### What Orthographic Screenshots Can Verify

From orthographic screenshots, you can visually verify proportions:

1. **Compare to known dimensions** — e.g., a 120mm fan opening should be roughly square
2. **Check ratios** — a 120×120 opening should look square, not rectangular
3. **Count features** — 4 mounting holes should appear as 4 white circles
4. **Slot length** — a 12mm slot should be about 1/10th of a 120mm feature

For precise measurements, compare hole-to-hole distances visually. In orthographic projection, parallel features maintain their true proportions.

## Printability Checks from Screenshots

| Issue | Visible In | What to Look For |
|-------|-----------|-----------------|
| Thin walls (<1mm) | Edge views | Line too thin to resolve clearly |
| Large overhangs (>45°) | Side views | Features extending without support below |
| Internal cavities | All views (invisible) | Can't see from screenshots — verify in code |
| Disconnected parts | Overview | Gaps where parts should touch |
| Very small holes (<2mm) | Any view | Dot too small to print reliably |

## Color Scheme for Better Inspection

The default Cornfield color scheme works well. For cleaner inspection, consider:

```bash
--colorscheme=Monotone   # Grayscale — easier to spot artifacts
```
