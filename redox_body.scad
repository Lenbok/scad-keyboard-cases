$fa=1;
$fs=5;
$fs=2;    // Uncomment for final render

base_height = 13;
base_chamfer = 2.5;
wall_thickness = 2.0004;

usb_interconnect = 1; // 0 = keep existing TRRS interconnect hole, 1 = mini-usb interconnect

tent_positions = [
    // [X, Y, Angle]
    [85.5, 45.0, 0],
    [85.5, -28, 0],
    [-57.8, 45.5, 155],
    [-69, -46, -150],
    ];

// M5 bolt tenting
boltRad = 5 / 2;
nutRad = 9.4 / 2;
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
            translate([-10,-20, base_chamfer]) cube([10-wall_thickness+0.1, 40, base_height+1], center=false);
            translate([off, 0, -0.1]) polyhole(r=boltRad, h=height+1);
            // Nut hole
            translate([off, 0, height-nutHeight]) rotate([0, 0, 60/2]) cylinder(r=nutRad, h=nutHeight+0.1, $fn=6);
        }
    }
}

module mini_usb_hole() {
    mini_usb_screw_rad=2.4/2; // Smaller than M3 to tap into
    mini_usb_screw_sep=20;
    mini_usb_hole_height=7.5;
    translate([0, 0, mini_usb_hole_height/2])  rotate([90, 0, 0]) roundedcube([10, mini_usb_hole_height, 10], r=1.5, center=true, $fs=1);
    for (i = [-1,1], j = [0, 14]) {
        translate([i*mini_usb_screw_sep/2, -4-j, -5]) polyhole(r=mini_usb_screw_rad, h=10);
    }
}

module modified_base() {
    difference() {
        union() {
            rotate([0,0,180]) import("orig/BottomR.stl");
            if (usb_interconnect) {
                // Fill in TRRS hole, since we'll do something different
                translate([-42, 61.426, base_chamfer]) cube([20, wall_thickness, base_height - base_chamfer - 0.1]);
            }
            for(i = [0:len(tent_positions)-1]) {
                tent_support(tent_positions[i]);
            }
        }
        if (usb_interconnect) {
            translate([-28, 61.426, wall_thickness]) mini_usb_hole();
        }
        // Hole to access reset microswitch
        #translate([40, 55.38, wall_thickness]) {
            cube([14, 6, 6], center = false);
            translate([8, 0, 1])  cube([2, 10, 4], center = false);
        }
    }
}

//mirror([1, 0, 0])
modified_base();

// Requires my utility functions in your OpenSCAD lib https://cubehero.com/physibles/Lenbok/Lenbok_Utils
use<Lenbok_Utils/utils.scad>
