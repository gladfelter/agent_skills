#!/usr/bin/env node
/**
 * traversal_graph.js — predict D-pad traversal paths from a Maestro commands log.
 *
 * Reads the same commands-*.json format as analyze_log.js. Builds a directed
 * graph of all interactable elements (each element has up to 4 outgoing edges,
 * one per D-pad direction), scored using a center-based heuristic that
 * approximates Flutter's default directional focus traversal.
 *
 * Elements are clustered by Y coordinate into logical "rows" (horizontal
 * scroll containers like LeanbackRow) and "fixed" regions (nav bars). When a
 * target element is not visible in the hierarchy (off-screen), the script
 * estimates which container it belongs to and how many D-pad presses are
 * needed to scroll it into view.
 *
 * Usage:
 *   node traversal_graph.js <commands-*.json>              # dump full graph
 *   node traversal_graph.js <commands-*.json> <from> <to>  # BFS path
 *
 * Limitations:
 *   - Custom onKeyEvent intercepts (e.g., carousel-up → nav redirect) are
 *     invisible to the script. Only default geometry-based traversal is
 *     modeled.
 *   - Focus scopes may contain traversal within a subtree; the script treats
 *     all elements as flat siblings.
 */

const fs = require("fs");

// ─── helpers ─────────────────────────────────────────────────────────────────

function clamp(v, lo, hi) {
  return v < lo ? lo : v > hi ? hi : v;
}

/** Median of a non-empty numeric array. */
function median(arr) {
  const sorted = [...arr].sort((a, b) => a - b);
  const mid = Math.floor(sorted.length / 2);
  return sorted.length % 2 === 0
    ? (sorted[mid - 1] + sorted[mid]) / 2
    : sorted[mid];
}

// ─── element parsing ─────────────────────────────────────────────────────────

/**
 * Parse a Maestro bounds string like "0,48-120,96".
 * Returns { left, top, right, bottom, centerX, centerY, width, height } or null.
 */
function parseBounds(str) {
  if (!str || typeof str !== "string") return null;
  const [tl, br] = str.split("-");
  if (!tl || !br) return null;
  const [left, top] = tl.split(",").map(Number);
  const [right, bottom] = br.split(",").map(Number);
  if ([left, top, right, bottom].some(isNaN)) return null;
  return {
    left,
    top,
    right,
    bottom,
    width: right - left,
    height: bottom - top,
    centerX: (left + right) / 2,
    centerY: (top + bottom) / 2,
  };
}

/**
 * Walk the Maestro hierarchy tree and collect every element that has a label
 * and parsable bounds. Also records whether the element (or an ancestor) is a
 * scrollable container.
 */
function collectElements(root) {
  const out = [];
  function walk(node, depth, scrollableDepth) {
    if (!node || typeof node !== "object") return;
    const attrs = node.attributes || {};
    let label = "";
    let type = "";
    if (attrs.accessibilityText) {
      label = attrs.accessibilityText;
      type = "accessibilityText";
    } else if (attrs["resource-id"]) {
      label = attrs["resource-id"];
      type = "resource-id";
    }
    const bounds = parseBounds(attrs.bounds);
    const isScrollable = attrs.scrollable === "true";
    const nextScrollableDepth = isScrollable ? depth : scrollableDepth;

    if (label && bounds) {
      out.push({
        label,
        type,
        bounds,
        clickable: attrs.clickable === "true",
        focused: attrs.focused === "true",
        scrollable: isScrollable,
        // How deep in the tree was the nearest scrollable ancestor (0 = self,
        // Infinity = none). Used later to infer "this element is inside a
        // scrollable container."
        scrollableAncestorDepth:
          isScrollable ? 0 : scrollableDepth < Infinity ? scrollableDepth : Infinity,
      });
    }
    if (Array.isArray(node.children)) {
      for (const c of node.children) walk(c, depth + 1, nextScrollableDepth);
    }
  }
  walk(root, 0, Infinity);
  return out;
}

/**
 * Extract the hierarchy root from a commands-*.json file.
 */
function getHierarchy(data) {
  for (const entry of data) {
    if (entry.metadata?.error?.hierarchyRoot) {
      return entry.metadata.error.hierarchyRoot;
    }
  }
  return null;
}

// ─── Y-clustering ────────────────────────────────────────────────────────────

/**
 * Group elements by Y proximity into logical "rows".
 *
 * Uses gap-based clustering: elements are sorted by centerY, and a new cluster
 * is started whenever the Y gap between consecutive elements exceeds an
 * adaptive threshold (2× the median element height).
 */
