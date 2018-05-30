include <kle-examples/ergodox-layout.scad>
include <keyboard-case.scad>

$fa = 1;
$fs = $preview ? 5 : 2;
bezier_precision = $preview ? 0.05 : 0.025;

// Hacky way to select just the left hand keys from split iris/redox layout
left_keys = [ for (i = key_layout) if (key_pos(i).x < 10) i ];

/////////////////////////////////////////
// Rudimentary ergodox case. Untested
/////////////////////////////////////////
ex0 = 88;
ey0 = -104;
ex1 = 0;
ey1 = 0;
ex2 = 144;
ey3 = -70;
ex3 = 183.5;
ey4 = -93;
ex4 = 155.0;
ey5 = -143;
ergodox_reference_points = [
    [ex0, ey0], // Bottom mid
    [ex1, ey0], // Bottom left
    [ex1, ey1], // Top left
    [ex2, ey1], // Top right
    [ex2, ey3], // Mid right
    [ex3, ey4], // Right
    [ex4, ey5], // Bottom
    ];
ergodox_screw_holes = [
    [ex1, ey0], // Bottom left
    [ex1, ey1], // Top left
    [ex2, ey1], // Top right
    [ex3, ey4], // Right
    [ex4, ey5], // Bottom
    ];
ergodox_tent_positions = [];

module ergodox_outer_profile() {
    fillet(r = 5, $fn = 20)
        offset(r = 5, chamfer = false)
        polygon(points = ergodox_reference_points, convexity = 3);
}
module ergodox_top_case() {
    top_case(left_keys, ergodox_screw_holes, raised = false) ergodox_outer_profile();
}
module ergodox_bottom_case() {
    bottom_case(ergodox_screw_holes, ergodox_tent_positions) ergodox_outer_profile();
}


part = "assembly";
explode = 1;
if (part == "outer") {
    offset(r = -2.5) // Where top of camber would come to
        ergodox_outer_profile();
    for (pos = ergodox_screw_holes) {
        translate(pos) {
            polyhole2d(r = 3.2 / 2);
        }
    }
    #key_holes(left_keys);
    
} else if (part == "top") {
    ergodox_top_case();

} else if (part == "bottom") {
    ergodox_bottom_case();

} else if (part == "assembly") {
    %translate([0, 0, plate_thickness + 30 * explode]) key_holes(left_keys, "keycap");
    %translate([0, 0, plate_thickness + 20 * explode]) key_holes(left_keys, "switch");
    ergodox_top_case();
    translate([0, 0, -bottom_case_height -20 * explode]) ergodox_bottom_case();
}


// Requires my utility functions in your OpenSCAD lib or as local submodule
// https://github.com/Lenbok/scad-lenbok-utils.git
use<Lenbok_Utils/utils.scad>
