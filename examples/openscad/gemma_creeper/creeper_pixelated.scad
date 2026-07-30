// Minecraft Creeper Model - Final Surface Pixelation

// Parameters
head_size = 8;
body_w = 8;    
body_d = 4;    
body_h = 16;   
leg_w = 4;     
leg_d = 4;     
leg_h = 3;     

face_color = "black";
creeper_color = "green";

pixel_size = 4.0; 
jitter = 0.4;

function random(seed) = abs(sin(seed * 12.9898) * 43758.5453) - floor(abs(sin(seed * 12.9898) * 43758.5453));

module noise_grid(w, h, seed, exclude_face=false) {
    step = pixel_size;
    for (x = [0 : step : w - step]) {
        for (y = [0 : step : h - step]) {
            is_eye = false;
            is_nose = false;
            is_mouth = false;
            
            if (exclude_face) {
                cx = x - w/2 + step/2;
                cy = y - h/2 + step/2;
                is_eye = ((abs(cx) > 1 && abs(cx) < 3) && (cy > 1 && cy < 3));
                is_nose = ((abs(cx) < 1) && (abs(cy) < 2));
                is_mouth = ((abs(cx) > 1 && abs(cx) < 3) && (cy < -1 && cy > -4));
            }

            if (!(exclude_face && (is_eye || is_nose || is_mouth))) {
                z_noise = (random(seed + x*10 + y*20) - 0.5) * 2 * jitter;
                val = abs(z_noise); 
                translate([x + step/2, y + step/2, 0])
                    cube([step, step, val], center=true);
            }
        }
    }
}

module apply_surface_noise(normal_rot, face_center, w, h, seed, type="add", exclude_face=false) {
    translate(face_center) {
        rotate(normal_rot) {
            translate([-w/2, -h/2, 0]) {
                if (type == "add") {
                    color(creeper_color) noise_grid(w, h, seed, exclude_face);
                } else {
                    noise_grid(w, h, seed, exclude_face);
                }
            }
        }
    }
}

module base_head() {
    cube([head_size, head_size, head_size], center=true);
}

module base_body() {
    cube([body_w, body_d, body_h], center=true);
}

module base_leg() {
    cube([leg_w, leg_d, leg_h], center=true);
}

module pixelated_creeper() {
    difference() {
        union() {
            color(creeper_color) {
                translate([0, 0, 21]) base_head();
                translate([0, 0, 10]) base_body();
                translate([-2.1, 3, 1.5]) base_leg();
                translate([2.1, 3, 1.5]) base_leg();
                translate([-2.1, -3, 1.5]) base_leg();
                translate([2.1, -3, 1.5]) base_leg();
            }
            
            // Additive Noise
            apply_surface_noise([90, 0, 0], [0, -body_d/2, 10], body_w, body_h, 201, "add");
            apply_surface_noise([-90, 0, 0], [0, body_d/2, 10], body_w, body_h, 202, "add");
            apply_surface_noise([0, -90, 0], [-body_w/2, 0, 10], body_h, body_d, 203, "add");
            apply_surface_noise([0, 90, 0], [body_w/2, 0, 10], body_h, body_d, 204, "add");
            apply_surface_noise([0, 0, 0], [0, 0, 10 + body_h/2], body_w, body_d, 205, "add");
            
            for (p = [[-2.1, 3, 1.5], [2.1, 3, 1.5], [-2.1, -3, 1.5], [2.1, -3, 1.5]]) {
                translate(p) {
                    apply_surface_noise([90, 0, 0], [0, -leg_d/2, 0], leg_w, leg_h, 301, "add");
                    apply_surface_noise([-90, 0, 0], [0, leg_d/2, 0], leg_w, leg_h, 302, "add");
                    apply_surface_noise([0, -90, 0], [-leg_w/2, 0, 0], leg_h, leg_d, 303, "add");
                    apply_surface_noise([0, 90, 0], [leg_w/2, 0, 0], leg_h, leg_d, 304, "add");
                    apply_surface_noise([0, 0, 0], [0, 0, leg_h/2], leg_w, leg_d, 305, "add");
                }
            }
        }
        
        // Subtractive Noise
        apply_surface_noise([90, 0, 0], [0, -body_d/2, 10], body_w, body_h, 501, "sub");
        apply_surface_noise([-90, 0, 0], [0, body_d/2, 10], body_w, body_h, 502, "sub");
        apply_surface_noise([0, -90, 0], [-body_w/2, 0, 10], body_h, body_d, 503, "sub");
        apply_surface_noise([0, 90, 0], [body_w/2, 0, 10], body_h, body_d, 504, "sub");
        apply_surface_noise([0, 0, 0], [0, 0, 10 + body_h/2], body_w, body_d, 505, "sub");

        for (p = [[-2.1, 3, 1.5], [2.1, 3, 1.5], [-2.1, -3, 1.5], [2.1, -3, 1.5]]) {
            translate(p) {
                apply_surface_noise([90, 0, 0], [0, -leg_d/2, 0], leg_w, leg_h, 601, "sub");
                apply_surface_noise([-90, 0, 0], [0, leg_d/2, 0], leg_w, leg_h, 602, "sub");
                apply_surface_noise([0, -90, 0], [-leg_w/2, 0, 0], leg_h, leg_d, 603, "sub");
                apply_surface_noise([0, 90, 0], [leg_w/2, 0, 0], leg_h, leg_d, 604, "sub");
                apply_surface_noise([0, 0, 0], [0, 0, leg_h/2], leg_w, leg_d, 605, "sub");
            }
        }

        // Recessed face
        translate([0, -head_size/2 - 0.1, 21]) {
            color(face_color) {
                translate([-2, 0, 2]) cube([2, 0.5, 2], center=true);
                translate([2, 0, 2]) cube([2, 0.5, 2], center=true);
                translate([0, 0, 0]) cube([2, 0.5, 4], center=true);
                translate([-2, 0, -2]) cube([2, 0.5, 3], center=true);
                translate([2, 0, -2]) cube([2, 0.5, 3], center=true);
            }
        }
    }
}

pixelated_creeper();
