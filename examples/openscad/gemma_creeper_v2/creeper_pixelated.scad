// Minecraft Creeper 3D Model - High-Fidelity Pixelated Edition

// --- Parameters ---
block_size = 1; 
pixel_size = 0.25 * block_size; // 4 pixels per unit length as requested

head_dim = 8 * block_size;
body_w = 8 * block_size;
body_h = 12 * block_size;
body_d = 4 * block_size;

leg_w = 4 * block_size;
leg_h = 6 * block_size;
leg_d = 4 * block_size;

color_green = [0.3, 0.6, 0.2]; 
color_black = [0.1, 0.1, 0.1];

// --- Utility ---

// Deterministic pseudo-random function for OpenSCAD
function rnd(x, y, z) = (sin(x * 12.9898 + y * 78.233 + z * 43.123) * 43758.5453) % 1.0;

module pixel_cube(x, y, z, color, ox, oy, oz) {
    translate([x + ox, y + oy, z + oz])
        color(color)
        cube([pixel_size, pixel_size, pixel_size], center=true);
}

module pixelated_volume(w, d, h, center_pos, color, is_leg = false) {
    cx = center_pos[0];
    cy = center_pos[1];
    cz = center_pos[2];

    for (x = [-(w/2) + pixel_size/2 : pixel_size : (w/2) - pixel_size/2]) {
        for (y = [-(d/2) + pixel_size/2 : pixel_size : (d/2) - pixel_size/2]) {
            for (z = [-(h/2) + pixel_size/2 : pixel_size : (h/2) - pixel_size/2]) {
                
                abs_x = cx + x;
                abs_y = cy + y;
                abs_z = cz + z;
                
                // Bottom layer of feet should be flat
                if (is_leg && abs_z <= (cz - h/2 + pixel_size)) {
                    pixel_cube(abs_x, abs_y, abs_z, color, 0, 0, 0);
                } else {
                    // Random offsets in all 3 dimensions for "pixelated" look
                    ox = rnd(abs_x, abs_y, abs_z) * 0.2 - 0.1;
                    oy = rnd(abs_x + 1, abs_y, abs_z) * 0.2 - 0.1;
                    oz = rnd(abs_x, abs_y + 1, abs_z) * 0.2 - 0.1;
                    pixel_cube(abs_x, abs_y, abs_z, color, ox, oy, oz);
                }
            }
        }
    }
}

module pixelated_head() {
    h_dim = head_dim;
    cx = 0; cy = 0; cz = 0;

    for (x = [-(h_dim/2) + pixel_size/2 : pixel_size : (h_dim/2) - pixel_size/2]) {
        for (y = [-(h_dim/2) + pixel_size/2 : pixel_size : (h_dim/2) - pixel_size/2]) {
            for (z = [-(h_dim/2) + pixel_size/2 : pixel_size : (h_dim/2) - pixel_size/2]) {
                
                abs_x = cx + x;
                abs_y = cy + y;
                abs_z = cz + z;
                
                // Face coordinates (Front face is at Y = -4)
                is_front = (abs_y <= -h_dim/2 + pixel_size);
                
                // Face pattern (Creeper face)
                is_eye = ( (abs_x < -1 && abs_x > -3 && abs_z > 0 && abs_z < 2) || 
                           (abs_x > 1 && abs_x < 3 && abs_z > 0 && abs_z < 2) );
                
                is_mouth = ( (abs_x >= -1 && abs_x <= 1 && abs_z >= -0.5 && abs_z <= 0.5) || 
                             (abs_x >= -2 && abs_x <= 2 && abs_z >= -2.5 && abs_z <= 0.5) || 
                             (abs_x >= -2 && abs_x < -1 && abs_z >= -3.5 && abs_z <= -2.5) || 
                             (abs_x > 1 && abs_x <= 2 && abs_z >= -3.5 && abs_z <= -2.5) );

                if (is_front && (is_eye || is_mouth)) {
                    // Uniformly recessed and black
                    // Offset them in -Y to "dig into" the head
                    pixel_cube(abs_x, abs_y, abs_z, color_black, 0, -0.2, 0);
                } else {
                    // Random offsets for head skin
                    ox = rnd(abs_x, abs_y, abs_z) * 0.2 - 0.1;
                    oy = rnd(abs_x + 1, abs_y, abs_z) * 0.2 - 0.1;
                    oz = rnd(abs_x, abs_y + 1, abs_z) * 0.2 - 0.1;
                    pixel_cube(abs_x, abs_y, abs_z, color_green, ox, oy, oz);
                }
            }
        }
    }
}

// --- Assembly ---

// Head
translate([0, 0, 6 + 12 + 4]) pixelated_head();

// Body
translate([0, 0, 6 + 12/2]) pixelated_volume(8, 4, 12, [0, 0, 0], color_green);

// Legs
overlap = 1.0;
leg_y_offset = (4/2) + (4/2) - overlap;
translate([-2,  leg_y_offset, 3]) pixelated_volume(4, 4, 6, [0, 0, 0], color_green, true);
translate([ 2,  leg_y_offset, 3]) pixelated_volume(4, 4, 6, [0, 0, 0], color_green, true);
translate([-2, -leg_y_offset, 3]) pixelated_volume(4, 4, 6, [0, 0, 0], color_green, true);
translate([ 2, -leg_y_offset, 3]) pixelated_volume(4, 4, 6, [0, 0, 0], color_green, true);
