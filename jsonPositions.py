from argparse import ArgumentParser
import sys
import re
import json

parser = ArgumentParser(description="Convert keyboard-layout-editor.com data into \
position/size data structure for OpenSCAD.")
parser.add_argument('iname',nargs='?',default=None)
parser.add_argument('--varname',nargs='?',default="key_layout")
args = parser.parse_args()

jsonFile  = open(args.iname,"r") if args.iname else sys.stdin
layout = jsonFile.read()
jsonLayout = json.loads(layout, strict=False);

currentX = 0;
currentY = 0;
currentRowY = 0;

nextWidth = 1;
nextHeight = 1;
nextRotation = 0;
nextRotationX = 0;
nextRotationY = 0;

print("""
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
""")
print("%s = [" % args.varname);

for row in jsonLayout:
    if(isinstance(row, dict)):
        continue;

    addY = 0
    for key in row:
        addX = 0

        if(isinstance(key, str)):
            print("    [[%s, %s], [%s, %s], [%s, [%s, %s]]], /* %s */" % (nextRotationX + currentX, nextRotationY + currentRowY + currentY, nextWidth, nextHeight, nextRotation, nextRotationX, nextRotationY, re.sub(r"\s+", ' / ', key)))
            currentX += nextWidth;
            nextWidth = 1;
            nextHeight = 1;
        else:
            if("x" in key):
                addX = key["x"]
                currentX += addX;
            if("y" in key):
                addY = key["y"]
                currentY += addY;

            if("w" in key):
                nextWidth = key["w"];
            if("h" in key):
                nextHeight = key["h"];
            #Rotation seems to reset the row locations
            if("r" in key):
                nextRotation = key["r"]
                currentRowY = 0
                currentX = addX
                currentY = addY
                #nextRotationX = 0;
                #nextRotationY = 0;
            if("rx" in key):
                nextRotationX = key["rx"];
            if("ry" in key):
                nextRotationY = key["ry"];


    currentX = 0;
    currentRowY += 1


print("];");
