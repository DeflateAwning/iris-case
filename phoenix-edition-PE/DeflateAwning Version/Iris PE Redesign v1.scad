include <BOSL2/std.scad>;

// Fuzzy Skin Settings:
// Distance: 0.7mm
// Thickness: 1.0mm
// Supports Required.

//filename = "../Iris PE Middle Layer - Normal No Lip for 1.5mm Plate.stl";
filename = "../Iris PE Middle Layer - Normal No Lip for 1.5mm Plate - Centered.stl";
outline_filename = "openscad_gen - Iris PE Normal No Lip Outline.dxf";

import_size_x = 157.44;
import_size_y = 137.69;
import_size_z = 11;

tilt_angle_deg = 20;
tilt_angle_deg_vector = [0, -20, 0];

screw_depth = 8-1; // screw len minus FR4 plate thickness
screw_d = 1.7; // M2 screw, but at this small of diameter, the plastic fills the hole

ball_d = 6;
ball_cyl_d = 3.5;
ball_cyl_h = 1;
foot_max_d = ball_d * 1.4; // max d for clipped cones
foot_max_d_cyl = ball_d * 1.25; // real max d
foot_retainer_h = 3.5+2; // sum of heights from middle of ball in _make_ball_outside()

holes_xy = [[-7, -47.9], [-72.8, -29], [-73, 51.3], [-7, 63.7], [17.9, 62.8], [46.1, 53.2], [46.6, 9], [61.9, -14.4], [72.5, -21.8], [49, -62.6]];
ball_loc_xy = [[-7, -47.9], [-72.8, -29], [-72.9, (51.3-29)/2], [-73, 51.3], [-7, 63.7], [46.1, 53.2], [46.6, 9], [72.5, -21.8], [49, -62.6]];

// bot_left_ball_xy = [-72.8, -29]; // for indexing the reset switch position

bot_t_total = 1.5;
bot_overlap = 1;
bot_t_nonoverlap = bot_t_total - bot_overlap;

total_h = import_size_z + bot_t_nonoverlap;

/////////////////////// Settings for Stand ///////////////////////
stand_shim_h = 2.7;

// support for the ball of your hand
stand_hand_ball_x = -50;
stand_hand_ball_y = -125;
stand_hand_ball_z = 30; // absolute position in space (not relative to the shim top)
stand_hand_ball_d = 45;

// locations of balls on the bottom of the stand
ball_loc_xy_stand = [[-7, -47.9], [-72.8, -29+8], /*[-72.9, (51.3-29)/2],*/ [-73, 51.3-8], [-7, 63.7], [46.1, 53.2], [46.6, 9], [72.5, -21.8], [49, -62.6]];


//////////////////////////////////////////////////////////////////


//echo("Amount of screw that goes into the ball part below: ", -(total_h-screw_depth-ball_d/2-ball_cyl_h), " (negative means not intersecting)");

$fn = 100;


//import_outline();

//make_stand();
//make_main_case(); // THIS IS THE MAIN ONE
make_balls();

//make_sizing_grid();
//fuzzy_region_modifier();

// debug cross-section view
/*
difference() {
	make_main_case();
	//translate([46.1, 53.2, 0]) cuboid([100, 100, 100], anchor=LEFT+FRONT);
	translate([46.1, 53.2, 0]) cuboid([100, 100, 100], anchor=LEFT);
}*/

module import_model() {
	import(filename);
}

module import_outline() {
	import(outline_filename);
}

module create_solid_import() {
	// creates a "solid" version (in 2D) of the outline
	// saved, because it takes forever to render
	for (i = [0.01:0.001:1]) {
		scale([i, i, 1]) projection(false) import_file();
	}

	circle(d=50);
}

