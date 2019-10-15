// http://www.keyboard-layout-editor.com/#/gists/62e7fc79758227cd0ca7efae1afebd99
include <kle/crkbd-layout.scad>
include <../keyboard-case.scad>

theme = 3;
nrfmicro = true;   // If true, make adjustments for nrfmicro and small lipo battery, rather than pro micro.
wall_thickness = 2.5;
plate_thickness = 4;   // (5mm - max diode height)
depth_offset = 6;       // Distance from bottom of plate to top of stand-offs
top_case_raised_height = 7; // Distance between plate and bottom of keycap plus a little extra, for raised top case
bottom_case_height = 8.2 - plate_thickness + 2 + 2;

screw_rad = 2.2 / 2;
screw_head_rad = 5.4 / 2;
//screw_head_depth = 1.5;
screw_head_depth = 0;

//standoff_rad = 4.0 / 2;
bottom_screws = true; // Default is to screw down from the top

tent_attachment_width = 15.9;

trrs_hole_width = 12;
trrs_hole_height = 8;
micro_usb_hole_width = 14;
micro_usb_hole_height = 8;
cherry_clip_recess_height = 2.0; // How far down clip recess go, just go for the minimal
keycap_depth_offset = 6.6;  // Distance from bottom of keycap to top of plate.

$fa = 1;
$fs = $preview ? 8 : 2;
bezier_precision = $preview ? 0.1 : 0.025;

// Hacky way to select just the left hand keys from a split layout
left_keys = [ for (i = crkbd_layout) if (key_pos(i).x < 8) i ];

///////////////////////////////////////////////////
// Simple Tented Corne Keyboard case
///////////////////////////////////////////////////

pos_x1 = 28.55;
crkbd_screw_holes = [
    [pos_x1, -64.4],           // Bottom left
    [pos_x1, -45.3],           // Top left
    [72.0, -81.6],          // Bottom mid
    [104.89, -41.7],             // Top right
    [118.7, -89.37],          // Bottom right
    ];

tent_x1 = 14.0;
crkbd_tent_positions = [
    // [[X, Y], Angle, height]

    // Both supports against on left edge
    // [[4.8, -32.2], 180, 9, 3.2], // Top left
    // [[4.8, -77.0], 180, 9, 3.2], // Bottom left

    // Supports against top and bottom edges (lets the left edge be closer to desk)
    [[tent_x1, -22.2], 90, 9, 3.2],  // Top left
    [[tent_x1, -87.0], -90, 9, 3.2], // Bottom left

    [[115.5, -19.4], 90, 12.2], // Top right
    [[140, -102], -30, 12.2],   // Bottom right
    ];

// This is so annoying, the SVG had the wrong scale, but direct import from the foostan dxf files didn't work.
svg_scale=0.755;
module crkbd_left_top() {
    scale([svg_scale, svg_scale, 0]) 
    translate([12, -129.5])
    import(file = "orig/crkbd-left-top.svg");
}
module crkbd_left_top_window() {
    scale([svg_scale, svg_scale, 0]) 
    translate([163, -83.3])
    import(file = "orig/crkbd-left-top-window.svg");
}
module crkbd_left_bottom() {
    scale([svg_scale, svg_scale, 0]) 
    translate([11.9, -136.8])
    import(file = "orig/crkbd-left-bottom.svg");
}
module crkbd_left_bottom_mod() {
    scale([svg_scale, svg_scale, 0]) 
    translate([11.9, -136.8])
    import(file = "orig/crkbd-left-bottom-mod.svg");
}
module crkbd_expand_profile(expand = 4) {
    offset(r = expand, chamfer = false, $fn = 40)
    offset(delta = 1.25, chamfer = false, $fn = 40) // Delta gives sharp interiors
    children();
}
module crkbd_outer_profile(expand = 4) {
    crkbd_expand_profile(expand)
    crkbd_left_bottom();
}

