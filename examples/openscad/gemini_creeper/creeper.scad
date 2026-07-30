// Minecraft Creeper Model with Sub-Pixel Surface Detail
// Optimized for 3D Printing with Manifold geometry
P = 1.0; 
PS = 0.25; 
MAX_O = 0.15; 
BASE_T = 1.0; // Thick enough for structural integrity
E = 0.02; 
OVERLAP = 0.5;

HEAD_SIZE = 8.0;
BODY_W = 8.0;
BODY_H = 12.0;
BODY_D = 4.0;
LEG_W = 4.0;
LEG_D = 4.0;
LEG_H = 6.0;

// Pseudo-random noise function
function p_rand(ix, iy, s) = (abs(sin(ix * 12.9898 + iy * 78.233 + s * 43.17) * 43758.5453) % 1.0);

// Face recess logic (ux, uy in range 0..8)
function is_recessed(ux, uy) = 
    (ux >= 1-E && ux < 3-E && uy >= 1-E && uy < 3-E) || // Left Eye
    (ux >= 5-E && ux < 7-E && uy >= 1-E && uy < 3-E) || // Right Eye
    (ux >= 3-E && ux < 5-E && uy >= 3-E && uy < 4-E) || // Nose
    (ux >= 2-E && ux < 6-E && uy >= 4-E && uy < 6-E);   // Mouth

module render_face_pixels(w, h, d_val, seed, ax, ay, az, is_front=false) {
    nx = round(w / PS);
    ny = round(h / PS);
    for (ix = [0 : nx - 1]) {
        for (iy = [0 : ny - 1]) {
            ux = ix * PS;
            uy = iy * PS;
            recessed = (is_front && is_recessed(ux, uy));
            
            if (!recessed) {
                val = p_rand(ix, iy, seed);
                off = val * MAX_O;
                lx = (ix + 0.5) * PS - w/2;
                ly = (ny - 1 - iy + 0.5) * PS - h/2;
                
                // Normal az is outward. Cubes extend into the core.
                center_pos = d_val * az + lx * ax + ly * ay + (off/2 - BASE_T/2) * az;
                
                color([0, 0.45 + val*0.35, 0])
                translate(center_pos)
                    cube([
                        abs(ax.x)*PS + abs(ay.x)*PS + abs(az.x)*(BASE_T+off) + E,
                        abs(ax.y)*PS + abs(ay.y)*PS + abs(az.y)*(BASE_T+off) + E,
                        abs(ax.z)*PS + abs(ay.z)*PS + abs(az.z)*(BASE_T+off) + E
                    ], center=true);
            }
        }
    }
}

module pixel_block(w, d, h, seed, skip_bottom = false, face = false) {
    union() {
        // Internal structural core
        color([0, 0.35, 0]) cube([w - 1.2, d - 1.2, h - 1.2], center=true);
        
        // Deep black backplane for face features
        if (face) {
            color([0.05, 0.05, 0.05])
            translate([0, -d/2 + BASE_T + 0.2, 0])
            cube([w - 0.8, 0.4, h - 0.8], center=true);
        }
        
        // Front (-Y)
        render_face_pixels(w, h, d/2, seed+1, [1,0,0], [0,0,1], [0,-1,0], face);
        // Back (+Y)
        render_face_pixels(w, h, d/2, seed+2, [-1,0,0], [0,0,1], [0,1,0]);
        // Left (-X)
        render_face_pixels(d, h, w/2, seed+3, [0,1,0], [0,0,1], [-1,0,0]);
        // Right (+X)
        render_face_pixels(d, h, w/2, seed+4, [0,-1,0], [0,0,1], [1,0,0]);
        // Top (+Z)
        render_face_pixels(w, d, h/2, seed+5, [1,0,0], [0,1,0], [0,0,1]);
        
        if (!skip_bottom) {
            // Bottom (-Z)
            render_face_pixels(w, d, h/2, seed+6, [1,0,0], [0,-1,0], [0,0,-1]);
        } else {
            // Flat base for stable printing
            color([0, 0.4, 0])
            translate([0, 0, -h/2 + BASE_T/2]) cube([w, d, BASE_T], center=true);
        }
    }
}

module creeper() {
    union() {
        // Head
        translate([0, 0, LEG_H + BODY_H + HEAD_SIZE/2 - OVERLAP*2])
            pixel_block(HEAD_SIZE, HEAD_SIZE, HEAD_SIZE, 110, face=true);
        // Body
        translate([0, 0, LEG_H + BODY_H/2 - OVERLAP])
            pixel_block(BODY_W, BODY_D, BODY_H, 220);
        // Legs (Front-Left, Front-Right, Back-Left, Back-Right)
        for (tx = [-1, 1], ty = [-1, 1])
            translate([tx*LEG_W/2, ty*(BODY_D/2 + LEG_D/2 - 1.0), LEG_H/2])
                pixel_block(LEG_W, LEG_D, LEG_H, 330 + tx + ty*10, skip_bottom=true);
    }
}

// Final assembly
creeper();
