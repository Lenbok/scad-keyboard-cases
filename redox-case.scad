include <kle-examples/redox-layout.scad>
include <keyboard-case.scad>

$fa = 1;
$fs = $preview ? 5 : 2;
bezier_precision = $preview ? 0.05 : 0.025;

// Hacky way to select just the left hand keys from split iris/redox layout
left_keys = [ for (i = key_layout) if (key_pos(i).x < 8) i ];

/////////////////////////////////////////
// Replicates the original Redox top case
// Sans holes for connectors, see the
// rev0b to see how to do that.
/////////////////////////////////////////
r0_x0 = 88.2;
r0_y0 = -100.8;
r0_x1 = 7.9;
r0_y1 = -1.45;
r0_x2 = 134.7;
r0_x3 = 169.2;
r0_y3 = -75.5;
r0_x6 = 154.32;
r0_y6 = -101.26;
r0_x4 = 145.0;
r0_y4 = -117.6;
r0_x5 = 118.65;
rev0_reference_points = [
    [r0_x0, r0_y0],
    [r0_x1, r0_y0],
    [r0_x1, r0_y1],
    [r0_x2, r0_y1],
    [r0_x3, r0_y3],
    [r0_x6, r0_y6],
    [r0_x4, r0_y4],
    [r0_x5, r0_y4],
    ];
rev0_screw_holes = [ for (p = rev0_reference_points) if (p.x != r0_x4) p];
rev0_tent_positions = [
    // [X, Y, Angle]
    [3.3, -89.0, 180],
    [3.3, -13, 180],
    [145.1, -13, 25],
    [155.7, -108, -30],
    ];
module rev0_outer_profile() {
    fillet(r = 5, $fn = 20)
        offset(r = 5, chamfer = false)
        polygon(points = rev0_reference_points, convexity = 3);
}
module rev0_top_case() {
    top_case(left_keys, rev0_screw_holes, raised = false) rev0_outer_profile();
}
module rev0_bottom_case() {
    bottom_case(rev0_screw_holes, rev0_tent_positions) rev0_outer_profile();
}

/////////////////////////////////////////////////
// Revised case with bezier based curved outlines
/////////////////////////////////////////////////
r0b_x0 = 88.2;
r0b_y0 = -100.8;
r0b_x1 = 0.9;
r0b_y1 = -3.45;
r0b_y1b = -13.45;
r0b_x2 = 146.7;
r0b_x3 = 169.2;
r0b_y3 = -75.5;
r0b_x6 = 154.32;
r0b_y6 = -101.26;
r0b_x4 = 145.0;
r0b_y4 = -117.6;
r0b_x5 = 118.65;
rev0b_reference_points = [
    [r0b_x0-1, r0b_y0-3],     // Bottom mid
    [r0b_x1, r0b_y0-5],       // Bottom left
    [r0b_x1, r0b_y1],         // Top left
    [r0b_x2, r0b_y1b],        // Top right
    [r0b_x3+2, r0b_y3-6.5],    // Right
    [r0b_x6+5, r0b_y6],        // Screw
    [r0b_x4+5, r0b_y4],        // Bottom
    [r0b_x5+5, r0b_y4],        // Screw
    ];
//rev0b_screw_holes = [ for (p = rev0b_reference_points) if (p.x != r0b_x4+5) p];
rev0b_screw_holes = [
    //[r0b_x1+5, r0b_y0],           // Bottom left
    [r0b_x1+26.5, r0b_y0+18.65],           // Bottom left, under caps

    //[r0b_x1+5, r0b_y1-5],       // Top left
    [r0b_x1+26.5, r0b_y1-6.5],       // Top left
    //[r0b_x1+44.5, r0b_y1-1],      // Top leftish

    //[r0b_x2-13.5, r0b_y1b+3],     // Top right
    [r0b_x2-6.5,  r0b_y3+40],   // Top right, under caps

    //[r0b_x2+4.5,  r0b_y3+7],     // Right
    [r0b_x6-1.5, r0b_y6+0.9],      // Right, under caps

    //[r0b_x5-35, r0b_y4+20],      // Bottom
    ];
