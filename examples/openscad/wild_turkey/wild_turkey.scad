// Low-Poly Wild Turkey (Male Gobbler in Repose)
// Reference: Meleagris gallopavo — standing calmly, tail down, wings tucked
//
// Layout: Y+ = forward (head), Y- = rear (tail)
//         X+ = right, X- = left
//         Z+ = up, Z- = down
// Ground at Z = 0 (top surface)
// Scale: 1 unit ≈ 2 cm. Full turkey ~50 cm tall, ~90 cm long

$fn = 6;

// ========== COLORS ==========
BODY_DARK   = [0.18, 0.12, 0.10];
BODY_BRONZE = [0.35, 0.22, 0.12];
NECK_RED    = [0.72, 0.18, 0.14];
HEAD_BLUE   = [0.38, 0.52, 0.68];
HEAD_RED    = [0.75, 0.20, 0.16];
BEAK_C      = [0.62, 0.58, 0.46];
SNOOD_C     = [0.70, 0.22, 0.18];
WATTLE_C    = [0.78, 0.14, 0.12];
TAIL_DARK   = [0.16, 0.12, 0.09];
TAIL_COPPER = [0.55, 0.28, 0.14];
WING_DARK   = [0.16, 0.12, 0.10];
LEG_C       = [0.60, 0.44, 0.38];
FOOT_C      = [0.52, 0.40, 0.34];
BEARD_C     = [0.08, 0.08, 0.08];
EYE_C       = [0.12, 0.08, 0.14];

// ============================================================
//  GROUND — small platform under feet and tail
// ============================================================
color(GROUND_C)
    translate([0, -8, -1])
    cube([50, 80, 2], center = true);

// ============================================================
//  LEGS — standing straight
// ============================================================
color(LEG_C) {
    translate([7, -5, 0]) {
        cylinder(h = 9, r1 = 2.5, r2 = 2.0, center = false);
        translate([0, 0, 9]) cylinder(h = 11, r1 = 2.0, r2 = 1.5, center = false);
        translate([0, 0, 18]) sphere(r = 4);
    }
    translate([-7, -5, 0]) {
        cylinder(h = 9, r1 = 2.5, r2 = 2.0, center = false);
        translate([0, 0, 9]) cylinder(h = 11, r1 = 2.0, r2 = 1.5, center = false);
        translate([0, 0, 18]) sphere(r = 4);
    }
    // Spurs on lower leg
    translate([8.5, -5.5, 10]) rotate([90, 0, 0])
        cylinder(h = 3.5, r1 = 0.5, r2 = 0.15, center = false);
    translate([-8.5, -5.5, 10]) rotate([90, 0, 0])
        cylinder(h = 3.5, r1 = 0.5, r2 = 0.15, center = false);
}

// ========== FEET — on ground, toes spread ==========
// rotate([90, 0, a]): a=0→+Y(tail), a=180→-Y(head)
// Turkey faces -Y (head at y≈-18), tail at y≈+38
// Forward toes point -Y (a=180), back claw points +Y (a=0)
color(FOOT_C) {
    // Right foot (x=+7)
    translate([7, -5, 0]) {
        // Foot pad — flat disc on ground
        translate([0, 0, 0.8]) scale([1.3, 1.2, 0.25]) sphere(r = 2.8);
        // Forward toe (longest, toward -Y/head)
        translate([0, -1.5, 0.3]) rotate([90, 0, 180])
            cylinder(h = 7, r1 = 1.0, r2 = 0.5, center = false);
        // Inner toe (toward body center = -X, angled toward head)
        translate([-1.5, -0.5, 0.3]) rotate([90, 0, 210])
            cylinder(h = 6, r1 = 0.9, r2 = 0.5, center = false);
        // Outer toe (away from body = +X, angled toward head)
        translate([1.5, -0.5, 0.3]) rotate([90, 0, 150])
            cylinder(h = 6, r1 = 0.9, r2 = 0.5, center = false);
        // Back claw (toward +Y/tail)
        translate([0, 1.5, 0.3]) rotate([90, 0, 0])
            cylinder(h = 5, r1 = 0.9, r2 = 0.5, center = false);
    }
    // Left foot (x=-7)
    translate([-7, -5, 0]) {
        // Foot pad
        translate([0, 0, 0.8]) scale([1.3, 1.2, 0.25]) sphere(r = 2.8);
        // Forward toe (toward -Y/head)
        translate([0, -1.5, 0.3]) rotate([90, 0, 180])
            cylinder(h = 7, r1 = 1.0, r2 = 0.5, center = false);
        // Inner toe (toward body center = +X, angled toward head)
        translate([1.5, -0.5, 0.3]) rotate([90, 0, 150])
            cylinder(h = 6, r1 = 0.9, r2 = 0.5, center = false);
        // Outer toe (away from body = -X, angled toward head)
        translate([-1.5, -0.5, 0.3]) rotate([90, 0, 210])
            cylinder(h = 6, r1 = 0.9, r2 = 0.5, center = false);
        // Back claw (toward +Y/tail)
        translate([0, 1.5, 0.3]) rotate([90, 0, 0])
            cylinder(h = 5, r1 = 0.9, r2 = 0.5, center = false);
    }
}

