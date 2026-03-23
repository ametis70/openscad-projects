include <../lib/BOSL2/std.scad>

/* [Hidden] */

$fn = 64;

// Width of the base
base_width = 100; // .01
// Height of the base
base_length = 24.8; // .01
// Depth of the base
base_depth = 5.0; // .01

/* [Pegboard configuration] */

// This should only be set once

// Separation between hole centers in pegboard
wall_hole_separation = 24.75; // .01
// Diameter of narrow part of hole in pegboard
wall_hole_narrow_diameter = 5.0; // .01
// Diameter of wide part of hole in peboard
wall_hole_wide_diameter = 10.0; // .01
// Diameter of narrow part of peg
wall_peg_narrow_diameter = 4.0; // .01
// Diameter of wide part of peg
wall_peg_wide_diameter = 8.0; // .01
// Height of narrow part of peg
wall_peg_narrow_height = 2.25; // .01
// Height of wide part of peg
wall_peg_wide_height = 2.75; // .01

/* [Wall peg settings] */

// Peg count
wall_peg_count = 4; // 1
// Only render first and last peg
wall_peg_skip_center = false;

// Wall peg assertions
assert(wall_peg_wide_diameter < wall_hole_wide_diameter);
assert(wall_peg_narrow_diameter < wall_hole_narrow_diameter);
assert(base_width > wall_hole_separation * (wall_peg_count - 1) + wall_peg_narrow_diameter);

module peg(narrow_diameter, wide_diameter, narrow_height, wide_height) {
  cylinder(d=narrow_diameter, h=narrow_height);
  up(narrow_height)
  cylinder(d=wide_diameter, h=wide_height);
}

module render_pegs(
  separation, 
  count,
  skip_center,
  narrow_diameter,
  wide_diameter,
  narrow_height,
  wide_height
) {
  right_offset = (base_width - (separation * (count - 1))) / 2;
  up(base_depth)
  back(base_length / 2)
  right(right_offset)
  for (i = [0:1:count - 1]) {
    if (
      !skip_center ||
      (skip_center && (i == 0 || i == count - 1))
    ) {
      right(separation * i) {
        peg(
          narrow_diameter = narrow_diameter,
          wide_diameter = wide_diameter,
          narrow_height = narrow_height,
          wide_height = wide_height
        );
      }
    }
  }
}

import("original.stl");

rotate([270,0,90])
right(base_length / 3)
down(base_depth)
fwd(10)
// Wall pegs
render_pegs(
  separation = wall_hole_separation,
  count = wall_peg_count,
  skip_center = wall_peg_skip_center,
  narrow_diameter = wall_peg_narrow_diameter,
  wide_diameter = wall_peg_wide_diameter,
  narrow_height = wall_peg_narrow_height,
  wide_height = wall_peg_wide_height
);
