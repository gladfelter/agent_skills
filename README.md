# Agent Skills

Custom AI agent skills for [pi](https://github.com/earendil-works/pi-coding-agent) and other AI coding assistants.

## Skills

| Skill | Description |
|-------|-------------|
| `maestro-flutter-device-testing` | Stateful workflow for Flutter/Maestro device testing — connecting devices, running apps, fixing Flutter semantics-to-Maestro mismatches |
| `openscad` | Design parametric 3D models with OpenSCAD — code, render, screenshot from 6 angles, visually inspect, self-correct |

## Structure

Each skill lives in `skills/<name>/` and contains:

- `SKILL.md` — entry point with metadata, activation instructions, and links to references
- `rules/` or `references/` — detailed guidance documents
- `scripts/` — supporting scripts (if needed)

## Publications

- [`publications/bike-grip-cover/`](publications/bike-grip-cover/) — Article: "Agent Loop: Designing the Grip Cover" — walkthrough of using the `openscad` skill to design a 3D-printed bike grip cover

## Usage

These skills are designed to be used with pi's skill system. Install by placing skill directories into your pi skills path.