function clusterByY(elements) {
  if (elements.length === 0) return [];

  const sorted = [...elements].sort(
    (a, b) => a.bounds.centerY - b.bounds.centerY,
  );
  const heights = sorted.map((e) => e.bounds.height).filter((h) => h > 0);
  const threshold = heights.length > 0 ? median(heights) * 2 : 100;

  const clusters = [];
  let current = [sorted[0]];

  for (let i = 1; i < sorted.length; i++) {
    const gap = sorted[i].bounds.centerY - sorted[i - 1].bounds.centerY;
    if (gap > threshold) {
      clusters.push(current);
      current = [sorted[i]];
    } else {
      current.push(sorted[i]);
    }
  }
  clusters.push(current);

  return clusters;
}

/**
 * Classify a cluster as horizontal-row, vertical-list, or fixed-region based
 * on how its elements are laid out and whether they're inside a scrollable.
 */
function classifyCluster(cluster) {
  if (cluster.length <= 1) return "fixed";

  const xs = cluster.map((e) => e.bounds.centerX);
  const ys = cluster.map((e) => e.bounds.centerY);
  const xSpread = Math.max(...xs) - Math.min(...xs);
  const ySpread = Math.max(...ys) - Math.min(...ys);

  const hasScrollable = cluster.some((e) => e.scrollableAncestorDepth < Infinity);

  if (xSpread > ySpread * 2 && hasScrollable) return "horizontal-row";
  if (ySpread > xSpread * 2 && hasScrollable) return "vertical-list";
  if (xSpread > ySpread * 2) return "horizontal-fixed"; // e.g., nav bar
  return "fixed";
}

/**
 * For a horizontal-row cluster, sort by X, assign 0-based indices, and
 * estimate card dimensions.
 */
function annotateHorizontalRow(cluster) {
  const sorted = [...cluster].sort((a, b) => a.bounds.left - b.bounds.left);

  // Estimate card width + gap from the first two elements
  let cardWidth = 220;
  let cardGap = 12;
  if (sorted.length >= 2) {
    cardWidth = sorted[0].bounds.width;
    cardGap = sorted[1].bounds.left - sorted[0].bounds.right;
  }

  // Assign indices
  const indexed = sorted.map((el, i) => ({
    ...el,
    rowIndex: i,
  }));

  return { indexed, cardWidth, cardGap };
}

// ─── scoring ─────────────────────────────────────────────────────────────────

function directionScore(from, to, dir) {
  if (from.label === to.label) return Infinity;
  const fb = from.bounds;
  const tb = to.bounds;

  switch (dir) {
    case "up": {
      if (tb.bottom > fb.top) return Infinity;
      const primary = fb.centerY - tb.centerY;
      const cross = Math.abs(fb.centerX - tb.centerX);
      return clamp(primary, 0.1, Infinity) + 0.1 * cross;
    }
    case "down": {
      if (tb.top < fb.bottom) return Infinity;
      const primary = tb.centerY - fb.centerY;
      const cross = Math.abs(fb.centerX - tb.centerX);
      return clamp(primary, 0.1, Infinity) + 0.1 * cross;
    }
    case "left": {
      if (tb.right > fb.left) return Infinity;
      const primary = fb.centerX - tb.centerX;
      const cross = Math.abs(fb.centerY - tb.centerY);
      return clamp(primary, 0.1, Infinity) + 0.1 * cross;
    }
    case "right": {
      if (tb.left < fb.right) return Infinity;
      const primary = tb.centerX - fb.centerX;
      const cross = Math.abs(fb.centerY - tb.centerY);
      return clamp(primary, 0.1, Infinity) + 0.1 * cross;
    }
    default:
      return Infinity;
  }
}

// ─── graph ───────────────────────────────────────────────────────────────────

function buildGraph(elements) {
  const dirs = ["up", "down", "left", "right"];
  const edges = new Map();

  for (const el of elements) {
    const entry = {};
    for (const dir of dirs) {
      let best = null;
      let bestScore = Infinity;
      for (const candidate of elements) {
        const score = directionScore(el, candidate, dir);
        if (score < bestScore) {
          bestScore = score;
          best = candidate;
        }
      }
      if (best) {
        entry[dir] = { label: best.label, score: bestScore.toFixed(1) };
      }
    }
    edges.set(el.label, entry);
  }

  return { elements, edges };
}

// ─── BFS path ────────────────────────────────────────────────────────────────

function bfsPath(edges, fromLabel, toLabel) {
  if (fromLabel === toLabel) return [];

  const visited = new Set([fromLabel]);
  const queue = [{ label: fromLabel, path: [] }];

  while (queue.length > 0) {
    const { label, path } = queue.shift();
    const neighbors = edges.get(label);
    if (!neighbors) continue;

    for (const dir of ["up", "down", "left", "right"]) {
      const next = neighbors[dir];
      if (!next) continue;
      if (next.label === toLabel) {
        return [...path, { dir, to: next.label }];
      }
      if (!visited.has(next.label)) {
        visited.add(next.label);
        queue.push({ label: next.label, path: [...path, { dir, to: next.label }] });
      }
    }
  }

  return null;
}