// ============================================================
//  BODY — elongated oval, sitting on legs, upright posture
// ============================================================
color(BODY_DARK) {
    // Main body — elongated oval, slightly lower
    translate([0, 0, 15])
        scale([0.48, 0.9, 0.4])
        sphere(r = 28);

    // Breast — rounded forward bulge
    translate([0, 18, 12])
        scale([0.28, 0.4, 0.33])
        sphere(r = 24);

    // Upper back — smooth spine arc
    translate([0, -6, 21])
        scale([0.4, 0.58, 0.26])
        sphere(r = 24);

    // Rear / undertail — this is where tail feathers attach
    translate([0, -20, 14])
        scale([0.33, 0.48, 0.28])
        sphere(r = 18);

    // Side body (moderate width, room for wings)
    translate([9, 2, 15]) scale([0.12, 0.45, 0.25]) sphere(r = 20);
    translate([-9, 2, 15]) scale([0.12, 0.45, 0.25]) sphere(r = 20);

    // Fillers
    translate([0, 14, 21]) sphere(r = 9);    // body → neck
    translate([7, -5, 7]) sphere(r = 5);     // body → right leg
    translate([-7, -5, 7]) sphere(r = 5);    // body → left leg
}

// Bronze breast highlight
translate([0, 18, 8])
    color(BODY_BRONZE)
    scale([0.18, 0.28, 0.26])
    sphere(r = 22);

// ============================================================
//  WINGS — visible bulges along sides, tucked against body
//  Reference: wings sit on upper side/back, angle slightly back
// ============================================================
color(WING_DARK) {
    // Right wing — low bulge along side, mostly flush with body
    translate([12, 2, 17]) {
        // Shoulder bulge
        scale([0.16, 0.35, 0.22]) sphere(r = 18);
        // Wing trailing edge — extends back, stays low
        translate([0, -8, -3])
            scale([0.13, 0.38, 0.18]) sphere(r = 16);
        // Connector: trailing → tip
        translate([0, -11, -4]) sphere(r = 4);
        // Wing tip near tail
        translate([0, -14, -5])
            scale([0.1, 0.25, 0.14]) sphere(r = 12);
    }
    // Left wing (mirrored)
    mirror([1, 0, 0]) {
        translate([12, 2, 17]) {
            scale([0.16, 0.35, 0.22]) sphere(r = 18);
            translate([0, -8, -3])
                scale([0.13, 0.38, 0.18]) sphere(r = 16);
            // Connector: trailing → tip
            translate([0, -11, -4]) sphere(r = 4);
            // Wing tip near tail
            translate([0, -14, -5])
                scale([0.1, 0.25, 0.14]) sphere(r = 12);
        }
    }
}

// ============================================================
//  TAIL — down and trailing, feathers anchored to body rear
//  Base sits on the rear of the body sphere at y=-18, z=15
//  Feathers angle down ~30° below horizontal, trailing back
// ============================================================
color(TAIL_DARK) {
    t_n = 12;
    t_base_y = -22;    // just behind the body rear
    t_base_z = 13;     // sits on body rear
    t_max_len = 26;
    t_down_angle = 30;
    t_spread = 40;     // narrow — feathers overlap in repose

    // Tail base — merges into body
    translate([0, t_base_y, t_base_z]) sphere(r = 6);

    for (i = [0 : t_n - 1]) {
        a = -t_spread/2 + (i / (t_n - 1)) * t_spread;
        norm = i / (t_n - 1);
        taper = 1.0 - 0.15 * abs(norm - 0.5);
        fl = t_max_len * taper;
        horiz_spread = abs(norm - 0.5) * 5;

        rotate([0, 0, a]) {
            translate([0, t_base_y, t_base_z]) {
                // 90° flips Z→-Y (backward), +down_angle tilts down
                rotate([90 + t_down_angle, 0, horiz_spread])
                    cylinder(h = fl, r1 = 2.0, r2 = 0.5, center = false, $fn = 4);
            }
        }
    }
}

