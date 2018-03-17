$fa=1;
$fs=5;
$fs=2;    // Uncomment for final render

base_height = 13;
base_chamfer = 2.5;

tent_positions = [
    [85.5, 10, 0],
    [-58.0, 45, 155],
    [-69, -46, 210],
    ];

/* boltRad = 6 / 2; // M6 */
/* nutRad = 10 / 2; */
/* nutHeight = 4; */
boltRad = 5 / 2; // M5
nutRad = 9.3 / 2;
nutHeight = 3.5;
module tent_support(position) {
    off = boltRad*2;
    lift = base_chamfer;
    height = base_height - lift;
    translate([position[0], position[1], lift]) rotate([0, 0, position[2]]) {
        difference() {
            linear_extrude(height=height, convexity=3) difference() {
                hull() {
                    square([0.1, 35], center=true);
                    translate([off, 0]) circle(r=6);
                }
                translate([off, 0]) polyhole2d(r=boltRad);
            }
            // Nut hole
            translate([off, 0, height-nutHeight]) rotate([0, 0, 60/2]) cylinder(r=nutRad, h=nutHeight+0.1, $fn=6);
        }
    }
}


module base() {
    union() {
        rotate([0,0,180]) import("BottomR.sl.stl");
        // Fill in TRRS hole, since we'll do something different
        translate([-42, 61.426, base_chamfer]) cube([20, 2.0004, base_height - base_chamfer - 0.1]);
        for(i = [0:len(tent_positions)-1]) {
            tent_support(tent_positions[i]);
        }
    }
}

base();

// Requires my utility functions in your OpenSCAD lib https://cubehero.com/physibles/Lenbok/Lenbok_Utils
use<Lenbok_Utils/utils.scad>
