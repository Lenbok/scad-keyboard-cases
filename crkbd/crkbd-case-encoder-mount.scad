///////////////////////////////////////////////////
// Small plate to mount an encoder where the TRRS jack normally goes,
// for use when the crkbd makes use of a bluetooth MCU (nRFmicro,
// nice!nano, etc). Assumes the reset switch is bottom mounted.
///////////////////////////////////////////////////

include <../keyboard-case.scad>
include <crkbd-common.scad>

theme = 3;
top_mount_mcu = false;
top_mount_reset = false;
window_z = top_mount_mcu ? 13 : 6;

$fa = 1;
$fs = $preview ? 8 : 2;

encoder_base_size = [12.1, 11.5, 1];
encoder_base_size2 = [15.1, 11.5, 1.5];

module encoder_base_cutout() {
    cube(encoder_base_size + [0, 0, 0.01], center = false);
    translate([0, 0, encoder_base_size.z]) cube(encoder_base_size2, center = false);
}

module crkbd_encoder_mount() {
    mount_thickness = 1.5;
    mount_y = 22;
    standoff_rad = 1.8; // 1.8 fits brass standoffs; 2.6 fits nylon standoffs
    encoder_position_tweak = [1.9, 0, 0.01];
    difference() {
        color("#333333") translate([0, 0, crkbd_pcb.z]) linear_extrude(height = mount_thickness + encoder_base_size.z + encoder_base_size2.z, convexity = 3)
            // Create 2d profile first
            difference() {
            crkbd_left_top_window();

            translate(-crkbd_first_offset) translate([crkbd_pcb.x, -crkbd_window_size.y]) {

                // Truncate the window
                translate([-crkbd_window_size.x - 0.01, mount_y]) square([crkbd_window_size.x + 0.02, crkbd_window_size.y], center = false);

                // Cutout for wires to matrix
                translate([-2.5, 11]) square([5, 3.5], center = false);

                // Screw holes
                translate([-crkbd_window_size.x / 2, 9])
                    for (i = [-30, 150])
                        rotate([0, 0, i]) translate([crkbd_window_size.x / 2 - 1.7, 0])
                            polyhole2d(r = 1.1);
            }
        }
        // Cut out encoder footprint
        translate([0, 0, crkbd_pcb.z]) translate(-crkbd_first_offset) translate([crkbd_pcb.x, -crkbd_window_size.y]) {
            translate([-encoder_base_size.x/2 - crkbd_window_size.x/2, mount_y - encoder_base_size.y + 0.01, mount_thickness + 0.01])
                translate(encoder_position_tweak) encoder_base_cutout();
        }

        // Standoff recesses
        color("#cccc66") translate(-crkbd_first_offset)
            translate([crkbd_pcb.x - crkbd_window_size.x / 2, 9 - crkbd_window_size.y, crkbd_pcb.z + mount_thickness])
            for (i = [-30, 150])
                rotate([0, 0, i]) translate([crkbd_window_size.x / 2 - 1.7, 0, 0])
                    cylinder(r = standoff_rad, h = window_z, $fn = 6);
    }
}

part = "encoder-plate";
//part = "assembly";
explode = 0;
depressed = false;

if (part == "encoder-plate") {
    translate(crkbd_center_offset) crkbd_encoder_mount();
    //%translate([0, 0, plate_thickness + -7 * explode]) key_holes(left_keys, "keycap");
} else if (part == "assembly") difference(convexity=10) {
    union() {
        //rotate([0, -tent_angle, 0])
        translate([-80, 60, plate_thickness]) {
            %translate([0, 0, plate_thickness - (depressed ? 4 : 0) + 30 * explode]) key_holes(left_keys, "keycap");
            %translate([0, 0, plate_thickness + 20 * explode]) key_holes(left_keys, "switch");

            %translate([0, 0, -2.5 - 5 * explode]) crkbd_pcb_assembly(top_mount_mcu = top_mount_mcu, top_mount_reset = top_mount_reset, top_mount_trrs = false, window_z = window_z);

            translate([0, 0, -2.5 - 5 * explode]) crkbd_encoder_mount();

        }
    }
}


// Requires my utility functions in your OpenSCAD lib or as local submodule
// https://github.com/Lenbok/scad-lenbok-utils.git
use<../Lenbok_Utils/utils.scad>
