include <../lib/BOSL2/std.scad>;

/* [Hidden] */

$fn = 80;

/* [Base Dimensions] */

// Diameter of the bottom (base) of the holder
bottom_diameter = 63.5; // .01
// Diameter of the top opening
top_diameter = 50.0; // .01
// Total height of the holder
height = 40.0; // .01

/* [Wedge Settings] */

// Depth of the wedge cutout from the top
wedge_depth = 30.0; // .01
// Inner diameter at the bottom of the wedge
wedge_inner_diameter = 10; // .01
// Wall thickness around the wedge
wedge_wall_thickness = 2.0; // .01

/* [Shape Settings] */

// Rotation angle applied to the top
rotation = 80; // 1
// Number of faces for the twisted shape
faces = 40; // 1

/* [Hidden] */

top = circle($fn=$fn, d=top_diameter);
bottom = circle($fn=$fn, d=bottom_diameter);

difference() {
  skin([bottom, rot(rotation, p=top)], z=[0,height], slices=faces);
  up(height - wedge_depth + 0.01) cylinder(center = false, $fn=$fn, d1=wedge_inner_diameter, d2=top_diameter - wedge_wall_thickness, h=wedge_depth);
}