module make_main_case () {
	difference() {
		union() {
			up(bot_t_nonoverlap) {
				import_model();
				for (xy = holes_xy) translate([xy[0], xy[1], 0]) zcyl(d=5, h=import_size_z, anchor=BOTTOM);
			}

			linear_extrude(height = bot_t_total) import_outline();

			
			// add supports around balls
			for (xy = ball_loc_xy) translate([xy[0], xy[1], 0]) {
				zcyl(d=foot_max_d+2.5, h=foot_retainer_h+2, anchor=BOTTOM);
				intersection() {
					spheroid(d=ball_d+4, anchor=CENTER, $fn=50);
					cuboid([1000, 1000, 1000], anchor=BOTTOM);
				}
			}
		}

		// remove screw holes to top board
		for (xy = holes_xy) translate([xy[0], xy[1], 0]) {
			up(total_h) zcyl(d=screw_d, h=screw_depth, anchor=TOP);
			up(total_h) zcyl(d1=screw_d, d2=2.1, h=0.8, anchor=TOP); // add registration hole for easy screwing
		}

		// remove reset/programming hole
		//translate([-import_size_x/2 + 83.7, import_size_y/2 - 52.5, 0]) zcyl(d=12, h=100);
		echo("Programming hole location (original): ", -import_size_x/2 + 83.7, import_size_y/2 - 52.5); //  4.98, 16.345
		//% translate([-import_size_x/2 + 83.7, import_size_y/2 - 52.5, 0]) cuboid([8, 8, 30], rounding=2.5, except=[TOP, BOTTOM]);
		translate([5.27, 15.98, 0]) zcyl(d=7, h=50); //cuboid([8, 8, 30], rounding=2.5, except=[TOP, BOTTOM]);
	
		// remove places for balls
		for (xy = ball_loc_xy) translate([xy[0], xy[1], 0]) {
			_make_ball_outside(false);
		}

	}

}

module _make_raised_stand_outline(degrees_delta, offset_radius) {
	translate([-import_size_x/2, -import_size_y/2, stand_shim_h]) xflip() zrot(180) xrot(90)
		rotate_extrude(angle=tilt_angle_deg+degrees_delta, $fn=500)
		translate([import_size_x/2+0.001, import_size_y/2+0.001, 0]) offset(r=offset_radius) import_outline();
}

module make_stand() {
	// FIXME: update this to work with the new ball format
	
	difference() {
		union() {
			// add the outline
			_make_raised_stand_outline(0, 0);
			
			// add a shim at the bottom
			linear_extrude(stand_shim_h) import_outline();

			// add ball-of-hand (hand_ball) support
			// methodolgy: move it to where it should be if the keeb were flat, then rotate it, then hull it
			
			// main stand
			translate([stand_hand_ball_x, stand_hand_ball_y, 0])
				zcyl(d=stand_hand_ball_d, h=stand_hand_ball_z, anchor=BOTTOM, rounding2=5);
			
			hull() {
				// shadow underneath the main part
				translate([stand_hand_ball_x, stand_hand_ball_y]) zcyl(d=stand_hand_ball_d, h=8, anchor=BOTTOM);

				// join back to the main stand (left node)
				translate([-40, 0, 0]) zcyl(d=10, h=8, anchor=BOTTOM);

				// join back to the main stand (right node)
				translate([-10, -30, 0]) zcyl(d=10, h=8, anchor=BOTTOM);
			}
		}

		// remove inside part (rotate_extrude)
		_make_raised_stand_outline(degrees_delta = 30, offset_radius = -10);

		// remove inside part (linear_extrude)
		down(0.9) linear_extrude(stand_shim_h+1) offset(r=-10) import_outline(); // TODO maybe comment this line

		// remove spherical hole locations (interface with keyboard)
		up(stand_shim_h) rot(tilt_angle_deg_vector, cp=[-import_size_x/2, 0, 0]) {
			for (xy = ball_loc_xy) translate([xy[0], xy[1], 0]) {
				zcyl(d=ball_cyl_d, h=ball_d/2+ball_cyl_h, anchor=TOP);
				spheroid(d=ball_d, anchor=CENTER);
			}
		}

		// remove spherical hole locations under keeb (grip on desk)
		for (xy = (ball_loc_xy_stand)) translate([xy[0], xy[1], 0]) {
			zcyl(d=ball_cyl_d, h=ball_d/2+ball_cyl_h, anchor=BOTTOM);
			spheroid(d=ball_d, anchor=CENTER);
		}

		// remove spherical hole locations under hand (grip on desk)
		translate([stand_hand_ball_x, stand_hand_ball_y]) for (rot = [0:60:360]) zrot(rot) right(stand_hand_ball_d/2 - 8) {
			zcyl(d=ball_cyl_d, h=ball_d/2+ball_cyl_h, anchor=BOTTOM);
			spheroid(d=ball_d, anchor=CENTER);
		}
		translate([stand_hand_ball_x, stand_hand_ball_y]) {
			zcyl(d=ball_cyl_d, h=ball_d/2+ball_cyl_h, anchor=BOTTOM);
			spheroid(d=ball_d, anchor=CENTER);
		}
	}

