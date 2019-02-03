
// Functions to extract from the raw data structure, not sized to units
function key_pos(key) = key[0];
function key_size(key) = key[1];
function key_rot(key) = key[2];
function key_rot_angle(key) = key_rot(key)[0];
function key_rot_off(key) = key_rot(key)[1];

// Put a child shape at the appropriate position for a key, incorporating unit sizing
module position_key(key, unit = 19.05) {
    pos = (key_pos(key) + key_size(key) / 2) * unit;
    rot_off = key_rot_off(key) * unit;
    translate(rot_off) rotate([0, 0, key_rot_angle(key)]) translate(-rot_off)
        translate(pos)
        children();
}

not_so_minidox_layout = [
    [[3.5, 1], [1, 1], [0, [0, 0]]], /* E */
    [[2.5, 1.125], [1, 1], [0, [0, 0]]], /* W */
    [[4.5, 1.125], [1, 1], [0, [0, 0]]], /* R */
    [[5.5, 1.25], [1, 1], [0, [0, 0]]], /* T */
    [[0.5, 1.375], [1, 1], [0, [0, 0]]], /* Tab */
    [[1.5, 1.375], [1, 1], [0, [0, 0]]], /* Q */
    [[3.5, 2.0], [1, 1], [0, [0, 0]]], /* D */
    [[2.5, 2.125], [1, 1], [0, [0, 0]]], /* S */
    [[4.5, 2.125], [1, 1], [0, [0, 0]]], /*  / : / ; / F */
    [[5.5, 2.25], [1, 1], [0, [0, 0]]], /* G */
    [[0.5, 2.375], [1, 1], [0, [0, 0]]], /* Ctrl */
    [[1.5, 2.375], [1, 1], [0, [0, 0]]], /* A */
    [[3.5, 3.0], [1, 1], [0, [0, 0]]], /* C */
    [[4.5, 3.125], [1, 1], [0, [0, 0]]], /* V */
    [[2.5, 3.1251496999999997], [1, 1], [0, [0, 0]]], /* X */
    [[5.5, 3.25], [1, 1], [0, [0, 0]]], /* B */
    [[0.5, 3.375], [1, 1], [0, [0, 0]]], /* LShift */
    [[1.5, 3.375], [1, 1], [0, [0, 0]]], /* Z */
    [[4, 4.25], [1, 1], [0, [0, 0]]], /*  / LGui */
    [[5, 4.25], [1, 1], [12, [5, 5.25]]], /*  / Lower */
    [[5.93, 3.45], [1, 1.5], [30, [5, 5.25]]], /* Space */
];
