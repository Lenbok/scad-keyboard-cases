///////////////////////////////////////////////////
// Minimal Tilted Corne Keyboard case (alternate layout)
//
// * Simple top plate (no sides)
// * Simple angled bottom plate (no sides)
// * Supports bottom mount MCU e.g. nrfmicro/lipo combo
//
///////////////////////////////////////////////////

include <../keyboard-case.scad>
include <crkbd-common.scad>

theme = 3;
nrfmicro = false;   // If true, make adjustments for nrfmicro and small lipo battery, rather than pro micro.
top_mount_mcu = false;
top_mount_reset = false;
wall_thickness = 2.5;
plate_thickness = 4;   // (5mm - max diode height)
bottom_case_height = 0;
window_z = top_mount_mcu ? 13 : 6;
battery_bay = false;
battery_bay_size = [66.5, 15, 9];
battery_bay_offset = [-8, -mcu_size.y+0.5, 0];

mcu_size = [20.0, 35, 13.2];  // Adjusted depth according to sockets etc

screw_rad = 2.2 / 2;
screw_head_rad = 5.4 / 2;
//screw_head_depth = 1.5;
screw_head_depth = 0;

//standoff_rad = 4.0 / 2;
bottom_screws = true; // Default is to screw down from the top

tent_angle = 10;

hipro_height = 9.5;   // 0 for minimal, ~9.5 for flush, ~15 for hipro

micro_usb_hole_width = 14;
micro_usb_hole_height = 8;
cherry_clip_recess_height = 2.0; // How far down clip recess go, just go for the minimal
keycap_depth_offset = 6.6;  // Distance from bottom of keycap to top of plate.

$fa = 1;
$fs = $preview ? 8 : 2;

module crkbd_top_case() {
    top_plate(left_keys, crkbd_screw_holes) crkbd_left_top();
}

module crkbd_bottom_case() {
    outer_height = 1.25;
    standoff = 2.2;

    gap_offset = hipro_height == 0 ? 0 : 0.4;
    outer_offset = hipro_height == 0 ? 0 : 2.5 + gap_offset;

    outer_width = crkbd_pcb.x + 2 * outer_offset;
    min_inner_height = top_mount_mcu
        ? (battery_bay_size.z + wall_thickness)
        : battery_bay ? (battery_bay_size.z + wall_thickness)
        : outer_height;
    min_angle = atan((min_inner_height - outer_height) / outer_width);
    if (tent_angle < min_angle) {
        echo(str("WARNING: min_angle=", min_angle, " tent_angle=", tent_angle, " inner_height=", inner_height));
    }

    inner_height = tan(tent_angle) * outer_width + outer_height;
    c = crkbd_first_offset + [0, 30, -inner_height + outer_height];

    rotate([0, tent_angle, 0]) translate([-c.x, -c.y, 0]) rotate([0, -tent_angle, 0]) translate([c.x, c.y, 0])
    difference() {
        translate([-c.x, -c.y, 0])
        difference() {
            translate(c) difference() {
                chamfer_extrude(height = inner_height + hipro_height, convexity = 3, faces = hipro_height == 0 ? "none" : "top")
                    offset(r=outer_offset) crkbd_left_bottom();
                if (hipro_height > 0) {
                    translate([0, 0, inner_height])
                        linear_extrude(height = hipro_height + 0.01, convexity = 3)
                        offset(r = gap_offset) crkbd_left_bottom();
                }
            }
            rotate([0, tent_angle, 0])
                translate([-outer_offset-0.1, -100, -inner_height])
                cube([crkbd_pcb.x * 2, 200, inner_height]);
        }
        translate([0, 0, 0]) {
            if (battery_bay) {
                // Hole for lipo battery
                translate(-crkbd_first_offset)
                translate([crkbd_pcb.x - battery_bay_size.x, -battery_bay_size.y, -battery_bay_size.z + outer_height + 0.01])
                translate(battery_bay_offset) {
                    roundedcube(battery_bay_size, r = 1, center = false);
                }
            }
            if (!top_mount_mcu) {
                // Hole for mcu
                translate(-crkbd_first_offset)
                translate([crkbd_pcb.x - mcu_size.x + 0.01, -mcu_size.y, -mcu_size.z+outer_height+standoff]) {
                    cube(mcu_size, center = false);
                    if (hipro_height > 0) {
                        translate([2.5, 0, 0]) cube(mcu_size + [-5, 10, 0], center = false);
                    }
                }
            }
            if (!top_mount_reset) {
                // Hole for reset access, extend through bottom for hipro version
                reset_cutout = reset_size + [2, 2, hipro_height == 0 ? 5 : 50];
                translate(-crkbd_first_offset)
                translate([crkbd_pcb.x - reset_cutout.x + 0.01, reset_y_off-reset_cutout.y/2, -reset_cutout.z+outer_height+standoff]) {
                    cube(reset_cutout, center = false);
                }
            }
        }
        screw_positions(crkbd_screw_holes) {
            screw_head_depth = 80;
            translate([0, 0, -0.1-screw_head_depth-1]) bolthole(r1=screw_head_rad, r2=screw_rad, h1=screw_head_depth, h2=screw_length, membrane = screw_head_depth > 0 ? 0.2 : 0);
        }
    }
}


part = "assembly";
explode = 0;
cross_section = false;
depressed = false;

if (part == "outer") { // To preview the outer profile, key hole, and screw hole positions
    /* offset(r = -2.5) // Where top of camber would come to */
    color("gray") translate([0, 0, -7.1]) crkbd_expand_profile(2) crkbd_left_bottom_mod();
    color("blue") translate([0, 0, -5.1]) crkbd_left_bottom_mod();
    translate([0, 0, -5]) crkbd_left_top();
    //translate([0, 0, -5]) crkbd_left_top_window();
    color("black") for (pos = crkbd_screw_holes) {
        translate(pos) {
            circle(r = 2.5 / 2, $fn=20);
            //polyhole2d(r = 2.5 / 2);
        }
    }
    #key_holes(left_keys, "plate");
    
} else if (part == "top") {
        translate(crkbd_center_offset)
        render() crkbd_top_case();
    //%translate([0, 0, plate_thickness + -7 * explode]) key_holes(left_keys, "keycap");

} else if (part == "bottom") {
    rotate([0, $preview ? 0 : -tent_angle, 0])
    translate(crkbd_center_offset)
        crkbd_bottom_case();

} else if (part == "assembly") difference(convexity=10) {
    union() {
        //rotate([0, -tent_angle, 0])
        translate([-80, 60, plate_thickness]) {
                %translate([0, 0, plate_thickness - (depressed ? 4 : 0) + 30 * explode]) key_holes(left_keys, "keycap");
                %translate([0, 0, plate_thickness + 20 * explode]) key_holes(left_keys, "switch");
                crkbd_top_case();

                %translate([0, 0, -2.5 - 5 * explode]) crkbd_pcb_assembly(top_mount_mcu = top_mount_mcu, top_mount_reset = top_mount_reset, window_z = window_z);

            }

            translate([-80, 60, 0])
            translate([0, 0, -bottom_case_height - 1 - (20 * explode)]) crkbd_bottom_case();

    }
    if (cross_section) {
        translate([50, -250, -250])  cube([400, 500, 500], center = false);
    }
}


// Requires my utility functions in your OpenSCAD lib or as local submodule
// https://github.com/Lenbok/scad-lenbok-utils.git
use<../Lenbok_Utils/utils.scad>