	// TODO consider a left-edge mount onto the keyboard, so the keyboard's feet can be used as the desk grip feet
	

}

//import("iris-PE-bottom-plate_outline.dxf.svg", center=true);

module make_sizing_grid() {
	/*difference() {
		linear_extrude(height = 0.4) import_outline();

		grid_copies(spacing = 5, size = 250) zcyl(d=4, h=100, $fn=24);
	}*/

	grid_test_h = 0.4;

	linear_extrude(height = grid_test_h) difference() {
		import_outline();
		offset(-0.45) import_outline();
	}

	intersection() {
		union() {
			xcopies(spacing = 5, n = 51) cuboid([0.45, 1000, grid_test_h], anchor=BOTTOM);
			ycopies(spacing = 5, n = 51) cuboid([1000, 0.45, grid_test_h], anchor=BOTTOM);
			
			xcopies(spacing = 50, n = 11) cuboid([0.45, 1000, grid_test_h*2], anchor=BOTTOM);
			ycopies(spacing = 50, n = 11) cuboid([1000, 0.45, grid_test_h*2], anchor=BOTTOM);

			zrot(45) cuboid([0.45, 1000, grid_test_h], anchor=BOTTOM);
			zrot(-45) cuboid([0.45, 1000, grid_test_h], anchor=BOTTOM);
		}
		linear_extrude(height = 100) import_outline();
	}

	zcyl(d=10, h=1, $fn=12, anchor=BOTTOM);
	zcyl(d=2, h=1.8, anchor=BOTTOM);

}

module fuzzy_region_modifier() {
	fuzzy_rounding = 4;

	// bottom-right
	translate([63.5, -45, 0]) up(1) zrot(-30) cuboid([4, 45, total_h-2], rounding=fuzzy_rounding, except=[RIGHT, LEFT], anchor=BOTTOM+LEFT);

	// center bottom region
	translate([-15, -43, 0]) up(1) cuboid([4, 12, total_h-2], rounding=fuzzy_rounding, except=[RIGHT, LEFT], anchor=BOTTOM+LEFT);

	// left edge
	translate([-80.5, -3, 0]) up(1) cuboid([4, 55, total_h-2], rounding=fuzzy_rounding, except=[RIGHT, LEFT], anchor=BOTTOM+LEFT);
}

module make_balls() {
	difference() {
		_make_ball_outside(true);
		// up(ball_d/2)
        zcyl(d=3, h=100, anchor=BOTTOM);
	}
}

module _make_ball_outside(clip_cone) {
    // When clip_cone=true, the cones are clipped (for the actual balls)
    // When clip_cone=false, the cones extend all the way out (for creating the void in the rigid case)
    intersection() {
        union() {
            zcyl(
                d1=2, d2=foot_max_d,
                h=3.5,
                anchor=BOTTOM
            );
            up(3.5) zcyl(
                d1=foot_max_d,
                d2=ball_d,
                h=2,
                anchor=BOTTOM
            );
        }
        if (clip_cone)
            zcyl(d=foot_max_d_cyl, h=100);
    }
	spheroid(d=ball_d, anchor=CENTER);
}
