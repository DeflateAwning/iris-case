include <BOSL2/std.scad>

/* Print Settings:
- Fuzzy Skin: Outside Walls
- Fuzzy Skin Thickness: 0.5mm
- Fuzzy Skin Point Distance: 0.8mm
*/

knob_od_bottom = 15;
knob_h_bottom = 14;

knob_taper_h = 3;
knob_top_od = 20;
knob_top_h = 5;

knob_peg_d = 5.6; // real: 5.8
knob_peg_h = 20; // real: a little less

dimple_d = 8;
dimple_h = 3;

$fn = 60;

make_rotary_encoder_knob();

module make_rotary_encoder_knob() {
	difference() {
		union() {
			zcyl(d=knob_od_bottom, h=knob_h_bottom, anchor=BOTTOM);

			up(knob_h_bottom) {
				zcyl(d1=knob_od_bottom, d2=knob_top_od, h=knob_taper_h, anchor=BOTTOM);

				up(knob_taper_h) {
					zcyl(d=knob_top_od, h=knob_top_h, anchor=BOTTOM);
				}
			}


		}

		// remove peg
		zcyl(d=knob_peg_d, h=knob_peg_h, anchor=BOTTOM);

		// remove sphere at the top
		up(knob_h_bottom + knob_taper_h + knob_top_h) {
			up(1) zscale(dimple_h/dimple_d) sphere(d=dimple_d, $fn=60);
		}
	}
} 
