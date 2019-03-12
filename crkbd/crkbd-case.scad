// http://www.keyboard-layout-editor.com/#/gists/62e7fc79758227cd0ca7efae1afebd99
include <kle/crkbd-layout.scad>
include <../keyboard-case.scad>

unit = 19.02;
scaletweak = (unit / 19.05);

theme = 3;
wall_thickness = 2.5;
plate_thickness = 3.2;   // 5mm - max diode height
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
// Not-so-minidox-ish case with bezier based curved outlines
///////////////////////////////////////////////////

pos_x1 = 28.55;
pos_x2 = 72.0;
pos_x3 = 148.3;
pos_y3 = -79.95;
pos_x6 = 131.0;
pos_y6 = -110.0;
pos_x4 = 132.8;
pos_y4 = -106.8;
pos_x5 = 118.65;

crkbd_screw_holes = [
    scaletweak * [pos_x1, -64.4],           // Bottom left
    scaletweak * [pos_x1, -45.3],           // Top left
    scaletweak * [72.0,  -81.6],          // Bottom mid
    scaletweak * [104.89,  -41.7],             // Top right
    scaletweak * [118.7,  -89.37],          // Bottom right
    ];

crkbd_tent_positions = [
    // [[X, Y], Angle, height]
    [[scaletweak * 4.8, scaletweak * -32.2], 180, depth_offset],
    [[scaletweak * 4.8, scaletweak * -77.0], 180, depth_offset],
    [[scaletweak * 115.5, scaletweak * -19.4], 90, depth_offset + plate_thickness],
    [[scaletweak * 140, scaletweak * -102], -30, depth_offset + plate_thickness],
    ];

// This is so annoying, the SVG had the wrong scale
svg_scale=0.755*scaletweak;
module crkbd_left_top() {
    scale([svg_scale, svg_scale, 0]) 
    translate([6, -139.5]) 
    import(file = "orig/crkbd-left-top.svg");
}
module crkbd_left_top_window() {
    scale([svg_scale, svg_scale, 0]) 
    translate([2, -99.3]) 
    import(file = "orig/crkbd-left-top-window.svg");
}
module crkbd_left_bottom() {
    scale([svg_scale, svg_scale, 0]) 
    translate([5.9, -142.8]) 
    import(file = "orig/crkbd-left-bottom.svg");
}
module crkbd_outer_profile(expand = 4) {
    //offset(r = 5, chamfer = false, $fn = 20) // Purposely slightly larger than the negative offset below
    offset(r = expand, chamfer = false, $fn = 20)
    /*     offset(delta = -4.5, chamfer = false, $fn = 20) // Delta gives sharp interiors */
    offset(delta = 1, chamfer = false, $fn = 20) // Delta gives sharp interiors
    crkbd_left_bottom();
}

module crkbd_case_holes(preview = false) {
    // Case holes for connectors etc. The second version of each is just for preview view
    pcb_offset = plate_thickness - cherry_switch_depth - pcb_thickness;
    // pcb_offset is nominally bottom of crkbd PCB
           translate([135, -25.1, pcb_offset]) translate([0, 0, 2 * pcb_thickness]) {
        micro_usb_hole();
        if (preview) {
            %micro_usb_hole(hole = false);
        }
    }
    // TRRS connector - should update to a better shape hole
    translate([145, -73.5, pcb_offset]) translate([0, 0, 2 * pcb_thickness]) rotate([0, 0, -90]) {
        micro_usb_hole();
        if (preview) {
            %micro_usb_hole(hole = false);
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
        translate([0, 0, 0]) crkbd_case_holes();
        translate([0, 0, -1]) linear_extrude(height = 30, center = false, convexity = 3) 
            //offset(delta = 1, chamfer = false, $fn = 20) // Delta gives sharp interiors
            crkbd_left_top_window();
    }
}
module crkbd_bottom_case(raised = raised) {
    difference() {
        color(case_color) linear_extrude(height = wall_thickness, center = false, convexity = 3) crkbd_left_bottom();
        translate([0, 0, -wall_thickness]) screw_positions(crkbd_screw_holes) polyhole(r = screw_rad / 2, h = 50);
    }
}


part = "top";
explode = 0;
depressed = true;
raised = false;

if (part == "outer") {
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
    rotate([180, 0, 0]) 
        translate([-80, 60, -plate_thickness])
        render() crkbd_top_case();
    //%translate([0, 0, plate_thickness + -7 * explode]) key_holes(left_keys, "keycap");

} else if (part == "bottom") {
    crkbd_bottom_case();

} else if (part == "assembly") {
    %translate([0, 0, plate_thickness - (depressed ? 4 : 0) + 30 * explode]) key_holes(left_keys, "keycap");
    %translate([0, 0, plate_thickness + 20 * explode]) key_holes(left_keys, "switch");
    crkbd_top_case();
    %color("white") translate([0, 0, -bottom_case_height - (20 * explode)]) crkbd_bottom_case();
}


// Requires my utility functions in your OpenSCAD lib or as local submodule
// https://github.com/Lenbok/scad-lenbok-utils.git
use<../Lenbok_Utils/utils.scad>
// Requires bezier library from https://www.thingiverse.com/thing:2207518
use<../Lenbok_Utils/bezier.scad>
