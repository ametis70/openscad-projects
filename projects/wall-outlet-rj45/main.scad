include <../lib/BOSL2/std.scad>
use <lib/RJ45KeystoneReceiver/rj45_keystone_receiver.scad>;

wt = 0.8; // Wall thickness

base_x = 43.80;
base_y = 24.35;
base_z = 7.65;
base = [base_x, base_y, base_z];

holder_base_x = 45.25;
holder_base_y = base_y;
holder_base_z = 2.5;
holder_base = [holder_base_x, holder_base_y, holder_base_z];

holder_top_x = holder_base_x + wt;
holder_top_y = base_y;
holder_top_z = 5.85;
holder_top = [holder_top_x, holder_top_y, holder_top_z];

holder_top_cut_bottom_x = 32.35;
holder_top_cut_x = 39.60;

clip_size = 6.50;

module clip() {
    union() {
        left(wt * 1.5)
        fwd(wt)
        difference() {
            cube([wt * 2.5, clip_size + wt * 2, holder_top_z]);
            right(wt)
            back(wt)
            down(1)
            cube([wt + 1, clip_size, 10]);
        }

      zrot(-90)
      left(clip_size)
      fwd(wt / 2)
        wedge([clip_size, wt * 2, holder_top_z]);
    }
}

module base_clip_hole() {
    left(1)
    down(1)
    cube([1 + (holder_base_x - base_x) / 2, clip_size, holder_base_z + 1]);
}

difference() {
    union() {
        // Base
        cuboid(
            base,
            rounding = 2,
            edges = [BOT + LEFT, BOT + RIGHT],
            $fn = 24,
            anchor = FRONT + LEFT + BOT
        );

        // Holder Base
        up(base_z)
        left((holder_base_x - base_x) / 2)
        difference() {
            cube(holder_base);

            // Holes below clips
            up(0.5)
            back(holder_base_y / 2 - clip_size / 2) {
                base_clip_hole();
                right(holder_base_x) base_clip_hole();
            }
        }

        // Holder top
        up(base_z + holder_base_z)
        left((holder_top_x - base_x) / 2)
        fwd((holder_top_y - base_y) / 2) {
            difference() {
                cube(holder_top);

                // Wall triangles
                right((holder_top_x - holder_top_cut_x) / 2)
                back(-1)
                down(1)
                cuboid(
                    [holder_top_cut_x, holder_top_y + 2, holder_top_z + 10],
                    chamfer = holder_top_cut_x - holder_top_cut_bottom_x,
                    edges = [BOT + LEFT, BOT + RIGHT],
                    anchor = FRONT + LEFT + BOT
                );

                back(wt)
                right(wt)
                // Lateral inner hollow
                cube([holder_base_x - wt, holder_base_y - wt * 2, 10]);

                // Hole for clip
                left(1)
                down(1)
                back(holder_base_y / 2 - clip_size / 2)
                cube([holder_top_x + 2, clip_size, 10]);
            }

            // Clips
            zrot(180)
            left(wt)
            fwd(holder_base_y / 2 + clip_size / 2)
            clip();

            right(holder_top_x - wt)
            back(holder_base_y / 2 - clip_size / 2)
            clip();
        }
    }

    // Hollow inside
    translate([wt, wt, wt])
    cube([base_x - wt * 2, base_y - wt * 2, 100]);

    zrot(-90)
    left(base_y / 2 + 18 / 2)
    back(base_x / 2 - 25 / 2)
    up(8)
    zflip()
    rj45VolumeBlock();
}

zrot(-90)
left(base_y / 2 + 18 / 2)
back(base_x / 2 - 25 / 2)
up(9.9)
zflip()
rj45Receiver();
