# OpenSCAD Batch API Reference

## Installation

```bash
sudo apt install -y openscad    # Ubuntu/Debian
openscad --version              # Verify (2021.01 on Ubuntu 24.04)
```

On WSL, the Windows installation is also accessible at:
```
/mnt/c/Program Files/OpenSCAD/openscad.exe
```

## Rendering (Required — Prevents GUI Launch)

The `-o <file>` flag is the **only** way to run headless. Without it, OpenSCAD launches the GUI regardless of other flags.

```bash
# Render to STL
openscad --render -o output.stl design.scad

# Render to other formats
openscad --render -o output.off design.scad    # OFF (polygon format)
openscad --render -o output.amf design.scad    # AMF
openscad --render -o output.3mf design.scad    # 3MF
openscad --render -o output.csg design.scad    # CSG tree (debug)
```

### STL Quality

```bash
openscad --render -o output.stl design.scad           # Default (ascii STL)
openscad --export-format=binstl -o output.stl design.scad  # Binary STL
openscad --export-format=asciistl -o output.stl design.scad # Explicit ascii
```

### Render Summary Output

```
Top level object is a 3D object:
   Simple:        yes
   Vertices:      472
   Facets:        242
   Volumes:         4        ← 2 per solid (exterior counted)
```

- `Simple: yes` — manifold, watertight geometry (good for printing)
- `Simple: no` — non-manifold (may have issues)
- `Volumes: 2` — one solid (normal)
- `Volumes: 4` — two solids (assembly or disconnected parts)

## PNG Export with Camera Control

```bash
openscad \
  --projection=o \
  --camera=eye_x,eye_y,eye_z,center_x,center_y,center_z \
  --autocenter \
  --viewall \
  --imgsize=1024,1024 \
  --render \
  -o view.png \
  design.scad
```

### Camera Parameter Format

`--camera` accepts two formats:

**Eye + Center (6 values):**
```
--camera=eye_x,eye_y,eye_z,center_x,center_y,center_z
```

**Translation + Rotation + Distance (8 values):**
```
--camera=translate_x,y,z,rot_x,y,z,dist
```

The 6-value format is more intuitive for standard views.

### Projection Modes

| Flag | Description |
|------|-------------|
| `--projection=o` | Orthographic — parallel projection, true dimensions |
| `--projection=p` | Perspective — vanishing point, realistic look |

Use orthographic (`o`) for dimension verification. Use perspective (`p`) for presentation.

### Camera Helpers

| Flag | Description |
|------|-------------|
| `--autocenter` | Adjust camera to look at object's center of bounding box |
| `--viewall` | Zoom to fit entire object in view |

Always use both `--autocenter` and `--viewall` for consistent framing.

### Image Size

```bash
--imgsize=512,512      # Optimal for Qwen3.6 vision (258 tokens/image)
--imgsize=256,256      # Minimum viable (66 tokens/image, jagged edges)
--imgsize=1024,1024    # Overkill for CAD geometry (1026 tokens/image)
```

**Qwen3.6 token cost:** `h × w / 1024 + 2` tokens per image (32×32 patches).
For 6-view inspection:
- 512×512: 1,548 tokens total (0.9% of 163K context) — **recommended**
- 256×256: 396 tokens (0.2%) — small holes may be fuzzy
- 1024×1024: 6,156 tokens (3.8%) — unnecessary for CAD geometry

### Color Schemes

```bash
--colorscheme=Cornfield        # Default yellow-green
--colorscheme=Monotone         # Grayscale (cleaner for inspection)
--colorscheme=DeepOcean        # Dark blue theme
--colorscheme=Tomorrow Night   # Dark theme
```

### View Options (Debug)

```bash
--view=axes        # Show coordinate axes
--view=edges       # Show wireframe edges
--view=wireframe   # Wireframe only
--view=crosshairs  # Center crosshair
```

### CSG Limit (Debug Complex Models)

```bash
--csglimit=1000    # Stop rendering at 1000 CSG elements
```

Useful for diagnosing which operation caused a problem in complex models.

## Parameter Override

```bash
# Override a variable without editing the source file
openscad --render -D "PART=1" -o part1.stl design.scad
openscad --render -D "SCALE=2" -o big.stl design.scad
openscad --render -D "HOLE_SIZE=5" -o design.scad -o output.stl
```

Multiple `-D` flags can be combined:
```bash
openscad --render -D "PART=1" -D "T=4" -D "HOLE=5" -o output.stl design.scad
```

## Coordinate System

OpenSCAD uses a right-handed coordinate system:
- **X** — right
- **Y** — forward / depth
- **Z** — up

When viewing from +Z (top-down), X runs left-to-right and Y runs bottom-to-top.

## Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| GUI launches | Missing `-o` flag | Always use `-o <file>` |
| `ERROR: Unable to select an object` | Empty model after CSG | Check `difference()` arguments |
| `CGAL: error` | Invalid geometry | Check for negative sizes, degenerate shapes |
| Black PNG | Nothing in camera view | Use `--viewall --autocenter` |
| Very slow render | High `$fn` or minkowski | Reduce `$fn`, avoid minkowski on large objects |
