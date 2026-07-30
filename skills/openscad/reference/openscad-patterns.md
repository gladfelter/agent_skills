# OpenSCAD Patterns Reference

## File Structure

```openscad
$fn = 32;                    // Polygon quality for circles

// ========== PARAMETERS ==========
// All tunable dimensions at the top

// ========== UTILITY MODULES ==========
// Reusable holes, slots, patterns

// ========== PART MODULES ==========
// One module per physical part

// ========== RENDER CONTROL ==========
// PART variable to select what to render
```

## Flat Plate Pattern (Most Common)

For brackets, mounting plates, and thin parts:

```openscad
T = 3;    // thickness

difference() {
  // Base plate in XY plane, centered
  linear_extrude(height = T, center = true)
    square([W, H], center = true);

  // Holes, cutouts, slots
  translate([x, y, 0]) cylinder(h = T * 2, r = radius, center = true);
}
```

## Rounded Rectangle

```openscad
linear_extrude(height = T, center = true)
  offset(r = 4) square([W - 8, H - 8], center = true);
```

The `offset()` shrinks/grows a 2D shape. Using it with `r > 0` on a square with reduced size creates rounded corners.

## Hole Patterns

### Single clearance hole

```openscad
module clearance(depth) {
  cylinder(h = depth + 0.15, r = HOLE_DIA / 2, center = true, $fn = 16);
}

// Usage:
translate([x, y, 0]) clearance(T);
```

### Symmetric hole pair

```openscad
module hole_pair(spacing, depth, axis = "x") {
  half = spacing / 2;
  if (axis == "x") {
    translate([ half, 0, 0]) clearance(depth);
    translate([-half, 0, 0]) clearance(depth);
  } else {
    translate([0,  half, 0]) clearance(depth);
    translate([0, -half, 0]) clearance(depth);
  }
}
```

### 4-corner pattern

```openscad
hx = width / 2 - margin;
hy = height / 2 - margin;
translate([ hx,  hy, 0]) clearance(T);
translate([-hx,  hy, 0]) clearance(T);
translate([ hx, -hy, 0]) clearance(T);
translate([-hx, -hy, 0]) clearance(T);
```

## Slot (Pill-Shaped Hole)

```openscad
// Vertical slot (elongated along Z in 3D, or Y in 2D)
SLOT_LEN = 12;
CLEARANCE = 4.5;

// Slot body (rectangle)
cube([CLEARANCE + 0.3, SLOT_LEN, T + 0.15], center = true);
// End semicircles
translate([0, -SLOT_LEN/2, 0])
  cylinder(h = T + 0.15, r = CLEARANCE/2, center = true);
translate([0, SLOT_LEN/2, 0])
  cylinder(h = T + 0.15, r = CLEARANCE/2, center = true);
```

## Frame with Opening

```openscad
FRAME = 12;
OPENING = 120;

difference() {
  linear_extrude(height = T, center = true)
    offset(r = 4) square([OPENING + 2*FRAME - 8, OPENING + 2*FRAME - 8], center = true);

  linear_extrude(height = T * 2, center = true)
    square([OPENING - 2, OPENING - 2], center = true);
}
```

## Nut Pocket

```openscad
NUT_DIA = 9;       // M4 hex nut circumscribed
NUT_DEPTH = 3;     // M4 hex nut thickness

module nut_pocket() {
  // Counterbore on back side
  cylinder(h = NUT_DEPTH + 0.15, r = NUT_DIA / 2, center = false);
}

// Usage: inset into back of plate
translate([x, y, -T/2 - NUT_DEPTH]) nut_pocket();
```

## Connecting Arm

```openscad
ARM_LEN = 70;
ARM_W = 20;
FLANGE = 25;

union() {
  // Left flange
  translate([FLANGE/2, 0, 0]) cube([FLANGE, FLANGE, T], center = true);
  // Right flange
  translate([ARM_LEN - FLANGE/2, 0, 0]) cube([FLANGE, FLANGE, T], center = true);
  // Connecting body
  translate([ARM_LEN/2, 0, 0]) cube([ARM_LEN - FLANGE, ARM_W, T], center = true);
}
```

## Rounded Rectangle Plate with Hull

```openscad
// Creates a plate with rounded corners using hull
W = 60; H = 140; R = 3; T = 3;

translate([T/2, 0, 0])
  linear_extrude(height = T)
    hull() {
      circle(r = R);
      translate([W, 0]) circle(r = R);
      translate([W, H]) circle(r = R);
      translate([0, H]) circle(r = R);
    };
```

## Render Control Pattern

```openscad
PART = undef;

if (PART == 1) {
  fan_mount();
} else if (PART == 2) {
  pos_arm();
} else if (PART == 3) {
  case_mount();
} else {
  // Overview: all parts laid out
  translate([-200, 0, 0]) fan_mount();
  translate([0, 0, 0]) pos_arm();
  translate([200, 0, 0]) case_mount();
}
```

Override from CLI: `openscad -D "PART=1" -o part1.stl design.scad`

## Common Modules Reference

| Module | Purpose |
|--------|---------|
| `cube([x,y,z], center=true)` | Box, optionally centered |
| `cylinder(h, r, r, center=true)` | Cylinder/hole |
| `sphere(r)` | Sphere |
| `linear_extrude(h, center=true)` | Extrude 2D to 3D |
| `rotate_extrude()` | Revolve 2D profile into 3D |
| `translate([x,y,z])` | Move |
| `rotate([x,y,z])` | Rotate (degrees, around each axis) |
| `mirror([x,y,z])` | Mirror across plane |
| `scale([x,y,z])` | Scale |
| `difference()` | Boolean subtract |
| `union()` | Boolean add |
| `intersection()` | Boolean intersect |
| `hull()` | Convex hull of children |
| `minkowski()` | Minkowski sum (bevel/offset) |
| `offset(r)` | 2D offset (grow/shrink, or round corners) |
| `children()` | Reference child elements in a module |

## $fn (Fragment Count)

Controls polygon approximation of curves:

| `$fn` | Appearance | Use Case |
|-------|-----------|----------|
| 0 | Prerender resolution | Not recommended |
| 8 | Octagonal | Very fast, blocky |
| 16 | Clearly polygonal | Rough preview |
| 32 | Smooth enough | **Good default** |
| 64 | Very smooth | Final renders |
| 128 | Near-perfect | Small circles, slow |

Override per-object: `cylinder($fn=16)`

## Gotchas

1. **`difference()` order matters** — first child is the base, all subsequent children are subtracted.
2. **Holes must extend through** — cylinder `h` must exceed the part thickness (use `T * 2` or `T + 0.15` with `center=true`).
3. **`center=true` on cylinders** — places the cylinder centered on its axis. Combined with `h = T * 2`, it punches cleanly through a plate of thickness `T`.
4. **`$fn` is global** — setting `$fn = 32` at the top affects all cylinders/spheres. Override per-object for mixed quality.
5. **No variables in module names** — modules must have literal names.
6. **Semicolons required** — unlike most declarative languages, OpenSCAD requires `;` after statements.
7. **`union()` is implicit** — multiple children of a node are unioned automatically. Explicit `union()` is optional but clarifies intent.
