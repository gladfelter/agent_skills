// Bike Stand Grip Cover
// Parametric design for an L-shaped grip cover sleeve

// --- Parameters ---
BAR_L = 35;            // Total length of each leg of the L (measured from outside) (mm)
BAR_T = 6.5;           // Total thickness of the bike stand's L-profile (mm)
EXTRUSION_DEPTH = 25;  // Depth of the part being covered (mm)
WALL = 2.5;            // Thickness of the grip cover walls (mm)
ROUNDING = 3;          // Rounding radius for the L-shape corners (mm)
$fn = 64;              // Smoothness

// --- Modules ---

module base_l_shape(l, t) {
    // Basic L-shape composed of two rectangles
    union() {
        square([l, t]);
        square([t, l]);
    }
}

module rounded_l_profile() {
    // To get a final size of BAR_L and thickness BAR_T with rounding,
    // we start with a smaller shape and expand it using offset.
    // This ensures the final bounding box is exactly BAR_L x BAR_L.
    offset(r = ROUNDING) 
        base_l_shape(BAR_L - 2 * ROUNDING, BAR_T - 2 * ROUNDING);
}

module grip_cover() {
    total_depth = EXTRUSION_DEPTH + WALL;
    
    difference() {
        // Outer Shell
        linear_extrude(height = total_depth) {
            // The outer shell is an offset of the inner rounded profile
            offset(r = WALL) 
                rounded_l_profile();
        }
        
        // Inner Void
        // Shifted by WALL in Z to leave a bottom cap.
        translate([0, 0, WALL]) {
            linear_extrude(height = EXTRUSION_DEPTH + 0.1) {
                rounded_l_profile();
            }
        }
    }
}

// --- Render ---
grip_cover();
