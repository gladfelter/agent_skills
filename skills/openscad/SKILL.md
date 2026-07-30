---
name: openscad
description: "Design 3D models with OpenSCAD — code, render, screenshot from 6 angles, visually inspect, self-correct"
tools: openscad, bash, read
---

# OpenSCAD 3D Design with Screenshot Verification

Design parametric 3D models using OpenSCAD's code-based CAD, verify geometry by generating orthographic screenshots from 6 camera angles, and iterate by visually inspecting the renders.

## When to Use This Skill

Use when:
- Designing a 3D printable part or mechanical assembly
- Need precise dimensions and hole placement
- Want to verify geometry visually before exporting STL
- Iterating on a design by inspecting renders and fixing issues
- Designing brackets, mounts, ducts, enclosures, or any parametric mechanical part

Do NOT use when:
- You need organic/sculpted shapes (use Blender/ZBrush)
- You need CAD with constraints and assemblies (use FreeCAD/Fusion)
- You just need to slice an existing STL (use PrusaSlicer/Cura)

## Toolchain

| Concern | Tool | Why |
|---------|------|-----|
| 3D modeling | OpenSCAD | Code-based, parametric, version-controllable |
| Batch rendering | `openscad --render -o` | CLI, no GUI needed, headless |
| Screenshots | `openscad-screenshots.sh` | 6 orthographic views; supports `render` vs `preview` modes |
| Visual inspection | `read` (image tool) | Agent reads PNGs as image attachments |
| Parameter control | `-D VAR=val` | Override design parameters without editing source |

## Core Workflow

```
Write .scad → Render STL (verify no errors) → Generate 6-view screenshots (preview or render)
    → Read ALL screenshots → Analyze geometry → Fix issues → Repeat → Export final
```

### Step 1: Write the OpenSCAD Code

Structure the `.scad` file with:
- **Parameters at top** — all tunable dimensions as variables
- **Utility modules** — reusable hole, slot, and pattern helpers
- **Part modules** — one `module` per physical part
- **Render control** — a `PART` variable to select which part to render

See [reference/openscad-patterns.md](./reference/openscad-patterns.md) for coding conventions.

### Step 2: Render and Verify No Errors

```bash
openscad --render -o output.stl design.scad
```

**CRITICAL**: The `-o <file>` flag is required. Without it, `--render` alone launches the GUI. Check the output for:
- `Top level object is a 3D object` — success
- `Facets: N` — polygon count (complex models: thousands)
- `Volumes: 2` — normal for a single solid (CGAL counts exterior as a volume)
- Error messages about invalid CSG — fix before proceeding

### Step 3: Generate 6-View Screenshots

Use the screenshot harness script bundled with this skill (`scripts/openscad-screenshots.sh`):

```bash
# Default (render mode: verifies manifold geometry, strips colors)
DIST=300 bash <skill-path>/openscad/scripts/openscad-screenshots.sh design.scad screenshots_dir

# Preview mode (fast: preserves colors, ideal for identifying subcomponents)
DIST=300 bash <skill-path>/openscad/scripts/openscad-screenshots.sh design.scad screenshots_dir preview
```

This produces: `front.png`, `back.png`, `top.png`, `bottom.png`, `left.png`, `right.png`, `iso_right.png`, `iso_left.png`, `model.stl`

**Pro Tip:** Use `color("red")` etc. in your `.scad` file and render in `preview` mode to quickly identify the placement and overlap of complex subcomponents. 

**Debug Modifiers (Preview Mode Only):**
- Use the `#` prefix (e.g., `#cube(10);`) to highlight a component. In `preview` mode, this renders it in a distinct color, making it excellent for verifying the position of subcomponents or visualizing the "negative" space of a `difference()` operation. Note that `#` geometry is preserved in `render` mode.
- Use the `%` prefix (e.g., `%cube(10);`) for temporary highlighting. **Warning:** Geometry marked with `%` is completely stripped during `render` mode and will not appear in your final STL.

**Efficiency Tip:** To optimize your model, identify and discard interior geometry that is completely enclosed by other objects. You can confirm which parts are invisible by assigning them a unique, bright color and inspecting the model in `preview` mode—if the color doesn't appear in any of the 6 views, that geometry is likely redundant.

**Render individual parts with `--` and `-D` flags:**

```bash
DIST=100 bash <skill-path>/openscad/scripts/openscad-screenshots.sh \
  design.scad screenshots/p1 preview -- -D DO_LID=false -D DO_BASE=true
```

All args after `--` are passed through to every `openscad` invocation. See [reference/screenshot-harness.md](./reference/screenshot-harness.md) for details.

### Step 4: Read and Analyze Screenshots

```
read screenshots/front.png
read screenshots/iso_right.png
```

The `read` tool sends PNGs as image attachments. **Selective Reading:** In the first iteration, read all views. In subsequent iterations, only read the views relevant to the changes you made to save context tokens and quota. 

