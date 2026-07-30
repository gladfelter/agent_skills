# Screenshot Harness Reference

## The Script

`<skill-path>/openscad/scripts/openscad-screenshots.sh` generates 6 orthographic views and an STL from any `.scad` file.

### Usage

```bash
bash <skill-path>/openscad/scripts/openscad-screenshots.sh <input.scad> <output_dir> [ortho|perspective] [-- extra_args...]
```

### Options

| Argument | Default | Description |
|----------|---------|-------------|
| `<input.scad>` | required | Path to the OpenSCAD source file |
| `<output_dir>` | required | Directory for output files (created if missing) |
| `[ortho\|perspective]` | `ortho` | Projection mode |
| `-- extra_args` | none | Args passed through to every `openscad` call |

### Passing `-D` Flags

Everything after `--` is forwarded to every `openscad` invocation (view renders and STL export):

```bash
# Screenshot only the dome (portico hidden via toggle flag)
DIST=40 bash screenshots.sh model.scad out/ -- -D DO_PORTICO=false

# Multiple flags
DIST=30 bash screenshots.sh model.scad out/ -- -D DO_DOME=false -D DO_WALL=false
```

This is the preferred way to screenshot sub-assemblies — no temp files or sed needed.

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DIST` | `300` | Camera distance from origin (increase for larger models) |
| `IMGSIZE` | `512` | PNG resolution per axis (512 is optimal, see below) |

### Output

```
<output_dir>/
├── front.png     # Camera at +Z, looking at origin
├── back.png      # Camera at −Z, looking at origin
├── top.png       # Camera at +Y, looking at origin
├── bottom.png    # Camera at −Y, looking at origin
├── left.png      # Camera at −X, looking at origin
├── right.png     # Camera at +X, looking at origin
└── model.stl     # Full STL export
```

### Camera Positions

All cameras look at the origin (0,0,0). The `--autocenter` and `--viewall` flags ensure the model is centered and fully visible regardless of its actual position.

**Convention: Z = up, Y = forward, X = right**
Matches OpenSCAD's default viewport (camera at ~10,−20,100 looking at origin).

| View | Eye Position | Sees |
|------|-------------|------|
| Front | (0, −DIST, 0) | XZ plane — face-on view |
| Back | (0, +DIST, 0) | XZ plane — rear view |
| Top | (0, 0, +DIST) | XY plane — bird's-eye view |
| Bottom | (0, 0, −DIST) | XY plane — underside |
| Left | (−DIST, 0, 0) | YZ plane — left side |
| Right | (+DIST, 0, 0) | YZ plane — right side |

## Adjusting DIST

The `DIST` variable controls how far the camera is from the origin. `--viewall` zooms to fit, so `DIST` mainly affects the field of view in perspective mode. For orthographic views, the default 300 works for most models up to ~200mm in any dimension.

For larger assemblies:
```bash
DIST=600 bash <skill-path>/openscad/scripts/openscad-screenshots.sh big_assembly.scad screenshots/
```

## Per-Part Screenshots

For multi-part designs with toggle flags, pass `-D` after `--`:

```bash
# Screenshot just the portico (rotunda and dome disabled)
DIST=30 bash <skill-path>/openscad/scripts/openscad-screenshots.sh \
  model.scad screenshots/portico -- -D DO_ROTUNDA=false -D DO_DOME=false
```

For legacy files using `PART` selectors, create a temp file:
```bash
cat design.scad | sed 's/PART = undef;/PART = 1;/' > /tmp/part1.scad
DIST=300 bash <skill-path>/openscad/scripts/openscad-screenshots.sh /tmp/part1.scad screenshots/p1
```

## Resolution Choice

**Use 512×512** for OpenSCAD screenshots. OpenSCAD renders are flat-color geometry with sharp edges — no texture or fine detail that needs high resolution. At 512px, holes (3-5mm on a 120mm part) are ~17 pixels across, perfectly clear.

Qwen3.6 token formula: `h × w / 1024 + 2` (32×32 pixel patches).

| Resolution | Tokens/img | 6 images | Quality |
|-----------|-----------|----------|----------|
| 512×512 | 258 | 1,548 | Crisp, all features visible |
| 256×256 | 66 | 396 | Small holes fuzzy |
| 1024×1024 | 1,026 | 6,156 | No benefit over 512 |

Override: `IMGSIZE=256 bash <skill-path>/openscad/scripts/openscad-screenshots.sh design.scad out/`

## Custom Screenshots

For non-standard views, call openscad directly:

```bash
# Isometric-ish view (perspective)
openscad \
  --projection=p \
  --camera=200,200,200,0,0,0 \
  --autocenter --viewall \
  --imgsize=1024,1024 \
  --render \
  -o isometric.png \
  design.scad
```

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| All images are blank/black | Model doesn't render | Check `openscad --render -o test.stl design.scad` for errors |
| Model too small in frame | `DIST` too large for perspective mode | Decrease DIST or stick with orthographic |
| Model cut off at edges | `--viewall` not used | Always include `--viewall` |
| Model not centered | `--autocenter` not used | Always include `--autocenter` |
| GUI launches instead of batch | Missing `-o` flag | Script uses `-o`; manual calls must include it |
| Slow rendering | High `$fn` or minkowski hulls | Reduce `$fn` in the `.scad` file |
