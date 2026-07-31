// Minecraft Creeper 3D Model - Precision Proportion Adjustment

// --- Parameters ---
block_size = 1; 

head_dim = 8 * block_size;
body_w = 8 * block_size; // Explicitly matches head X extent
body_h = 12 * block_size;
body_d = 4 * block_size; // Substantial "slab" depth

leg_w = 4 * block_size;
leg_h = 6 * block_size;
leg_d = 4 * block_size;

// Colors
color_green = [0.3, 0.6, 0.2]; 
color_black = [0.1, 0.1, 0.1];

// --- Modules ---

module head() {
    union() {
        color(color_green)
        cube([head_dim, head_dim, head_dim], center=true);
        
        face_thickness = 0.15 * block_size;
        face_y_offset = -head_dim/2 - (face_thickness / 2);

        color(color_black)
        translate([0, face_y_offset, 0]) {
            translate([-2 * block_size, 0, 1 * block_size]) 
                cube([2 * block_size, face_thickness, 2 * block_size], center=true);
            translate([2 * block_size, 0, 1 * block_size]) 
                cube([2 * block_size, face_thickness, 2 * block_size], center=true);
            translate([0, 0, -0.5 * block_size]) 
                cube([2 * block_size, face_thickness, 1 * block_size], center=true);
            translate([0, 0, -2 * block_size]) 
                cube([4 * block_size, face_thickness, 2 * block_size], center=true);
            translate([-1.5 * block_size, 0, -3 * block_size]) 
                cube([1 * block_size, face_thickness, 2 * block_size], center=true);
            translate([1.5 * block_size, 0, -3 * block_size]) 
                cube([1 * block_size, face_thickness, 2 * block_size], center=true);
        }
    }
}

module body() {
    color(color_green)
    cube([body_w, body_d, body_h], center=true);
}

module leg() {
    color(color_green)
    cube([leg_w, leg_d, leg_h], center=true);
}

// --- Assembly ---

// "Barely intersect":
// The leg's inner edge should be almost at the body's outer edge.
// Body edge = body_d / 2 = 2.
// Leg inner edge = leg_y_offset - (leg_d / 2).
// To overlap more for 3D printability
overlap = 1.0 * block_size;
leg_y_offset = (body_d / 2) + (leg_d / 2) - overlap;

// Front row
translate([-leg_w/2,  leg_y_offset, leg_h/2]) leg(); 
translate([ leg_w/2,  leg_y_offset, leg_h/2]) leg(); 

// Back row
translate([-leg_w/2, -leg_y_offset, leg_h/2]) leg(); 
translate([ leg_w/2, -leg_y_offset, leg_h/2]) leg(); 

// Body
translate([0, 0, leg_h + body_h/2]) body();

// Head
translate([0, 0, leg_h + body_h + head_dim/2]) head();