| View | Camera | Shows | Check For |
|------|--------|-------|-----------|
| Front | −Y | XZ face (face-on) | Overall layout, symmetry |
| Back | +Y | XZ face (rear) | Hidden features, backside |
| Top | +Z | XY face (bird's-eye) | Footprint, feature placement |
| Bottom | −Z | XY face (underside) | Undercut, bottom details |
| Left | −X | YZ face (left side) | Height, side profile |
| Right | +X | YZ face (right side) | Height, side profile |
| ISO Right | +X, −Y, +Z | Perspective Front-Right-Top | Depth, 3D spatial relationship |
| ISO Left | −X, −Y, +Z | Perspective Front-Left-Top | Depth, 3D spatial relationship |

See [reference/visual-inspection.md](./reference/visual-inspection.md) for what to look for.

### Step 5: Self-Correct

Based on screenshot analysis:
1. Identify issues (wrong hole positions, missing features, wrong proportions)
2. Edit the `.scad` code to fix them
3. Re-render, re-screenshot, re-read
4. Compare before/after
5. Repeat until all views are correct

### Step 6: Export Final STL

```bash
openscad --render -o final_part.stl design.scad
```

For individual parts:
```bash
openscad --render -D "PART=1" -o part1.stl design.scad
openscad --render -D "PART=2" -o part2.stl design.scad
```

## Reference Files

| File | Read When |
|------|-----------|
| [reference/openscad-api.md](./reference/openscad-api.md) | Full OpenSCAD API — primitives, transforms, functions, CLI |
| [reference/batch-api.md](./reference/batch-api.md) | OpenSCAD CLI flags, camera params, rendering modes |
| [reference/screenshot-harness.md](./reference/screenshot-harness.md) | How the 6-view screenshot system works |
| [reference/visual-inspection.md](./reference/visual-inspection.md) | What to check in each view, common mistakes |
| [reference/openscad-patterns.md](./reference/openscad-patterns.md) | CSG operations, modules, patterns |
| [reference/printing-considerations.md](./reference/printing-considerations.md) | FDM printability from a modeling perspective |

## Performance & Complexity

For models with high primitive counts (e.g., thousands of cubes for pixelation):
- **Manifold Backend**: Use `openscad-nightly` with `--backend=manifold`. It is orders of magnitude faster for complex CSG operations.
- **Structural Overlap**: Ensure parts overlap (0.1-1.0mm) to avoid non-manifold "zero-thickness" walls that crash the renderer or cause print failures.
- **Render vs Preview**: Use `preview` mode for fast color-coded layout checks. Use `render` mode sparingly to verify final manifold integrity.

## Context Management

Long-running 3D designs generate massive amounts of image data. To prevent context "crowding":
1. **Status Log**: Maintain a `STATUS.md` file with current goals, identified bugs, and next steps. Update this file *before* every compaction.
2. **Selective Reading**: Only `read` images that verify your current fix.
3. **Piecemeal Testing**: Test complex modules in isolation before full assembly.
4. **Milestone Compaction**: Use the `compact` tool at milestone transitions (e.g., "Face logic finished"). Avoid compacting during an active "negative feedback loop" (failing to fix a specific bug) to preserve the history of failed attempts.
5. **Compaction as a Save Point**: Treat compaction as a state-saving event. Ensure the `STATUS.md` and the `.scad` file are in a stable, well-documented state before summarizing the history.

## Definition of Done (Final Validation)

Before you provide your final response and conclude the task, you MUST perform a "Final Validation Render" to avoid "model optimism" (prematurely calling a task finished).

1.  **Full Render**: Run the screenshot script in `render` mode (not `preview`). This verifies the geometry is manifold and structurally sound.
2.  **Read All Views**: For the final verification, you MUST `read` all 8 generated screenshots. Inspect them for "floating" artifacts, Z-fighting, or missed details that were hidden in other views.
3.  **Check the Logs**: Verify the OpenSCAD output for any CSG warnings or manifold errors.
4.  **Export STL**: Ensure the final `model.stl` is successfully generated and in the output directory.
5.  **Final Summary**: In your final response, explicitly state that you have verified all 8 views and the model is manifold.

## Key Rules

1. **Always use `-o <file>` with `--render`** — without it, the GUI launches and blocks.
2. **Set `$fn` appropriately** — 32 is a good default. Higher for smooth curves, lower for speed. Only introduce high-detail options like `$fa` and `$fs` once the part layout is confirmed, as high geometry counts significantly increase rendering time.
3. **Use `center = true` liberally** — makes symmetry and assembly much easier.
4. **Design flat parts in XY plane** — `linear_extrude(height = T, center = true)` is the go-to pattern.
5. **Add 0.1-0.3mm clearance** to all holes for bolt fit and print tolerance.
6. **Keep plate thickness ≥ 2mm** — thinner walls print poorly and are fragile.
7. **Check relevant views** — issues hidden in one view (overhangs, floating geometry, z-fighting) become obvious from another angle. 
8. **Use `-D VAR=val` for parameter overrides** — avoids editing source files during iteration.
9. **"Volumes: 2" is normal** — CGAL counts the exterior "air" as a volume. A single solid = 2 volumes.
10. **Separate parts into different renders** — multi-part assemblies should be printed separately and bolted together.
11. **Center modules at origin** — design parts at (0,0,0), translate only at assembly time.
12. **Use toggle flags** — `DO_X=true/false` for CLI-controlled part visibility via `-D`.
13. **Manifold Verification**: Before concluding, you must confirm the model is a single manifold solid (indicated by "Volumes: 2" in the render log for a single part).
14. **Final Sign-off**: Do not end the task until you have performed the "Definition of Done" steps above.
15. **Watch for OpenSCAD warnings/errors** in the bash output. CSG warnings or "Mixing 2D and 3D" often indicate geometry bugs.
