// Minecraft Creeper Model - Final Proportions, Printability, and Leg Spacing

// Parameters
head_size = 8;
body_w = 8;    // Width (X) matches head
body_d = 4;    // Depth (Y)
body_h = 16;   // Increased height
leg_w = 4;     // Requested width
leg_d = 4;     // Match body depth
leg_h = 3;     // Requested height

face_color = "black";
creeper_color = "green";

module head() {
    union() {
        color(creeper_color)
        cube([head_size, head_size, head_size], center=true);
        
        translate([0, -head_size/2, 0]) {
            color(face_color) {
                translate([-2, -0.1, 2])
                    cube([2, 0.2, 2], center=true);
                translate([2, -0.1, 2])
                    cube([2, 0.2, 2], center=true);
                translate([0, -0.1, 0])
                    cube([2, 0.2, 4], center=true);
                translate([-2, -0.1, -2])
                    cube([2, 0.2, 3], center=true);
                translate([2, -0.1, -2])
                    cube([2, 0.2, 3], center=true);
            }
        }
    }
}

module body() {
    color(creeper_color)
    cube([body_w, body_d, body_h], center=true);
}

module leg() {
    color(creeper_color)
    cube([leg_w, leg_d, leg_h], center=true);
}

// Assembly
union() {
    // Head: center at z=21
    translate([0, 0, 21]) 
        head();
    
    // Body: center at z=10
    translate([0, 0, 10]) 
        body();
    
    // Legs: center at z=1.5
    // Range: [0, 3]
    // Z-Overlap with body: [2, 3] (1 unit)
    
    // Position legs at X= +/- 2.1 to create a visible gap between left/right
    // Position legs at Y= +/- 3 to create a visible gap between front/back
    // Body Y range: [-2, 2]. 
    // Leg Y range at 3: [1, 5] -> Overlap [1, 2] (1 unit)
    // Leg Y range at -3: [-5, -1] -> Overlap [-2, -1] (1 unit)
    
    // Front Left
    translate([-2.1, 3, 1.5])
        leg();
    // Front Right
    translate([2.1, 3, 1.5])
        leg();
    // Back Left
    translate([-2.1, -3, 1.5])
        leg();
    // Back Right
    translate([2.1, -3, 1.5])
        leg();
}
