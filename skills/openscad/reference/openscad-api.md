# OpenSCAD API Reference

Based on the [OpenSCAD Cheatsheet (v2021.01)](https://openscad.org/cheatsheet/index.html).

## 2D Primitives

| Function | Signature | Description |
|----------|-----------|-------------|
| `circle` | `(r \| d=diameter)` | Circle by radius or diameter |
| `square` | `(size, center)` or `([w, h], center)` | Rectangle |
| `polygon` | `([points])` or `([points], [paths])` | Arbitrary 2D polygon |
| `text` | `(text, size, font, direction, halign, valign, spacing)` | Text as 2D path |
| `import` | `("file.dxf" \| "file.svg", convexity)` | Import DXF/SVG |
| `projection` | `(cut)` | Project 3D → 2D |

## 3D Primitives

| Function | Signature | Description |
|----------|-----------|-------------|
| `sphere` | `(r \| d=diameter)` | Sphere |
| `cube` | `(size, center)` or `([w, d, h], center)` | Box |
| `cylinder` | `(h, r, center)` or `(h, r1, r2, center)` | Cylinder/cone |
| `polyhedron` | `(points, faces, convexity)` | Arbitrary mesh |
| `import` | `("file.stl"\|"file.off"\|"file.amf", convexity)` | Import mesh |

## 2D → 3D Extrusion

| Function | Signature | Description |
|----------|-----------|-------------|
| `linear_extrude` | `(height, center, twist, slices)` | Extrude 2D along Z |
| `rotate_extrude` | `(angle, convexity)` | Revolve 2D around Z axis |
| `surface` | `(file="file.dat"\|"file.png", center)` | Heightmap surface |

## Transformations

| Function | Signature | Description |
|----------|-----------|-------------|
| `translate` | `([x, y, z])` | Move |
| `rotate` | `([x, y, z])` or `(angle, [x, y, z])` | Rotate (degrees) |
| `scale` | `([x, y, z])` | Scale |
| `resize` | `([x, y, z], auto)` | Resize to target dimensions |
| `mirror` | `([x, y, z])` | Mirror across plane |
| `multmatrix` | `(4x4 matrix)` | Arbitrary 4x4 transform |
| `color` | `("name" \| "#hex" \| [r,g,b,a])` | Set color (preview only) |
| `offset` | `(r, chamfer)` | 2D grow/shrink/round |
| `hull` | `()` | Convex hull of children |
| `minkowski` | `(convexity)` | Minkowski sum of children |

## Boolean / CSG Operations

| Function | Description |
|----------|-------------|
| `union()` | Union all children (default behavior) |
| `difference()` | First child minus all others |
| `intersection()` | Intersection of all children |

## Flow Control

| Construct | Syntax | Description |
|-----------|--------|-------------|
| `for` | `(i = [start:end])` or `(i = [start:step:end])` | Loop over range |
| `for` | `(i = [a, b, c])` | Loop over list |
| `for` | `(i = r1, j = r2)` | Nested loops |
| `intersection_for` | Same as `for` | Intersection over loop |
| `if` | `(condition)` | Conditional |
| `if/else` | `(cond) { } else { }` | Branching |
| `let` | `(a=1, b=2) { }` | Local variables |
| `assign` | `(a=1) { }` | Assignment block |

## List Comprehensions

| Pattern | Description |
|---------|-------------|
| `[ for (i = list) expr ]` | Generate list |
| `[ for (i = …) if (cond) expr ]` | Filter |
| `[ for (i = …) if (c) x else y ]` | Map with branches |
| `[ for (i = …) let (v=expr) v ]` | Assignments in comprehension |
| `[ each list ]` | Flatten nested list |

## Special Variables

| Variable | Description |
|----------|-------------|
| `$fn` | Number of fragments (polygon segments) |
| `$fa` | Minimum angle per fragment |
| `$fs` | Minimum fragment size |
| `$t` | Animation time step (0–1) |
| `$vpr` | Viewport rotation [x, y, z] degrees |
| `$vpt` | Viewport translation [x, y, z] |
| `$vpd` | Viewport distance |
| `$vpf` | Viewport field of view |
| `$children` | Number of module children |
| `$preview` | true in F5 preview, false in F6 render |

## Modifier Characters

| Character | Effect |
|-----------|--------|
| `*` | Disable (hide) the object |
| `!` | Show only this object (root) |
| `#` | Highlight in red (debug) |
| `%` | Show as transparent background |

## Mathematical Functions

| Function | Description |
|----------|-------------|
| `abs(x)` | Absolute value |
| `sign(x)` | -1, 0, or +1 |
| `sin(x)`, `cos(x)`, `tan(x)` | Trig (x in degrees) |
| `asin(x)`, `acos(x)`, `atan(x)`, `atan2(y, x)` | Inverse trig |
| `floor(x)`, `ceil(x)`, `round(x)` | Rounding |
| `sqrt(x)` | Square root |
| `pow(x, y)` | x^y |
| `ln(x)`, `log(x, base)` | Logarithm |
| `exp(x)` | e^x |
| `min(a, b)`, `max(a, b)` | Min/max |
| `rands(min, max, count, seed)` | Random numbers |
| `norm(v)` | Vector magnitude |
| `cross(a, b)` | Cross product |
| `len(list)` | List length |
| `concat(a, b, …)` | Concatenate lists |
| `lookup(key, list)` | Binary search in sorted list |

## Type Test Functions

| Function | Description |
|----------|-------------|
| `is_undef(v)` | Check if undefined |
| `is_bool(v)` | Check if boolean |
| `is_num(v)` | Check if number |
| `is_string(v)` | Check if string |
| `is_list(v)` | Check if list |
| `is_function(v)` | Check if function |

## String Functions

| Function | Description |
|----------|-------------|
| `str(a, b, …)` | Convert to string |
| `chr(n)` | Character from code point |
| `ord(s)` | Code point from character |
| `search(regex, str)` | Regex search |

## Other Built-ins

| Function | Description |
|----------|-------------|
| `echo(v1, v2, …)` | Print to console |
| `assert(cond, msg)` | Runtime assertion |
| `children([idx])` | Reference module children |
| `render(convexity)` | Force pre-render of child |
| `version()` | OpenSCAD version string |
| `version_num()` | Version as number |
| `parent_module(idx)` | Parent module info |

## Operators

| Operator | Description |
|----------|-------------|
| `+ - * / % ^` | Arithmetic (+ `^` for power) |
| `< <= == != >= >` | Comparison |
| `&& \|\| !` | Logical |
| `? :` | Ternary conditional |

## Include / Use

| Statement | Description |
|-----------|-------------|
| `include <file.scad>` | Merge definitions (variables + modules) |
| `use <file.scad>` | Import modules/functions only |

## CLI Flags (Key)

| Flag | Description |
|------|-------------|
| `--render` | Force CGAL render (required for batch) |
| `-o file` | Output file (STL/OFF/AMF/3MF) — **required** |
| `-D VAR=val` | Override variable at top level |
| `--projection=o\|p` | Orthographic or perspective |
| `--camera=ex,ey,ez,cx,cy,cz` | Camera eye and center |
| `--autocenter` | Center camera on model |
| `--viewall` | Zoom to fit model |
| `--imgsize=W,H` | PNG resolution |
| `--colorscheme=Name` | Color scheme |
| `--export-format=binstl\|asciistl` | STL format |
| `--csglimit=N` | Abort after N CSG elements (debug) |
