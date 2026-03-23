include <../lib/BOSL2/std.scad>;

/* [Hidden] */

$fn = 64;

/* [Pegboard configuration (set once)] */

// This should only be set once

// Separation between hole centers in pegboard
wall_hole_separation = 37.5; // .01
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

/* [Base settings (set per device)] */

// Modify on a per-print basis

// Width of the base
base_width = 80.0; // .01
// Height of the base
base_length = 20.0; // .01
// Depth of the base
base_depth = 5.0; // .01

/* [Wall peg settings (set per device)] */

// Modify on a per-print basis

// Peg count
wall_peg_count = 2; // 1
// Only render first and last peg
wall_peg_skip_center = true;

/* [Adapter peg settings (set per device)] */

// Modify on a per-print basis

// Render pegs
device_peg_enable = true;
// Peg count
device_peg_count = 2; // 1
// Only render first and last peg
device_peg_skip_center = true;
// Separation between hole centers in device
device_hole_separation = 38.0; // .01
// Diameter of narrow part of hole in device
device_hole_narrow_diameter = 5.0; // .01
// Diameter of wide part of hole in device
device_hole_wide_diameter = 10.0; // .01
// Diameter of narrow part of peg 
device_peg_narrow_diameter = 4.0; // .01
// Diameter of wide part of peg
device_peg_wide_diameter = 6.0; // .01
// Height of narrow part of peg
device_peg_narrow_height = 1.5; // .01
// Height of wide part of peg
device_peg_wide_height = 1.5; // .01

/* [Screw holes settings (set per device)] */

// Render screw holes
base_hole_enable = false;
// Screw holes count
base_hole_count = 2;
// Only render first and last holes
base_hole_skip_center = false;
// Separation between hole centers for device
base_hole_separation = 38.0; // .01
// Diameter of holes for device
base_hole_diameter = 2.7; // .01
// Diameter of holes for device
base_hole_depth = 4.5; // .01

// Wall peg assertions
assert(wall_peg_wide_diameter < wall_hole_wide_diameter);
assert(wall_peg_narrow_diameter < wall_hole_narrow_diameter);
assert(base_width > wall_hole_separation * (wall_peg_count - 1) + wall_peg_narrow_diameter);

// Forbid enabling pegs and holes at the same time
assert(!(device_peg_enable && base_hole_enable));

// Peg assertions
assert(!device_peg_enable || (device_peg_enable && device_peg_wide_diameter < device_hole_wide_diameter));
assert(!device_peg_enable || (device_peg_enable && device_peg_narrow_diameter < device_hole_narrow_diameter));
assert(!device_peg_enable || (device_peg_enable && (base_width > device_hole_separation * (device_peg_count - 1) + device_peg_narrow_diameter)));

// Hole assertions
assert(!base_hole_enable || (base_hole_enable && base_width > base_hole_separation * (base_hole_count - 1) + base_hole_diameter));
assert(!base_hole_enable || (base_hole_enable && base_hole_depth < base_depth));

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

module render_holes(
  separation, 
  count,
  skip_center,
  diameter,
  depth
) {
  right_offset = (base_width - (separation * (count - 1))) / 2;
  down(0.01)
  back(base_length / 2)
  right(right_offset)
  for (i = [0:1:count - 1]) {
    if (
      !skip_center ||
      (skip_center && (i == 0 || i == count - 1))
    ) {
      right(separation * i) {
        cylinder(d=diameter, h=depth + 0.01);
      }
    }
  }
}

module adapter() {
  // Base
  difference() {
    cube([base_width, base_length, base_depth]);
    if (base_hole_enable) {
     render_holes(
        separation=base_hole_separation,
        count=base_hole_count,
        skip_center=base_hole_skip_center,
        diameter=base_hole_diameter,
        depth=base_hole_depth
      );
    }
  }
    
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
  
  // Device pegs
  if (device_peg_enable) {
    zflip()
    down(base_depth)
    render_pegs(
      separation=device_hole_separation,
      count=device_peg_count,
      skip_center=device_peg_skip_center,
      narrow_diameter = device_peg_narrow_diameter,
      wide_diameter = device_peg_wide_diameter,
      narrow_height = device_peg_narrow_height,
      wide_height = device_peg_wide_height
    );
  }
}

xrot(90) adapter();
