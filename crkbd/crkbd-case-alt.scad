///////////////////////////////////////////////////
// Simple Tented Corne Keyboard case (alternate layout)
//
// * Simple top plate (no sides)
// * Single piece combined bottom/hi-profile sides/tent supports
// * Supports a bottom battery cutout/housing for LiPo
//
///////////////////////////////////////////////////

include <crkbd-common.scad>
include <../keyboard-case.scad>

theme = 3;
nrfmicro = false;   // If true, make adjustments for nrfmicro and small lipo battery, rather than pro micro.
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
    translate(crkbd_center_offset) render() crkbd_top_case();
    //%translate([0, 0, plate_thickness + -7 * explode]) key_holes(left_keys, "keycap");

} else if (part == "bottom") {
    //rotate([180, 0, 90]) translate([0, 0, -plate_thickness])
    translate(crkbd_center_offset) crkbd_bottom_case();

} else if (part == "battery_cover") {
    rotate([180, 0, 0]) translate([-7, -35, 0])
    crkbd_battery_cover();

} else if (part == "assembly") difference(convexity=10) {
    union() {
        translate(crkbd_center_offset)
        translate([0, 0, -plate_thickness]) {
            %translate([0, 0, plate_thickness - (depressed ? 4 : 0) + 30 * explode]) key_holes(left_keys, "keycap");
            %translate([0, 0, plate_thickness + 20 * explode]) key_holes(left_keys, "switch");
            crkbd_top_case();
            %translate([0, 0, -2.5 - 5 * explode]) crkbd_pcb_assembly();
            translate([0, 0, -bottom_case_height - (20 * explode)]) crkbd_bottom_case();
            if (nrfmicro) {
                translate([126, -94, -bottom_case_height - 28 * explode]) crkbd_battery_cover();
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