module pro_micro_usb_hole(hole = true) {
    // For nrfmicro make the hole taller to access the power switch
    micro_usb_hole_height = micro_usb_hole_height + (nrfmicro ? 4 : 0);
    pro_micro_usb_z_offset = pcb_thickness + micro_usb_socket_height / 2;
    pro_micro_pcb = [18.5, 34, pcb_thickness];
    color("#333333") translate([0, -18, pcb_thickness/2]) cube(pro_micro_pcb, center = true);
    color("silver") translate([0, 1, pro_micro_usb_z_offset]) rotate([90, 0, 0]) {
        translate([0, 0, 5]) cube([7.5, micro_usb_socket_height, 7], center = true, $fs = 1);
        if (hole) {
            roundedcube([micro_usb_hole_width, micro_usb_hole_height, 10], r=1.5, center=true, $fs=1);
        }
    }
}
module simple_trrs_hole(hole = true) {
    trrs_rad = 3.5 / 2;
    trrs_z_offset = trrs_rad + 1; // From top of pcb to center of TRRS
    color("#333333") translate([0, 1, trrs_z_offset]) rotate([90, 0, 0]) {
        translate([0, 0, 7]) difference() {
            roundedcube([trrs_z_offset * 2+1, trrs_z_offset * 2, 14], r=1.5, center=true, $fs=1);
            cylinder(r=trrs_rad, h = 15, center=true, $fn = 8);
        }
        if (hole) {
            roundedcube([trrs_hole_width, trrs_hole_height, 10], r=1.5, center=true, $fs=1);
        }
    }
}

// Case holes for connectors etc. The second version of each hole is just for preview view
module crkbd_case_holes(preview = false) {
    // pcb_offset is nominally bottom of crkbd PCB
    pcb_offset = plate_thickness - cherry_switch_depth - pcb_thickness;
    pro_micro_offset = 4; // Height of socket into which pro micro sits
    translate([133.5, -25.4, pcb_offset]) translate([0, 0, pcb_thickness + pro_micro_offset]) {
        pro_micro_usb_hole();
        if (preview) {
            %pro_micro_usb_hole(hole = false);
        }
    }
    // TRRS connector - should update to a better shape hole
    translate([145, -74.5, pcb_offset]) translate([0, 0, pcb_thickness]) rotate([0, 0, -90]) {
        simple_trrs_hole();
        if (preview) {
            %simple_trrs_hole(hole = false);
        }
    }
    if (preview) {
        %color("green") translate([0, 0, pcb_offset])
            linear_extrude(height = pcb_thickness, center = false, convexity = 3) crkbd_left_bottom();
    }
}

module crkbd_top_case() {
    top_plate(left_keys, crkbd_screw_holes) crkbd_left_top();
}


nrf_battery_size = [15, 67, 8.5];
module crkbd_bottom_case() {
    difference() {
        bottom_case(crkbd_screw_holes, tent_positions = crkbd_tent_positions, raised = true, chamfer_faces = [false, true], chamfer_height = 1.5, chamfer_width = 1.5)
            crkbd_outer_profile(2);
        translate([0, 0, bottom_case_height]) {
            crkbd_case_holes(false);
            if (nrfmicro) {
                // Hole for lipo battery
                translate([126, -94, -12]) {
                    roundedcube(nrf_battery_size, center = false);
                    translate(nrf_battery_size/2)
                        crkbd_battery_cover_screw_positions()
                        bolthole(r1=screw_head_rad, r2=screw_rad - 0.4, h1=5, h2=screw_length);
                }
            }
        }
    }
    //translate([126, -94, bottom_case_height - 8]) crkbd_battery_cover();
}

