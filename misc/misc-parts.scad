$fa=1;
$fs = $preview ? 5 : 2;

// M5 bolt tenting
boltRad = 5 / 2;
nutRad = 9.4 / 2;
nutHeight = 3.5;

// Brackets for attaching micro USB breakout to the case
// Print a couple of these to prevent heads of the mini-usb mounting screws from
// hitting the mini-usb socket
module micro_usb_bracket() {
    height = micro_usb_socket_height + 0.25; // One layer above
    difference() {
        translate([0, 0, height/2])  roundedcube([micro_usb_screw_sep + 7, 7, height], center = true);
        translate([0, 8, -pcb_thickness - 0.01]) micro_usb_hole();
        for (i = [-1,1]) {
            translate([i * micro_usb_screw_sep/2, 0, 0]) polyhole(r = (micro_usb_screw_dia + 0.2) / 2, h = 15, center = true);
        }
    }
}

// Make a mold for making an oogoo foot around the M5 nut heads.
module foot_negative(cap_head) {
    rotate([0, 90, 0]) {
        // Nut trap to stop the bolt from being pushed out. Two half height nuts.
        translate([0, 0, -1]) cylinder(r = nutRad + 0.75, h = 5.5, center = true, $fn=16);
        // actual bolt shaft
        polyhole(r = boltRad, h = 20, center = true);
        if (cap_head) {
            // show actual bolt head shape
            translate([0, 0, 8]) cylinder(r1 = 4.4, r2 = 4.4, h = 5.3, center = false);
            // This is the rubber around the head
            translate([0, 0, 10.5]) {
                scale([1, 1, 0.75])  sphere(r = 7);
            }
        } else {
            // show actual bolt head shape
            translate([0, 0, 10]) cylinder(r1 = 5, r2 = 2.5, h = 2.7, center = false);
            // This is the rubber around the head
            translate([0, 0, 11]) {
                scale([1, 1, 0.5])  sphere(r = 6.5);
            }
        }
    }
}

module foot_mold(cap_head) {
    height = 8;
    for (m = [0, 1])
        mirror([m, 0, 0])
            translate([5, 0, 0])
            difference() {
            translate([0, -10, 0])  cube([25, 65, height], center = false);
            for (i = [0:3]) {
          #      translate([7, i*15, height]) foot_negative(cap_head);
            }
    }
}

//micro_usb_bracket();

foot_mold(cap_head = false);

// Requires my utility functions in your OpenSCAD lib or as local submodule
// https://github.com/Lenbok/scad-lenbok-utils.git
use<../Lenbok_Utils/utils.scad>
