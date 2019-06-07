// http://www.keyboard-layout-editor.com/#/gists/62e7fc79758227cd0ca7efae1afebd99
include <kle/crkbd-layout.scad>
include <../keyboard-case.scad>

theme = 3;
wall_thickness = 2.5;
plate_thickness = 3.2;   // (5mm - max diode height)
depth_offset = 5 + 2 + 2;       // How much of side wall to include below top plate
bottom_case_height = 5 + 2 + 2; // 11;  // Enough room to house electonics
screw_rad = 2.2 / 2;
tent_attachment_width = 16;
micro_usb_hole_width = 14;
micro_usb_hole_height = 8;

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

crkbd_tent_positions = [
    // [[X, Y], Angle, height]
    [[4.8, -32.2], 180, depth_offset],
    [[4.8, -77.0], 180, depth_offset],
    [[115.5, -19.4], 90, depth_offset + plate_thickness],
    [[140, -102], -30, depth_offset + plate_thickness],
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
module crkbd_expand_profile(expand = 4) {
    offset(r = expand, chamfer = false, $fn = 40)
    offset(delta = 1, chamfer = false, $fn = 40) // Delta gives sharp interiors
    children();
}
module crkbd_outer_profile(expand = 4) {
    crkbd_expand_profile(expand)
    crkbd_left_bottom();
}

module simple_micro_usb_hole(hole = true) {
    color("silver") {
        if (hole) {
            translate([0, 1, pcb_thickness+micro_usb_socket_height/2]) rotate([90, 0, 0]) roundedcube([micro_usb_hole_width, micro_usb_hole_height, 10], r=1.5, center=true, $fs=1);
        }
    }
}
module simple_trrs_hole(hole = true) {
    color("silver") {
        if (hole) {
            translate([0, 1, pcb_thickness+micro_usb_socket_height/2]) rotate([90, 0, 0])
                roundedcube([micro_usb_hole_width, micro_usb_hole_height, 10], r=1.5, center=true, $fs=1);
        }
    }
}

module crkbd_case_holes(preview = false) {
    // Case holes for connectors etc. The second version of each is just for preview view
    pcb_offset = plate_thickness - cherry_switch_depth - pcb_thickness;
    // pcb_offset is nominally bottom of crkbd PCB
    translate([133.5, -25.1, pcb_offset]) translate([0, 0, 2 * pcb_thickness]) {
        simple_micro_usb_hole();
        if (preview) {
            %simple_micro_usb_hole(hole = false);
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
        %color("green") translate([0, 0, plate_thickness - cherry_switch_depth - pcb_thickness])
            linear_extrude(height = pcb_thickness, center = false, convexity = 3) crkbd_left_bottom();
    }
}

module crkbd_top_case(raised = raised) {
    difference() {
        top_case(left_keys, crkbd_screw_holes, chamfer_faces = true, chamfer_height = raised ? 5 : 2, chamfer_width = 2, raised = raised, tent_positions = crkbd_tent_positions)
            crkbd_outer_profile(raised ? 3 : 2);
        translate([0, 0, 0]) crkbd_case_holes(true);
        translate([0, 0, -1]) linear_extrude(height = 30, center = false, convexity = 3) 
            //offset(delta = 1, chamfer = false, $fn = 20) // Delta gives sharp interiors
            difference() {
            crkbd_left_top_window();
            // Ensure some removable supports
            for (y = [-31, -47, -65]) translate([100, y]) square([100, 1.2], center = false);

        }
    }
}

module crkbd_bottom_case(raised = raised) {
    difference() {
        color(case_color) linear_extrude(height = wall_thickness, center = false, convexity = 3) crkbd_left_bottom();
        translate([0, 0, -wall_thickness]) screw_positions(crkbd_screw_holes) polyhole(r = screw_rad / 2, h = 50);
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
explode = 0.5;
depressed = true;
raised = false;

if (part == "outer") { // To preview the outer profile, key hole, and screw hole positions
    /* offset(r = -2.5) // Where top of camber would come to */
    color("gray") translate([0, 0, -5.1]) crkbd_left_bottom();
    translate([0, 0, -5]) crkbd_left_top();
    translate([0, 0, -5]) crkbd_left_top_window();
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
    rotate([180, 0, 90]) translate([0, 0, -plate_thickness]) translate([-80, 60, 0])
        crkbd_bottom_case();

} else if (part == "carrier") {
    rotate([0, 0, 90]) translate([-80, 60, 0])
    crkbd_carrier();

} else if (part == "carrier-door") {
    tol = 0.3; // Tolerance to allow door to slide in the hole, adjust as needed.
    translate([-20, 0, door_thickness / 2 -  tol])
    rotate([0, 90, 0])
        crkbd_carrier_door(offset = -tol, scoop = true);

} else if (part == "assembly") translate([-80, 60, 0]) {
    %translate([0, 0, plate_thickness - (depressed ? 4 : 0) + 30 * explode]) key_holes(left_keys, "keycap");
    %translate([0, 0, plate_thickness + 20 * explode]) key_holes(left_keys, "switch");
    crkbd_top_case();
    %color("white") translate([0, 0, -bottom_case_height - (20 * explode)]) crkbd_bottom_case();
}


// Requires my utility functions in your OpenSCAD lib or as local submodule
// https://github.com/Lenbok/scad-lenbok-utils.git
use<../Lenbok_Utils/utils.scad>