// ─── missing target estimation ───────────────────────────────────────────────

/**
 * When a target label is not in the element set, try to estimate which cluster
 * (row) it belongs to and how many D-pad presses are needed to reach it.
 *
 * Heuristic: look for clusters whose elements share a label prefix or semantic
 * "shape" (similar dimensions at a consistent Y). If a target like "Avatar"
 * is requested and clusters contain cards with movie titles, estimate position.
 */
function estimateMissingTarget(targetLabel, clusters, allElements) {
  // Find horizontal-row clusters — those are the ones that scroll
  const scrollableRows = clusters
    .map((cluster) => {
      const type = classifyCluster(cluster);
      if (type === "horizontal-row" || type === "horizontal-fixed") {
        const annotated = annotateHorizontalRow(cluster);
        return {
          type,
          cluster,
          annotated,
          yAvg: median(cluster.map((e) => e.bounds.centerY)),
          firstX: annotated.indexed[0].bounds.left,
          lastX: annotated.indexed[annotated.indexed.length - 1].bounds.right,
        };
      }
      return null;
    })
    .filter(Boolean);

  // For each row, estimate total items based on known metadata. Without source
  // code context this is a guess — we report what IS visible and let the LLM
  // combine with app-code knowledge.
  const result = {
    missing: targetLabel,
    visibleElements: allElements.length,
    rows: scrollableRows.map((row) => ({
      yCenter: Math.round(row.yAvg),
      type: row.type,
      visibleCount: row.annotated.indexed.length,
      firstLabel: row.annotated.indexed[0].label,
      lastLabel: row.annotated.indexed[row.annotated.indexed.length - 1].label,
      cardWidth: Math.round(row.annotated.cardWidth),
      cardGap: Math.round(row.annotated.cardGap),
      // Pixels from leftmost visible card's left edge to right edge of viewport.
      // A rough estimate — assumes 1920px viewport at X=0.
      rightEdge: Math.round(row.lastX),
      // How many more cards of this size could fit before viewport ends:
      fitsToRight: Math.max(
        0,
        Math.floor(
          (1920 - row.lastX) / (row.annotated.cardWidth + row.annotated.cardGap),
        ),
      ),
    })),
  };

  return result;
}

// ─── output ──────────────────────────────────────────────────────────────────

function shortBounds(el) {
  const b = el.bounds;
  return `${b.left},${b.top} ${b.width}x${b.height}`;
}

function dumpGraph(graph) {
  const clusters = clusterByY(graph.elements);
  console.log("=== D-Pad Traversal Graph ===\n");

  // Count elements inside scrollable containers
  const withScrollableAncestor = graph.elements.filter(
    (e) => e.scrollableAncestorDepth < Infinity,
  );
  const outermostScrollable = graph.elements.filter(
    (e) => e.scrollable,
  );

  if (outermostScrollable.length > 0) {
    console.log("Scrollable containers detected:");
    for (const sc of outermostScrollable) {
      console.log(`  ${sc.label || "(unlabeled)"} ${shortBounds(sc)}`);
    }
    console.log(
      `  ${withScrollableAncestor.length}/${graph.elements.length} elements inside a scrollable\n`,
    );
  }

  for (let ci = 0; ci < clusters.length; ci++) {
    const cluster = clusters[ci];
    const type = classifyCluster(cluster);
    const yAvg = Math.round(median(cluster.map((e) => e.bounds.centerY)));

    let label = `Row ${ci}: ${type}`;
    if (type === "horizontal-row" || type === "horizontal-fixed") {
      const { indexed, cardWidth, cardGap } = annotateHorizontalRow(cluster);
      label += ` (Y:${yAvg}, ${indexed.length} visible, card:${cardWidth}x${cardGap} gap)`;

      console.log(`${label}`);
      for (const el of indexed) {
        const idx = el.rowIndex !== undefined ? `[${el.rowIndex}]` : "";
        const focused = el.focused ? " 🎯" : "";
        const scrollTag = el.scrollableAncestorDepth < Infinity ? " ↕" : "";
        console.log(
          `  ${idx} ${el.label} ${shortBounds(el)}${focused}${scrollTag}`,
        );
        const entry = graph.edges.get(el.label);
        if (!entry) continue;
        const dirs = ["up", "down", "left", "right"];
        for (const dir of dirs) {
          const edge = entry[dir];
          const dest = edge
            ? `→ ${edge.label} (${edge.score})`
            : "→ (dead end)";
          console.log(`       ${dir.padEnd(5)} ${dest}`);
        }
      }
    } else {
      label += ` (Y:${yAvg}, ${cluster.length} elements)`;
      console.log(`${label}`);
      for (const el of cluster) {
        const focused = el.focused ? " 🎯" : "";
        console.log(`  ${el.label} ${shortBounds(el)}${focused}`);
        const entry = graph.edges.get(el.label);
        if (!entry) continue;
        const dirs = ["up", "down", "left", "right"];
        for (const dir of dirs) {
          const edge = entry[dir];
          const dest = edge
            ? `→ ${edge.label} (${edge.score})`
            : "→ (dead end)";
          console.log(`       ${dir.padEnd(5)} ${dest}`);
        }
      }
    }

    console.log("");
  }
}

