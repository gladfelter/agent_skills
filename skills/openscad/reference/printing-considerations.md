# Printing Considerations for OpenSCAD Models

## Minimum Dimensions

| Feature | Minimum | Recommended |
|---------|---------|-------------|
| Wall thickness | 0.8mm | ≥ 2mm |
| Bolt clearance hole | 4mm (M4) | 4.5mm clearance |
| Support bridge span | — | ≤ 50mm (no supports needed) |
| Overhang angle | 45° | ≤ 45° (no supports) |
| Text height | 2mm | ≥ 3mm legible |
| Small hole | 2mm | ≥ 3mm reliable |

## Designing for FDM Printability

### Print Orientation

Design parts to print flat (thin dimension along Z) when possible:
- Flat plates: `linear_extrude(height = T)` prints with the extrusion as the Z-axis
- Avoid designing with the print Z-axis having complex geometry
- Consider adding **breakaway tabs** for parts that need vertical features

### Avoid Supports

- Keep overhangs under 45°
- Use chamfers instead of sharp external corners
- Design brackets as flat plates with tabs (print flat, bolt together)

### Wall Strength

- Minimum 2 perimeters (0.4mm nozzle → 0.8mm wall) for structural parts
- Design critical load paths along the XY plane (stronger than Z-axis layer adhesion)
- Bolt holes should have ≥ 3mm of material between hole edge and part edge

### Hole Quality

- Circles with `$fn ≥ 16` print acceptably round
- `$fn = 32` for visible holes
- Clearance holes should be 0.3-0.5mm larger than bolt diameter
- For tight fits (press-fit), size hole to nominal bolt diameter

### Assembly Design

- Design parts to bolt together (not glue or press-fit) for reliability
- Include alignment features (dovetails, pegs) for multi-part assemblies
- Leave 0.2mm gap between mating surfaces to avoid interference from print tolerance
- Design with **slotted holes** for adjustability — accounts for print variance and allows tuning

## Common OpenSCAD Print Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| Hole prints too small | Extrusion overshoot | Add 0.3-0.5mm clearance |
| Part warps | Large flat surface | Add raft in slicer, or design with feet/ridges |
| Layer lines visible | Part prints with features along Z | Rotate part or redesign orientation |
| Bridge sags | Long spans | Add support struts or reduce span |
| Stringing | Large part with travel | Not a modeling issue — slicer settings |
| Detached part | Disconnected geometry (multiple volumes) | Fix `union()` or `translate()` in model |

## Multi-Part Assembly Tips

1. **Print parts separately** — each part as its own STL file
2. **Include alignment holes** — use dowel pins or bolt alignment
3. **Design for adjustment** — slotted holes allow tuning after printing
4. **Test fit with dry assembly** — print one set, check fit, adjust tolerances
5. **Document hardware** — list all bolts, nuts, washers needed

## Material Considerations

| Material | Use Case | Notes |
|----------|----------|-------|
| PLA | Most brackets, enclosures | Easy to print, brittle under impact |
| PETG | Functional parts, outdoor | Flexible, chemical resistant |
| ABS/ASA | High temp, durable | Warps more, needs enclosure |
| TPU | Flexible parts, grips | Slow print, special nozzle helps |

For PC case brackets, PLA or PETG is sufficient. The parts are not under high stress or heat.
