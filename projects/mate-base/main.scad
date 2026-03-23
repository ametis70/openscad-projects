include <../lib/BOSL2/std.scad>;

bottom_diameter = 63.5;
top_diameter = 50.0;
wedge_depth = 30.0;
wedge_inner_diameter = 10;
wedge_wall_thickness = 2.0;
height = 40.0;

rotation = 80;
faces = 40;

top = circle($fn=80, d=top_diameter);
bottom = circle($fn=80, d=bottom_diameter);

difference() {
  skin([bottom, rot(rotation, p=top)], z=[0,height], slices=faces);
  up(height - wedge_depth + 0.01) cylinder(center = false, $fn=80, d1=wedge_inner_diameter, d2=top_diameter - wedge_wall_thickness, h=wedge_depth);
}