function dumpPath(graph, fromLabel, toLabel) {
  // Check if both endpoints exist
  const fromEl = graph.elements.find((e) => e.label === fromLabel);
  const toEl = graph.elements.find((e) => e.label === toLabel);

  const problems = [];

  if (!fromEl) {
    problems.push(`Source "${fromLabel}" not found in the accessibility tree.`);
  }
  if (!toEl) {
    problems.push(`Target "${toLabel}" not found in the accessibility tree.`);
  }

  // If target is missing, provide estimation
  if (!toEl || !fromEl) {
    const clusters = clusterByY(graph.elements);
    const estimate = estimateMissingTarget(
      toLabel,
      clusters,
      graph.elements,
    );

    console.log("=== Missing Target Report ===\n");
    for (const p of problems) console.log(`${p}\n`);

    console.log(
      `Visible elements: ${estimate.visibleElements} across ${clusters.length} Y-clusters\n`,
    );

    if (estimate.rows.length > 0) {
      console.log(
        "Horizontal rows that may contain the target (scroll right to reveal more):",
      );
      for (const row of estimate.rows) {
        console.log(
          `  Row @ Y≈${row.yCenter}: "${row.firstLabel}" … "${row.lastLabel}" ` +
            `(${row.visibleCount} cards, ${row.cardWidth}px each, ${row.cardGap}px gap)`,
        );
        if (row.fitsToRight > 0) {
          console.log(
            `    ~${row.fitsToRight} more cards may fit before viewport edge`,
          );
        }
      }

      if (estimate.rows.length === 1) {
        const row = estimate.rows[0];
        console.log(
          `\nTo scroll this row: press right from the last visible card.`,
        );
        console.log(
          `Each right-press on the last visible card should trigger a scroll ` +
            `revealing ~${Math.floor(1920 / (row.cardWidth + row.cardGap))} new cards.`,
        );
      }
    }

    console.log(
      "\nCombine this with app source-code knowledge to estimate total items",
    );
    console.log(
      "per row and compute the number of right-presses needed.",
    );

    if (!fromEl || !toEl) {
      console.log(
        "\nNOTE: Path computation requires both endpoints in the tree.",
      );
      console.log(
        "Re-dump the hierarchy after scrolling the target into view.",
      );
      return;
    }
  }

  // Normal path computation
  const path = bfsPath(graph.edges, fromLabel, toLabel);

  if (!path) {
    console.log(`No path found from "${fromLabel}" to "${toLabel}".`);
    return;
  }

  console.log(`Path from "${fromLabel}" to "${toLabel}":\n`);
  for (const step of path) {
    console.log(`  ${step.dir.padEnd(5)} → ${step.to}`);
  }

  console.log("\nMaestro sequence:");
  for (const step of path) {
    const key =
      `Remote Dpad ${step.dir.charAt(0).toUpperCase() + step.dir.slice(1)}`;
    console.log(`  - pressKey: "${key}"`);
  }
}

// ─── main ────────────────────────────────────────────────────────────────────

function main() {
  const args = process.argv.slice(2);
  if (args.length === 0) {
    console.error(
      "Usage: node traversal_graph.js <commands-*.json> [<from> <to>]",
    );
    process.exit(1);
  }

  const filePath = args[0];
  if (!fs.existsSync(filePath)) {
    console.error(`File not found: ${filePath}`);
    process.exit(1);
  }

  const data = JSON.parse(fs.readFileSync(filePath, "utf8"));
  const hierarchy = getHierarchy(data);
  if (!hierarchy) {
    console.error("No hierarchy found in log file.");
    process.exit(1);
  }

  const elements = collectElements(hierarchy);
  if (elements.length === 0) {
    console.error("No interactable elements with bounds found.");
    process.exit(1);
  }

  const graph = buildGraph(elements);

  if (args.length >= 3) {
    dumpPath(graph, args[1], args[2]);
  } else {
    dumpGraph(graph);
  }
}

main();
