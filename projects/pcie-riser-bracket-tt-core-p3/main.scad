include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/screws.scad>

/* [Hidden] */

$fn = 64;

/* [Bracket Configuration] */

// Print the vertical bracket for 180° cables
add_vertical_bracket = true;

/* [Standoff Options] */

// Use printed standoffs on vertical bracket (180° cables)
use_standoffs_vertical = true;
// Use printed standoffs on horizontal bracket (90° cables)
use_standoffs_horizontal = true;

/* [Metal Standoff Options] */

// Size adjustment for metal standoff screw holes
screw_hole_oversize = -0.5; // .01

/* [Horizontal Bracket Standoff Positions (90° cables)] */

// X position of first horizontal mount
horizontal_mount_1_x = 21.50; // .01
// Y position of first horizontal mount
horizontal_mount_1_y = 27; // .01
// X position of second horizontal mount
horizontal_mount_2_x = 143.75; // .01
// Y position of second horizontal mount
horizontal_mount_2_y = 27; // .01

/* [Vertical Bracket Standoff Positions (180° cables)] */

// X position of first vertical PCI mount
pci_mount1_vertical_x = 4.20; // .01
// Y position of first vertical PCI mount
pci_mount1_vertical_y = 6; // .01
// X position of second vertical PCI mount
pci_mount2_vertical_x = 107; // .01
// Y position of second vertical PCI mount
pci_mount2_vertical_y = 6; // .01

/* [Hidden] */

module mount_standoff(height) {
  diff() {
    cylinder(d=6, h=height)
    attach(TOP)
    screw_hole("#6-32,0.236", thread=true, anchor=TOP, counterbore=0); 
  }
}

module mount_screw_hole() {
  screw_hole("#6-32,0.236", hole_oversize=screw_hole_oversize);
}

module vertical_bracket() {
  x_offset = 18.20;
  y_offset = 10;
    
  width = 111.50;
  depth = 1.40;
  height = 10.30;
    
  right(x_offset) back(y_offset) {
    diff() {
      cube([width, depth, height]);
        
      if (!use_standoffs_vertical) {
        up(pci_mount1_vertical_y) xrot(90) right(pci_mount1_vertical_x) mount_screw_hole();
        up(pci_mount1_vertical_y) xrot(90) right(pci_mount2_vertical_x) mount_screw_hole();
      }
    } 
    
    if (use_standoffs_vertical) {  
      up(pci_mount1_vertical_y) xrot(90) right(pci_mount1_vertical_x) mount_standoff(6.60);
      up(pci_mount1_vertical_y) xrot(90) right(pci_mount2_vertical_x) mount_standoff(6.60);
    }
  }     
}

module horizontal_bracket() {
  diff_offset = 1;    
  width = 150.55 - 3.75;
  depth = 32.30;
  height = 1.40;
    
  module screw_hole() {
    cylinder(d=4.25, h = height + diff_offset * 2 );
  }
  
  difference() {
    cube([width, depth, height]);
     
    down(diff_offset) { 
      // PCI slot cutout  
      right(14.40) fwd(diff_offset)
        cube([118.15, 10 + diff_offset, height + diff_offset]);
    
      // Screw holes
      back(9.5) {
        right(4.50) screw_hole(); 
        right(142) screw_hole();    
      }
    }
    
    if (!use_standoffs_horizontal) {
      back(horizontal_mount_1_y) right(horizontal_mount_1_x) mount_screw_hole();
      back(horizontal_mount_1_y) right(horizontal_mount_2_x) mount_screw_hole();
    }
  }
  
  if (use_standoffs_horizontal) {
      back(horizontal_mount_1_y) right(horizontal_mount_1_x) mount_standoff(7);
      back(horizontal_mount_2_y) right(horizontal_mount_2_x) mount_standoff(7);
  }
}

horizontal_bracket(); 
if(add_vertical_bracket) vertical_bracket();


