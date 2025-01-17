include <BOSL2/std.scad>;

// Fuzzy Skin Settings:
// Distance: 0.7mm
// Thickness: 1.0mm

//filename = "../Iris PE Middle Layer - Normal No Lip for 1.5mm Plate.stl";
filename = "../Iris PE Middle Layer - Normal No Lip for 1.5mm Plate - Centered.stl";
outline_filename = "openscad_gen - Iris PE Normal No Lip Outline.dxf";

import_size_x = 157.44;
import_size_y = 137.69;
import_size_z = 11;

tilt_angle_deg = 20;
tilt_angle_deg_vector = [0, -20, 0];

screw_depth = 8-1; // screw len minus FR4 plate thickness
screw_d = 1;

ball_d = 6;
ball_cyl_d = 3.5;
ball_cyl_h = 1;

holes_xy = [[-7, -47.9], [-72.8, -29], [-73, 51.3], [-7, 63.7], [17.9, 62.8], [46.1, 53.2], [46.6, 9], [61.9, -14.4], [72.5, -21.8], [49, -62.6]];
ball_loc_xy = [[-7, -47.9], [-72.8, -29], [-72.9, (51.3-29)/2], [-73, 51.3], [-7, 63.7], [46.1, 53.2], [46.6, 9], [72.5, -21.8], [49, -62.6]];

// bot_left_ball_xy = [-72.8, -29]; // for indexing the reset switch position

bot_t_total = 1.5;
bot_overlap = 1;
bot_t_nonoverlap = bot_t_total - bot_overlap;

total_h = import_size_z + bot_t_nonoverlap;


echo("Amount of screw that goes into the ball part below: ", -(total_h-screw_depth-ball_d/2-ball_cyl_h), " (negative means not intersecting)");

$fn = 100;


//import_outline();

//create_plate();
make_main_case();
//make_balls();

//make_sizing_grid();
//fuzzy_region_modifier();

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
				zcyl(d=ball_cyl_d+4, h=ball_d/2+ball_cyl_h+2, anchor=BOTTOM);
				intersection() {
					spheroid(d=ball_d+4, anchor=CENTER, $fn=50);
					cuboid([1000, 1000, 1000], anchor=BOTTOM);
				}
			}
		}

		// remove screw holes to top board
		for (xy = holes_xy) translate([xy[0], xy[1], 0]) {
			up(total_h) zcyl(d=screw_d, h=screw_depth, anchor=TOP);
			up(total_h) zcyl(d1=screw_d, d2=2, h=0.8, anchor=TOP); // add registration hole for easy screwing
		}

		// remove reset/programming hole
		//translate([-import_size_x/2 + 83.7, import_size_y/2 - 52.5, 0]) zcyl(d=12, h=100);
		echo("Programming hole location (original): ", -import_size_x/2 + 83.7, import_size_y/2 - 52.5); //  4.98, 16.345
		//% translate([-import_size_x/2 + 83.7, import_size_y/2 - 52.5, 0]) cuboid([8, 8, 30], rounding=2.5, except=[TOP, BOTTOM]);
		translate([5.27, 15.98, 0]) zcyl(d=7, h=50); //cuboid([8, 8, 30], rounding=2.5, except=[TOP, BOTTOM]);
	
		// remove places for balls
		for (xy = ball_loc_xy) translate([xy[0], xy[1], 0]) {
			zcyl(d=ball_cyl_d, h=ball_d/2+ball_cyl_h, anchor=BOTTOM);
			spheroid(d=ball_d, anchor=CENTER);
		}

	}

}

module create_plate() {
	rot(tilt_angle_deg_vector, cp=[-import_size_x/2, 0, 0])

	//linear_extrude(height = 5) import_outline(); 

	//extrude_from_to([import_size_x/2, import_size_y/2, 0], [import_size_x/2, import_size_y/2, 20], twist=10) import_outline();
	
	difference() {
		translate([-import_size_x/2, -import_size_y/2, 0]) xflip() zrot(180) xrot(90)
			rotate_extrude(angle=tilt_angle_deg, $fn=1000)
			translate([import_size_x/2+0.001, import_size_y/2+0.001, 0]) import_outline();

		translate([-import_size_x/2, -import_size_y/2, 0]) yrot(1) xflip() zrot(180) xrot(90)
			rotate_extrude(angle=tilt_angle_deg+3, $fn=1000)
			translate([import_size_x/2+0.001, import_size_y/2+0.001, 0]) offset(r=-10) import_outline();

	}

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
	zcyl(d=ball_cyl_d - 0.5, h=ball_d/2+ball_cyl_h - 0.6, anchor=BOTTOM);
	spheroid(d=ball_d, anchor=CENTER);

}

