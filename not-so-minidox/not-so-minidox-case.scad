include <keyboard-case.scad>
include <kle-examples/not-so-minidox-layout.scad>

$fa = 1;
$fs = $preview ? 8 : 2;
bezier_precision = $preview ? 0.1 : 0.025;

// Hacky way to select just the left hand keys from a split layout
left_keys = [ for (i = not_so_minidox_layout) if (key_pos(i).x < 8) i ];

///////////////////////////////////////////////////
// Not-so-minidox-ish case with bezier based curved outlines
///////////////////////////////////////////////////

pos_x0 = 72.1;
pos_y0 = -82.2;
pos_x1 = 5.5;
pos_y1 = -22.05;
pos_y1b = -21.3;
pos_x2 = 128.3;
pos_x3 = 148.3;
pos_y3 = -79.95;
pos_x6 = 131.0;
pos_y6 = -110.0;
pos_x4 = 132.8;
pos_y4 = -106.8;
pos_x5 = 118.65;

not_so_minidox_reference_points = [
    [pos_x0-1, pos_y0-3],     // Bottom mid
    [pos_x1, pos_y0-5],       // Bottom left
    [pos_x1, pos_y1],         // Top left
    [pos_x2, pos_y1b],        // Top right
    [pos_x3+2, pos_y3-6.5],    // Right
    [pos_x6+5, pos_y6],        // Screw
    [pos_x4+5, pos_y4],        // Bottom
    [pos_x5+5, pos_y4],        // Screw
    ];

not_so_minidox_screw_holes = [
    [pos_x1+23.2, pos_y0+18.2],           // Bottom left, under caps
    [pos_x1+23.2, pos_y1-5.5],       // Top left
    [pos_x2-6.5,  pos_y3+36.6],   // Top right, under caps
    [pos_x6-1.5, pos_y6+0.9],      // Right, under caps
    ];

not_so_minidox_tent_positions = [ ];

      /* CONTROL              POINT                       CONTROL      */
bzVec = [                     [pos_x1, pos_y1],            OFFSET([30, 0]), // Top left
         OFFSET([-25, -1]),   [71, -14.5],                     OFFSET([25, 0]), // Top
         POLAR(5, 140),       [pos_x2, pos_y1b],           SHARP(), // Top right
         POLAR(28, 168),      [pos_x3+2, pos_y3-6.5],      SHARP(), // Right
         // Skip screw
         SHARP(),             [pos_x4-1.5, pos_y4-12.5],  POLAR(30, 145), // Bottom right
         POLAR(19, 0),        [pos_x0, pos_y0-17-5],      SHARP(), // Bottom mid
         SHARP(),             [pos_x0, pos_y0-5.5],         SHARP(), // Bottom left
         SHARP(),             [pos_x1, pos_y0-5.5],         SHARP(), // Bottom left
         SHARP(),             [pos_x1, pos_y1],  // To top left
    ];
b1 = Bezier(bzVec, precision = bezier_precision);

module not_so_minidox_outer_profile(expand = 4) {
    //offset(r = 5, chamfer = false, $fn = 20) // Purposely slightly larger than the negative offset below
    offset(r = expand, chamfer = false, $fn = 20)
        offset(delta = -4.5, chamfer = false, $fn = 20) // Delta gives sharp interiors
        polygon(b1);
}

module not_so_minidox_case_holes(preview = false) {
        // Case holes for connectors etc. The second version of each is just
        // For preview view
        translate([35, -30.25, 0.05]) rotate([0, 0, 10.3]) {
            reset_microswitch();
            if (preview) {
                %reset_microswitch(hole = false);
            }
        }
        translate([17.3, -25.1, 0]) rotate([0, 0, 4]) {
            micro_usb_hole();
            if (preview) {
                %micro_usb_hole(hole = false);
            }
        }
        //translate([106, -20, 0]) rotate([0, 0, -7.2]) {
        translate([127.3, -60, 0]) rotate([0, 0, -76.5]) {
            mini_usb_hole();
            if (preview) {
                %mini_usb_hole(hole = false);
            }
        }
}

module not_so_minidox_top_case(raised = raised) {
    difference() {
        top_case(left_keys, not_so_minidox_screw_holes, chamfer_faces = true, chamfer_height = raised ? 5 : 2, chamfer_width = 2.5, raised = raised, standoffs = true)
            not_so_minidox_outer_profile(raised ? 4 : 2);
        translate([0, 0, -bottom_case_height]) translate([0, 0, wall_thickness + 0.01])
            not_so_minidox_case_holes();
    }
}
module not_so_minidox_bottom_case(raised = raised) {
    difference() {
        bottom_case(not_so_minidox_screw_holes, not_so_minidox_tent_positions, chamfer_faces = true, chamfer_height = 2) not_so_minidox_outer_profile(raised ? 4 : 2);
        translate([0, 0, wall_thickness + 0.01])
        not_so_minidox_case_holes(true);
    }
}

part = "assembly";
explode = 1;
depressed = true;
raised = false;
if (part == "outer") {
    BezierVisualize(bzVec);
    offset(r = -2.5) // Where top of camber would come to
        not_so_minidox_outer_profile();
    for (pos = not_so_minidox_screw_holes) {
        translate(pos) {
            polyhole2d(r = 3.2 / 2);
        }
    }
    #key_holes(left_keys);
    
} else if (part == "top") {
    not_so_minidox_top_case();
    //%translate([0, 0, plate_thickness + -7 * explode]) key_holes(left_keys, "keycap");

} else if (part == "bottom") {
    not_so_minidox_bottom_case();

} else if (part == "assembly") {
    %translate([0, 0, plate_thickness - (depressed ? 4 : 0) + 30 * explode]) key_holes(left_keys, "keycap");
    %translate([0, 0, plate_thickness + 20 * explode]) key_holes(left_keys, "switch");
    not_so_minidox_top_case();
    translate([0, 0, -bottom_case_height -20 * explode]) not_so_minidox_bottom_case();
}


// Requires my utility functions in your OpenSCAD lib or as local submodule
// https://github.com/Lenbok/scad-lenbok-utils.git
use<Lenbok_Utils/utils.scad>
// Requires bezier library from https://www.thingiverse.com/thing:2207518
use<Lenbok_Utils/bezier.scad>