rev0b_tent_positions = [
    // [X, Y, Angle]
    [0.8, -18, 180],
    [0.8, -91.0, 180],
    [146.8, -25, 5],
    [151.2, -117.3, -30],
    ];

      /* CONTROL              POINT                       CONTROL      */
bzVec = [                     [r0b_x1,r0b_y1],            OFFSET([30, 0]), // Top left
         OFFSET([-25, -1]),   [73,4],                     OFFSET([25, 0]), // Top
         POLAR(25, 140),      [r0b_x2,r0b_y1b],           SHARP(), // Top right
         POLAR(32, 153),      [r0b_x3+2,r0b_y3-6.5],      SHARP(), // Right
         // Skip screw
         SHARP(),             [r0b_x4-1.5, r0b_y4-12.5],  POLAR(82, 149), // Bottom right
         POLAR(18, 0),        [r0b_x0-41, r0b_y0-5],      POLAR(5, 180), // Bottom mid
         SHARP(),             [r0b_x1, r0b_y0-5],         SHARP(),
         SHARP(),             [r0b_x1, r0b_y1],
    ];
b1 = Bezier(bzVec, precision = bezier_precision);
module rev0b_outer_profile() {
    offset(r = 5, chamfer = false, $fn = 20) // Purposely slightly larger than the negative offset below
    offset(r = -4.5, chamfer = false, $fn = 20)
        polygon(b1);
}
module rev0b_top_case(raised = true) {
    top_case(left_keys, rev0b_screw_holes, chamfer_height = raised ? 5 : 2.5, chamfer_width = 2.5, raised = raised) rev0b_outer_profile();
}

module rev0b_bottom_case() {
    difference() {
        bottom_case(rev0b_screw_holes, rev0b_tent_positions) rev0b_outer_profile();

        // Case holes for connectors etc. The second version of each is just
        // For preview view
        translate([34, -8.45, 0.05]) rotate([0, 0, 8.8]) {
            reset_microswitch();
            %reset_microswitch(hole = false);
        }
        translate([13, -5.5, 0]) rotate([0, 0, 4]) {
            micro_usb_hole();
            %micro_usb_hole(hole = false);
        }
        translate([130.5, -7.5, 0]) rotate([0, 0, -24]) {
            mini_usb_hole();
            %mini_usb_hole(hole = false);
        }
    }
}

part = "assembly";
explode = 1;
if (part == "outer") {
    //BezierVisualize(bzVec);
    offset(r = -2.5) // Where top of camber would come to
        rev0b_outer_profile();
    for (pos = rev0b_screw_holes) {
        translate(pos) {
            polyhole2d(r = 3.2 / 2);
        }
    }
    #key_holes(left_keys);
    
} else if (part == "top0") {
    rev0_top_case();

} else if (part == "bottom0") {
    rev0_bottom_case();

} else if (part == "top0b-raised") {
    rev0b_top_case(true);
    
} else if (part == "top0b") {
    rev0b_top_case(false);

} else if (part == "bottom0b") {
    rev0b_bottom_case();

} else if (part == "assembly") {
    %translate([0, 0, plate_thickness + 30 * explode]) key_holes(left_keys, "keycap");
    %translate([0, 0, plate_thickness + 20 * explode]) key_holes(left_keys, "switch");
    rev0b_top_case();
    translate([0, 0, -bottom_case_height -20 * explode]) rev0b_bottom_case();

} else if (part == "holetest") {
    * translate([-66.5, 20.25]) top_case([left_holes[0], left_holes[1], left_holes[7], left_holes[8]], [], raised = true)
        translate([66.5, -20.25]) square([46, 49], center = true);
    translate([-66.5, 20.25]) difference() {
        chamfer_extrude(height = plate_thickness + top_case_raised_height, chamfer = 5, width = 2.5, faces = [false, true]) translate([66.5, -20.25]) square([46, 49], center = true);
        translate([0, 0, 4])
        key_holes([left_holes[0], left_holes[1], left_holes[7], left_holes[8]]);
    }
}


// Requires my utility functions in your OpenSCAD lib or as local submodule
// https://github.com/Lenbok/scad-lenbok-utils.git
use<Lenbok_Utils/utils.scad>
// Requires bezier library from https://www.thingiverse.com/thing:2207518
use<Lenbok_Utils/bezier.scad>