battery_cover_tab_width = 8 - wall_thickness;
battery_cover_tab_separation = 40;
module crkbd_battery_cover_screw_positions() {
        for (i = [-1,1], j = [-1, 1]) translate([j * (nrf_battery_size.x + 4) / 2, i * battery_cover_tab_separation/2, -5 - 2.5])
                                          children();
}
module crkbd_battery_cover() {
    top_size = [nrf_battery_size.x, nrf_battery_size.y];
    bottom_offset = nrf_battery_size.x / 6;
    bottom_size = [nrf_battery_size.x - 2 * bottom_offset, nrf_battery_size.y - 2 * bottom_offset];
    cover_height = 4;
    translate(top_size/2) difference() {
        union() {
            hull() {
                linear_extrude(height = 0.01) offset(r = wall_thickness) square(top_size, center = true);
                translate([0, 0, -cover_height - wall_thickness]) linear_extrude(height = 0.01) offset(r = wall_thickness) square(bottom_size, center = true);
            }
            for (i = [-1,1]) translate([0, i*battery_cover_tab_separation/2]) hull() {
                linear_extrude(height = 0.01) offset(r = wall_thickness) square([top_size.x+8, battery_cover_tab_width], center = true);
                translate([0, 0, -cover_height - wall_thickness]) linear_extrude(height = 0.01) offset(r = wall_thickness) square([bottom_size.x, battery_cover_tab_width], center = true);
            }
        }
        hull() {
            linear_extrude(height = 0.012) square(top_size, center = true);
            translate([0, 0, -cover_height]) linear_extrude(height = 0.01) square(bottom_size, center = true);
        }
        crkbd_battery_cover_screw_positions() bolthole(r1=screw_head_rad, r2=screw_rad, h1=5, h2=screw_length);
    }
}

holder_offset = [9.685, -112.5, 0];
module crkbd_holder_profile() {
    translate(holder_offset) square([119.7, 30], center = false);
}

module crkbd_carrier_profile(expand = 4, holder = false) {
    crkbd_outer_profile(expand);
    crkbd_expand_profile(expand) {
        // Space for magnetic micro usb plug
        translate([129, -33.3]) square([11, 10], center = false);
        // Compartment for cables, tent legs etc
        if (holder) {
            crkbd_holder_profile();
        }
    }
}

module crkbd_carrier_inset() {
    tolerance = 0.3;
    for (m = [0, 1]) mirror([0, 0, m]) translate([0, 0, -3.5]) difference() {
        render() chamfer_extrude(height = 4, chamfer = 2, width = 2, faces = [false, false], $fn = 25)
            difference() {
            crkbd_outer_profile(2 + tolerance + 0.1);
            crkbd_outer_profile(tolerance);
        }
        translate([0, 0, -1.5]) render() chamfer_extrude(height = 5, chamfer = 2, width = 2, faces = [false, true], $fn = 25)
            crkbd_outer_profile(2 + tolerance);
        translate([127, -30.3, -5]) cube([18, 10, 10], center = false);
        translate([140, -83.5, -5]) cube([10, 18, 10], center = false);

   }
}

door_thickness = 4.2;
module crkbd_carrier_door(offset = 0, scoop = false) {
    dth = door_thickness * 0.707;
    door_length = 50 + offset;
        difference() {
        linear_extrude(height = door_length) {
            offset(delta = offset, chamfer = false) 
            hull() {
                for (i = [-1, 1]) translate([0, i*10]) rotate([0, 0, 45]) square(dth, center = true);
            }
        }
        if (scoop) {
            thumb_r = 8;
            translate([-door_thickness / 2, 0, 5]) difference() {
                scale([2.5/thumb_r, 1, 1])  sphere(r = thumb_r, $fn = 20);
                translate([-100, -100, -100])  cube([200, 200, 100], center = false);
            }
            for (i = [-1, 1]) translate([0, i * (10 + door_thickness / 2), door_length])
            rotate([0, 90, 0]) rotate([0, 0, 45]) cube([dth, dth, 10], center = true);
        }
    }
}
// A simple carrier that accepts both keyboard halves and protects the keys.
// Could be extended with latches and a space to keep cables.
module crkbd_carrier() {
    tolerance = 0.4;
    case_thickness = 4;
    separation = 17; // key height. 15mm min, maybe allow extra for cables or tall keycaps
    tot_height = bottom_case_height + plate_thickness;
    case_height = 2 * (separation + tot_height);
    translate([0, 0, tot_height]) difference() {
        translate([0, 0, separation]) for (m = [0, 1]) mirror([0, 0, m]) translate([0, 0, -separation]) difference() {
                // Main outer profile less main hole for crkbd keyboard
                translate([0, 0, -tot_height])
                    linear_extrude(height = tot_height + separation, center = false, convexity = 3)
                    difference() {
                    crkbd_carrier_profile(2 + case_thickness + tolerance, true);
                    crkbd_carrier_profile(2 + tolerance);
                }
                // Hollow out leg storage compartment
                translate([0, 0, -tot_height + 2])
                    linear_extrude(height = tot_height + separation, center = false, convexity = 3)
                    difference() {
                    crkbd_expand_profile(2 + tolerance) crkbd_holder_profile();
                    crkbd_carrier_profile(2 + case_thickness + tolerance, false);
                }
                // Slots for tent supports
                translate([0, 0, -tot_height/2-0.1]) for(tent = crkbd_tent_positions) {
                    tent_position = tent[0];
                    tent_angle = tent[1];
                    tent_height = tent[2];
                    translate([tent_position.x, tent_position.y, 0]) rotate([0, 0, tent_angle]) {
                        hull() {
                            translate([-2.5, 0, 0]) cube([0.1, tent_attachment_width, tot_height], center = true);
                            translate([10, 0, 0]) cube([0.1, tent_attachment_width*0.8, tot_height], center = true);
                        }
                    }
                }
            }
        translate(holder_offset - [5.45, -10, bottom_case_height + plate_thickness + 0.1])
        crkbd_carrier_door();
    }
    //translate([0, 0, 0]) render() crkbd_carrier_inset();
//            translate(holder_offset-[6, 10, 0]) cube([39, 20, 50], center = false);
}