// Copper tips on tail
color(TAIL_COPPER) {
    t_n = 12;
    t_base_y = -22;
    t_base_z = 13;
    t_max_len = 26;
    t_down_angle = 30;
    t_spread = 40;

    for (i = [0 : t_n - 1]) {
        a = -t_spread/2 + (i / (t_n - 1)) * t_spread;
        norm = i / (t_n - 1);
        taper = 1.0 - 0.15 * abs(norm - 0.5);
        fl = t_max_len * taper;
        horiz_spread = abs(norm - 0.5) * 5;

        rotate([0, 0, a]) {
            translate([0, t_base_y, t_base_z]) {
                rotate([90 + t_down_angle, 0, horiz_spread])
                    translate([0, 0, fl * 0.75])
                    sphere(r = 1.3, $fn = 4);
            }
        }
    }
}

// ============================================================
//  NECK — upright, slight forward lean, bare red
// ============================================================
color(NECK_RED) {
    translate([0, 18, 26]) {
        rotate([-18, 0, 0])
            cylinder(h = 24, r1 = 6, r2 = 4, center = false);
    }
    translate([0, 17, 24]) sphere(r = 7);  // neck → body connector
}

// Neck caruncles
translate([0, 18, 26])
    rotate([-18, 0, 0]) {
    color(NECK_RED);
    for (z = [3 : 5 : 18]) {
        translate([-3.5, 1, z]) sphere(r = 1.3, $fn = 4);
        translate([3.5, 1, z]) sphere(r = 1.3, $fn = 4);
    }
}

// ============================================================
//  HEAD — at top of neck, compact
// ============================================================
color(HEAD_RED) {
    translate([0, 24, 46]) {
        scale([0.65, 0.65, 0.75]) sphere(r = 8);
        // Lower face / chin
        translate([0, 4, -2]) sphere(r = 3.5);
    }
}

// Blue crown
color(HEAD_BLUE)
translate([0, 23, 50.5])
    scale([0.38, 0.32, 0.28]) sphere(r = 6);

// Eyes
color(EYE_C) {
    translate([-4.2, 25.5, 48.5]) sphere(r = 1.2);
    translate([4.2, 25.5, 48.5]) sphere(r = 1.2);
}

// Face caruncles
color(HEAD_RED) {
    translate([-3.5, 27.5, 47.5]) sphere(r = 1.5);
    translate([3.5, 27.5, 47.5]) sphere(r = 1.5);
}

// Beak — curved downward at tip
color(BEAK_C)
translate([0, 30.5, 44.5])
    rotate([12, 0, 0])
    cylinder(h = 5, r1 = 0.7, r2 = 1.5, center = false);

// Snood — fleshy dangler from forehead, hangs forward
color(SNOOD_C)
translate([0, 28, 47]) {
    rotate([35, 0, 0]) {
        cylinder(h = 7, r1 = 1.2, r2 = 2.0, center = false);
        translate([0, -1, 7])
            scale([1, 1, 0.5]) sphere(r = 2.0);
    }
}

// Wattle — bulbous growth under beak/chin
color(WATTLE_C)
translate([0, 24, 40]) {
    rotate([-5, 0, 0]) {
        cylinder(h = 5, r1 = 2.5, r2 = 3.5, center = false);
        translate([0, 0, 5])
            scale([1.2, 1.0, 0.6]) sphere(r = 3.5);
    }
}

translate([0, 22, 38]) sphere(r = 5);  // neck → head connector

// ============================================================
//  BEARD — black strands from chest
// ============================================================
color(BEARD_C) {
    translate([0, 22, 11])
        cylinder(h = 22, r1 = 1.2, r2 = 0.3, center = false);
    translate([-2, 22, 11]) rotate([0, 0, -4])
        cylinder(h = 20, r1 = 1.0, r2 = 0.3, center = false);
    translate([2, 22, 11]) rotate([0, 0, 4])
        cylinder(h = 20, r1 = 1.0, r2 = 0.3, center = false);
    translate([-1, 23, 10]) rotate([0, 0, -2])
        cylinder(h = 18, r1 = 0.7, r2 = 0.2, center = false);
    translate([1, 23, 10]) rotate([0, 0, 2])
        cylinder(h = 18, r1 = 0.7, r2 = 0.2, center = false);
}
translate([0, 22, 12]) sphere(r = 4);  // beard → body connector
