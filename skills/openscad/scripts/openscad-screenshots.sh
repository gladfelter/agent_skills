#!/bin/bash
#
# OpenSCAD Screenshot Harness
# Generates 6 orthographic views from a .scad file.
#
# Usage: openscad-screenshots.sh <input.scad> <output_dir> [ortho|perspective] [render|preview] [-- extra_args...]
#
# Extra args after -- are passed through to every openscad invocation.
# Example: openscad-screenshots.sh model.scad out/ -- -D PART=1 -D SCALE=2
#          openscad-screenshots.sh model.scad out/ o preview -- -D PART=1
#
# Output:
#   <output_dir>/front.png, back.png, top.png, bottom.png, left.png, right.png
#   <output_dir>/model.stl

set -euo pipefail

SCAD_FILE="${1:?Usage: openscad-screenshots.sh <input.scad> <output_dir> [ortho|perspective] [render|preview] [-- extra...]}"
shift
OUTPUT_DIR="${1:?Usage: openscad-screenshots.sh <input.scad> <output_dir> [ortho|perspective] [render|preview] [-- extra...]}"
shift

PROJECTION="o"
MODE="render"
EXTRA_ARGS=()

# Parse remaining args: optional projection, then optional -- separator + extras
while [[ $# -gt 0 ]]; do
  case "$1" in
    --)
      shift
      EXTRA_ARGS=("$@")
      break
      ;;
    ortho|o)
      PROJECTION="o"
      shift
      ;;
    perspective|p)
      PROJECTION="p"
      shift
      ;;
    render|rn)
      MODE="render"
      shift
      ;;
    preview|pv)
      MODE="preview"
      shift
      ;;
    *)
      # Treat unknown args as extra (backwards compat with -D flags directly)
      EXTRA_ARGS+=("$1")
      shift
      ;;
  esac
done

# Camera distance from center (adjust for model size)
DIST="${DIST:-300}"
# PNG resolution
IMGSIZE="${IMGSIZE:-512}"
# Timeout for OpenSCAD operations (seconds)
OS_TIMEOUT="${OS_TIMEOUT:-30}"

mkdir -p "$OUTPUT_DIR"

echo "Rendering 6 views of $SCAD_FILE → $OUTPUT_DIR (projection: $PROJECTION, mode: $MODE)"
if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
  echo "  Extra args: ${EXTRA_ARGS[*]}"
fi

# Determine OpenSCAD binary
OPENSCAD_BIN="openscad"
IS_NIGHTLY=false
if command -v openscad-nightly >/dev/null 2>&1; then
  OPENSCAD_BIN="openscad-nightly"
  IS_NIGHTLY=true
  # Add manifold backend if using nightly
  EXTRA_ARGS+=("--backend=manifold")
fi

render_view() {
  local name="$1"
  local cam="$2"
  local out="$OUTPUT_DIR/${name}.png"
  local render_flag=""
  if [[ "$MODE" == "render" ]]; then
    render_flag="--render"
  fi
  echo "  → $name"
  
  # Run openscad with timeout and capture output
  local exit_code=0
  set +e
  timeout "$OS_TIMEOUT" "$OPENSCAD_BIN" \
    --projection="$PROJECTION" \
    --camera="$cam" \
    --autocenter \
    --viewall \
    --imgsize="${IMGSIZE},${IMGSIZE}" \
    $render_flag \
    -o "$out" \
    "${EXTRA_ARGS[@]}" \
    "$SCAD_FILE" > /tmp/os_out.log 2>&1
  exit_code=$?
  set -e

  if [[ $exit_code -eq 124 ]]; then
    echo "ERROR: OpenSCAD timed out after $OS_TIMEOUT seconds."
    if [[ "$IS_NIGHTLY" == "false" ]]; then
      echo "TIP: Try installing 'openscad-nightly' and passing '--backend=manifold' for much faster rendering."
    fi
    exit 124
  elif [[ $exit_code -ne 0 ]]; then
    echo "ERROR: OpenSCAD failed with exit code $exit_code."
    cat /tmp/os_out.log | grep -viE "Compiling design|Normalized CSG tree|Geometries in cache|Geometry cache size|CGAL (Polyhedrons|cache size)|Total rendering time" | head -n 20
    exit "$exit_code"
  fi
}

render_view "front"  "0,-$DIST,0,0,0,0"
render_view "back"   "0,$DIST,0,0,0,0"
render_view "top"    "0,0,$DIST,0,0,0"
render_view "bottom" "0,0,-$DIST,0,0,0"
render_view "left"   "-$DIST,0,0,0,0,0"
render_view "right"  "$DIST,0,0,0,0,0"
render_view "iso_right" "$DIST,-$DIST,$DIST,0,0,0"
render_view "iso_left"  "-$DIST,-$DIST,$DIST,0,0,0"

# Export STL
if [[ "$MODE" == "render" ]]; then
  echo "  → model.stl"
  set +e
  timeout "$OS_TIMEOUT" "$OPENSCAD_BIN" -o "$OUTPUT_DIR/model.stl" "${EXTRA_ARGS[@]}" "$SCAD_FILE" > /tmp/os_out.log 2>&1
  exit_code=$?
  set -e
  if [[ $exit_code -eq 124 ]]; then
    echo "ERROR: STL export timed out."
    exit 124
  elif [[ $exit_code -ne 0 ]]; then
    echo "ERROR: STL export failed."
    cat /tmp/os_out.log | grep -viE "Compiling design|Normalized CSG tree|Geometries in cache|Geometry cache size|CGAL (Polyhedrons|cache size)|Total rendering time" | head -n 20
    exit "$exit_code"
  fi
fi

echo "Done. Output files:"
ls -lh "$OUTPUT_DIR"/*.png 2>/dev/null || true
ls -lh "$OUTPUT_DIR"/*.stl 2>/dev/null || true
