$fa=1;
$fs=5;
$fs=2;    // Uncomment for final render

base_height = 13;
base_chamfer = 2.5;

tent_positions = [
    [85.5, 5, 0],
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
    off = apothem(nutRad, 6)+0.5;
    lift = 0;
    height = base_height - lift;
    translate([position[0], position[1], lift]) rotate([0, 0, position[2]]) {
        difference() {
            chamfer_extrude(height=height, chamfer=base_chamfer, faces = [true, false]) {
                hull() {
                    translate([-5,0]) square([0.1, 35], center=true);
                    translate([off, 0]) circle(r=boltRad+base_chamfer+1.5);
                }
            }
            translate([-10,-20, -0.1]) cube([10-base_chamfer, 40, base_chamfer+1], center=false);
            translate([-10,-20, base_chamfer]) cube([10, 40, base_height+1], center=false);
            translate([off, 0, -0.1]) polyhole(r=boltRad, h=height+1);
            // Nut hole
            translate([off, 0, height-nutHeight]) rotate([0, 0, 60/2]) cylinder(r=nutRad, h=nutHeight+0.1, $fn=6);
        }
    }
}

usb_interconnect = 1; // 0 = keep TRRS interconnect, 1 = mini-usb interconnect

module base() {
    union() {
        rotate([0,0,180]) import("BottomR.sl.stl");
        if (usb_interconnect) {
            // Fill in TRRS hole, since we'll do something different
            translate([-42, 61.426, base_chamfer]) cube([20, 2.0004, base_height - base_chamfer - 0.1]);
        }
        for(i = [0:len(tent_positions)-1]) {
            tent_support(tent_positions[i]);
        }
    }
}

mirror([1, 0, 0]) base();

// Requires my utility functions in your OpenSCAD lib https://cubehero.com/physibles/Lenbok/Lenbok_Utils
use<Lenbok_Utils/utils.scad>
