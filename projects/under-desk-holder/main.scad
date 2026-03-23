include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/screws.scad>

/* [Hidden] */

$fn = 64;

/* [Settings] */

// Thickness of holder walls
wall_thickness = 3; // 0.01
// Width of the device
holder_hole_width = 46.8; // 0.01
// Height of the device
holder_hole_height = 28.5; // 0.01
// How far into the holder the device goes before the stop
holder_depth = 7; // 0.01
// Width and hieght of stop starting from walls
stop_size = 4; // 0.01
// How deep is the stop. This will affect the total size of the holder
stop_depth = 3; // 0.01
// Screw tab width 
tab_width = 15; // 0.01
// Screw tab depth. It will be the same as the depth of the whole holder if set to 0
tab_depth = 0; // 0.01
// Screw tab height. It will be the same as the wall thickness if set to 0
tab_height = 0; // 0.01
// Valid metric screw hole size
hole_diameter = 3.5;

/* [Hidden] */

_tab_depth = tab_depth == 0 ? holder_depth + stop_depth : tab_depth;
_tab_height = tab_height == 0 ? wall_thickness : tab_height;

module screw_tab() {
  color("blue") 
  diff()
  cube([tab_width, _tab_depth, _tab_height], center=false)
  attach(TOP)
  screw_hole(str("M", hole_diameter,"x1,1000"), head="flat",counterbore=0,anchor=TOP);
}

module holder() {
  color("green")
  difference() {
    cube([
      holder_hole_width + wall_thickness * 2, 
      holder_depth + stop_depth,
      holder_hole_height + wall_thickness * 2
    ]);
    
    fwd(1)
    right(wall_thickness)
    up(wall_thickness)
    cube([
      holder_hole_width, 
      holder_depth + stop_depth + 2, 
      holder_hole_height
    ]);
  }
  
  color("magenta")
  right(wall_thickness)
  up(wall_thickness) {
    difference() {
      cube([
        holder_hole_width, 
        stop_depth, 
        holder_hole_height
      ]);
    
      fwd(1)
      up(stop_size / 2)
      right(stop_size / 2)
      cube([
        holder_hole_width - stop_size, 
        stop_depth + 2, 
        holder_hole_height - stop_size,
      ]);
    }
  }
}

xrot(90) {
  screw_tab();

  right(tab_width)
  holder();

  right(tab_width + holder_hole_width + wall_thickness * 2)
  screw_tab();
}