part = "assembly";
explode = 0.0;
cross_section = false;
depressed = false;

if (part == "outer") { // To preview the outer profile, key hole, and screw hole positions
    /* offset(r = -2.5) // Where top of camber would come to */
    color("gray") translate([0, 0, -7.1]) crkbd_expand_profile(2) crkbd_left_bottom_mod();
    color("blue") translate([0, 0, -5.1]) crkbd_left_bottom_mod();
    translate([0, 0, -5]) crkbd_left_top();
    //translate([0, 0, -5]) crkbd_left_top_window();
    color("black") for (pos = crkbd_screw_holes) {
        translate(pos) {
            circle(r = 2.5 / 2, $fn=20);
            //polyhole2d(r = 2.5 / 2);
        }
    }
    #key_holes(left_keys, "plate");
    
} else if (part == "top") {
    rotate([180, 0, 90]) translate([0, 0, -plate_thickness]) translate([-80, 60, 0])
        render() crkbd_top_case();
    //%translate([0, 0, plate_thickness + -7 * explode]) key_holes(left_keys, "keycap");

} else if (part == "bottom") {
    //rotate([180, 0, 90]) translate([0, 0, -plate_thickness])
            translate([-80, 60, 0])
        crkbd_bottom_case();

} else if (part == "battery_cover") {
    rotate([180, 0, 0]) translate([-7, -35, 0])
    crkbd_battery_cover();

} else if (part == "carrier") {
    rotate([0, 0, 90]) translate([-80, 60, 0])
    crkbd_carrier();

} else if (part == "carrier-door") {
    tol = 0.3; // Tolerance to allow door to slide in the hole, adjust as needed.
    translate([-20, 0, door_thickness / 2 -  tol])
    rotate([0, 90, 0])
        crkbd_carrier_door(offset = -tol, scoop = true);

} else if (part == "assembly") difference(convexity=10) {
    union() {
        translate([-80, 60, -plate_thickness]) {
            %translate([0, 0, plate_thickness - (depressed ? 4 : 0) + 30 * explode]) key_holes(left_keys, "keycap");
            %translate([0, 0, plate_thickness + 20 * explode]) key_holes(left_keys, "switch");
            crkbd_top_case();
            translate([0, 0, -bottom_case_height - (20 * explode)]) crkbd_bottom_case();
            if (nrfmicro) {
                translate([126, -94, -bottom_case_height - 8 * explode]) crkbd_battery_cover();
            }
        }
    }
    if (cross_section) {
        translate([50, -250, -250])  cube([400, 500, 500], center = false);
    }
}


// Requires my utility functions in your OpenSCAD lib or as local submodule
// https://github.com/Lenbok/scad-lenbok-utils.git
use<../Lenbok_Utils/utils.scad>
