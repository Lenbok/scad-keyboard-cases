// http://www.keyboard-layout-editor.com/#/gists/62e7fc79758227cd0ca7efae1afebd99
include <kle/crkbd-layout.scad>

// Hacky way to select just the left hand keys from a split layout
left_keys = [ for (i = crkbd_layout) if (key_pos(i).x < 8) i ];

crkbd_pcb = [134.65, 91.7, 1.65];
crkbd_first_offset = [-9.688, 26.449, 0];  // Coords to put top left corner of PCB at origin
crkbd_window_size = [20.708, 60.85];

crkbd_center_offset = crkbd_first_offset + [-crkbd_pcb.x, crkbd_pcb.y - 30] / 2; // To approx center on origin

mcu_size = [19.5, 34.5, 9.8];  // Adjust depth according to sockets etc

reset_size = [3.75, 6.25, 3.25];
reset_y_off = -38.6;  // Y offset relative to top right corner

trrs_size = [12.1, 6.5, 5];
trrs_y_off = -47.5;  // Y offset relative to top right corner

pos_x1 = 28.55;
crkbd_screw_holes = [
    [pos_x1, -64.4],        // Bottom left
    [pos_x1, -45.3],        // Top left
    [72.0, -81.6],          // Bottom mid
    [104.89, -41.7],        // Top right
    [118.7, -89.37],        // Bottom right
    ];

// This is so annoying, the SVG had the wrong scale, but direct import from the foostan dxf files didn't work.
svg_scale=0.755;
module crkbd_left_top() {
    scale([svg_scale, svg_scale, 0]) 
    translate([12.0095, -129.5])
    import(file = "orig/crkbd-left-top.svg");
}
module crkbd_left_top_window() {
    scale([svg_scale, svg_scale, 0]) 
    translate([162.94, -83.131])
    import(file = "orig/crkbd-left-top-window.svg");
}
module crkbd_left_bottom() {
    scale([svg_scale, svg_scale, 0]) 
    translate([11.9, -136.8])
    import(file = "orig/crkbd-left-bottom.svg");
}
module crkbd_left_bottom_mod() {
    scale([svg_scale, svg_scale, 0]) 
    translate([11.9, -136.8])
    import(file = "orig/crkbd-left-bottom-mod.svg");
}
module crkbd_expand_profile(expand = 4) {
    offset(r = expand, chamfer = false, $fn = 40)
    offset(delta = 1.25, chamfer = false, $fn = 40) // Delta gives sharp interiors
    children();
}
module crkbd_outer_profile(expand = 4) {
    crkbd_expand_profile(expand)
    crkbd_left_bottom();
}

module crkbd_pcb_assembly(top_mount_mcu = true, top_mount_reset = true, top_mount_trrs = true, window_z = 0) {

    color("purple") linear_extrude(height=crkbd_pcb.z) crkbd_left_bottom();

    color("#333333") translate(-crkbd_first_offset)
        translate([crkbd_pcb.x - mcu_size.x, -mcu_size.y, 0])
        translate([0, 0, top_mount_mcu ? crkbd_pcb.z : -mcu_size.z])
        cube(mcu_size);

    color("#555555") translate(-crkbd_first_offset)
        translate([crkbd_pcb.x - reset_size.x, reset_y_off - reset_size.y / 2, 0])
        translate([0, 0, top_mount_reset ? crkbd_pcb.z : -reset_size.z])
        cube(reset_size);

    color("#333333") translate(-crkbd_first_offset)
        translate([crkbd_pcb.x, 0, 0])
        translate([0, trrs_y_off, top_mount_trrs ? crkbd_pcb.z : -trrs_size.z])
        union() {
            translate([-trrs_size.x, -trrs_size.y / 2, 0]) cube(trrs_size);
            translate([0, 0, trrs_size.z / 2])  rotate([90, 0, 90]) cylinder(d = 5, h = 2.5, $fn = 8);
        }

    if (window_z > 0) {
        color("#333333") translate([0, 0, crkbd_pcb.z + window_z])
            linear_extrude(height=1.5) crkbd_left_top_window();
        color("#cccc66") translate(-crkbd_first_offset)
        translate([crkbd_pcb.x - crkbd_window_size.x / 2, 9 - crkbd_window_size.y, crkbd_pcb.z])
            for (i = [-30, 150])
            rotate([0, 0, i])
                translate([crkbd_window_size.x / 2 - 1.4, 0, 0])
                cylinder(r = 2, h = window_z, $fn = 6);
    }
}
