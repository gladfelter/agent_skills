# Project Status: Minecraft Creeper 3D Model

## Goal
Create a 3D printable Minecraft Creeper model with high-resolution pixelation (4 sub-pixels per standard pixel unit) and recessed facial features.

## Current State
- `creeper.scad`: Contains the logic for generating a core + sub-pixel surface noise.
- `openscad-screenshots.sh`: Updated to use `openscad-nightly` with `--backend=manifold`, added 30s timeouts, capped error output, and passes exit codes.

## Identified Issues
1. **Floating Geometry**: ISO screenshots show black panels (eyes/mouth) and green surface panels floating away from the central core.
2. **Face Alignment**: The eyes and mouth are not correctly aligned with the sub-pixel grid on the front face.
3. **Printability**: Need to ensure all sub-pixels have a 100% solid connection to the core without gaps.
4. **Z-Fighting**: Occasional flickering/overlapping surfaces in previews.

## Next Steps
1. **Activate Compactor**: User types `/reload` to enable the `compact` tool (now in the root `extensions/` folder of the repo).
2. **Final Validation**: Perform the "Definition of Done" check from the updated skill in the repo (`skills/openscad/SKILL.md`).
3. **Commit & Push**: User will squash commits and push the `agent_skills` repo to GitHub.

## Notes for Context Compaction
- All dimensions are parametric based on `P` (pixel unit).
- The `manifold` backend is required for performance due to thousands of sub-pixel primitives.
- Use `#` and `color()` for debugging during previews.
