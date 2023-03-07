// Resolution
$fs = 2; // [1:High, 2:Medium, 4:Low]
$fa = 0.01 + 0;
e = 0.005 + 0;

Part = "Top"; // [Combined, Separated, Top, Bottom]
Clipping_Plane = "None"; // [None, Right, Left, Front, Back]
Tolerance = 0.1;


/* [Enclosure] */
Width = 140;
Depth = 100;
Height = 40;
Front_Radius = 40;
Back_Radius = 11;
Chamfer_Size = 10;
Draft_Angle = 8.53;
Wall_Thickness = 2;


/* [Switch] */
Switch_Diameter = 19.75;
Switch_Key_Width = 2.25;
Switch_Key_Depth = 1.25;
Switch_Clasp_Width = 4.25;
Switch_Clasp_Depth = 2.00;


/* [Meter] */
Meter_Width = 45.50;
Meter_Depth = 26.50;
Meter_Clasp_Width = 25.00;
Meter_Clasp_Depth = 0.50;


/* [Jack] */
Jack_Diameter = 11.25;


/* [Text] */
Text_Depth = 1.00;
Text_Height = 5.00;


/* [Symbol] */
Symbol_Depth = 1.00;
Symbol_Height = 15.00;
Logo_Height = 42;


/* [Latch] */
Latch_Width = 4.00;
Latch_Depth = 1.00;




difference() {
	if (Part == "Combined") {
		top();
		bottom();
	}
	else if (Part == "Separated") {
		translate([-Width/2 - 5, 0, 0])
			top();
		translate([Width/2 + 5, 0, 0])
			bottom();
	}
	else if (Part == "Top") {
		top();
	}
	else if (Part == "Bottom") {
		bottom();
	}

	if (Clipping_Plane == "Right") {
		translate([0, -Depth/2-1, -1])
			cube([Width/2+1, Depth+2, Height+2]);
	}
	else if (Clipping_Plane == "Left") {
		translate([-Width/2-1, -Depth/2-1, -1])
			cube([Width/2+1, Depth+2, Height+2]);
	}
	else if (Clipping_Plane == "Front") {
		translate([-Width/2-1, -Depth/2-1, -1])
			cube([Width+2, Depth/2+1, Height+2]);
	}
	else if (Clipping_Plane == "Back") {
		translate([-Width/2-1, 0, -1])
			cube([Width+2, Depth/2+1, Height+2]);
	}
}

module top() {
	difference() {
		body(Height, Chamfer_Size);
		translate([0, 0, -Wall_Thickness])
			body(Height, Chamfer_Size-Wall_Thickness*2/5, -Wall_Thickness);

		if (!$preview)
			fillet(); // Around the bottom perimeter

		face();

		back();

		latches("negative");
	}

	supports();
}

module bottom() {
	linear_extrude(Wall_Thickness)
		offset(-Wall_Thickness-Tolerance)
			perimeter();
	latches("positive", -Tolerance);
}

module perimeter() {
	hull() {
		translate([-Width/2+Back_Radius, +Depth/2-Back_Radius, 0])
			circle(Back_Radius);

		translate([+Width/2-Back_Radius, +Depth/2-Back_Radius, 0])
			circle(Back_Radius);

		translate([-Width/2+Front_Radius, -Depth/2+Front_Radius, 0])
			circle(Front_Radius);

		translate([+Width/2-Front_Radius, -Depth/2+Front_Radius, 0])
			circle(Front_Radius);
	}
}

module body(height, chamfer_size, offset=0) {
	// Main, top face, with chamfer
	translate([0, Depth/2, height-chamfer_size-e])
		rotate(Draft_Angle, [1,0,0])
			translate([0, -Depth/2, 0])
				linear_extrude(chamfer_size, scale=[
					(Width-chamfer_size*2)/Width,
					(Depth-chamfer_size*2)/Depth
				])
					translate([0, Depth/2, 0])
						projection(cut=true)
							rotate(-Draft_Angle, [1,0,0])
								translate([0, -Depth/2, -height+1])
									linear_extrude(height)
										offset(offset)
											perimeter();

	difference() {
		// Wall of body
		linear_extrude(height-chamfer_size)
			offset(offset)
				perimeter();

		// Cut off the top at draft_angle
		translate([0, Depth/2, height-chamfer_size])
			rotate(Draft_Angle, [1,0,0])
				translate([0, -Depth/2, chamfer_size])
					cube([Width+2, Depth*1.5, chamfer_size*2], center=true);
	}
}

module arch(radius, length) {
	difference() {
		translate([0, -radius-1, 0])
			cube([radius+1, radius+1, length]);
		cylinder(r=radius, h=length, $fs=$fs/2);
	}
}
module arc(r1, r2) {
	difference() {
		translate([0, 0, -r1-1])
			cube([r1+r2, r1+r2, r1+1]);
		rotate_extrude(angle=90, convexity=4)
			translate([r2, 0, 0])
				circle(r=r1, $fs=$fs/2);
		translate([0, 0, -r1-2])
			cylinder(r=r2, h=r1+3);
	}
}

module fillet() {
	R = Wall_Thickness*0.9;

	// Right Side
	translate([Width/2-R, Depth/2, R])
		rotate(90, [1,0,0])
			arch(R, Depth);

	// Left Side
	translate([-Width/2+R, Depth/2, R])
		rotate(90, [1,0,0])
			rotate(-90, [0,0,1])
				arch(R, Depth);

	// Front Side
	translate([-Width/2, -Depth/2+R, R])
		rotate(90, [0,1,0])
			arch(R, Width);

	// Back Side
	translate([-Width/2, Depth/2-R, R])
		rotate(90, [0,1,0])
			rotate(90, [0,0,1])
				arch(R, Width);

	// Q1
	translate([Width/2-Back_Radius, Depth/2-Back_Radius, R])
		arc(R, Back_Radius-R);

	// Q2
	translate([-Width/2+Back_Radius, Depth/2-Back_Radius, R])
		rotate(90, [0,0,1])
			arc(R, Back_Radius-R);

	// Q3
	translate([-Width/2+Front_Radius, -Depth/2+Front_Radius, R])
		rotate(180, [0,0,1])
			arc(R, Front_Radius-R);

	// Q4
	translate([Width/2-Front_Radius, -Depth/2+Front_Radius, R])
		rotate(-90, [0,0,1])
			arc(R, Front_Radius-R);
}

module switch() {
	cylinder(d=Switch_Diameter, h=Wall_Thickness+2);

	translate([-Switch_Clasp_Width/2, -Switch_Clasp_Depth-Switch_Diameter/2, 0])
		cube([
			Switch_Clasp_Width,
			Switch_Clasp_Depth*2 + Switch_Diameter,
			Wall_Thickness+2
		]);

	translate([-Switch_Key_Depth-Switch_Diameter/2, -Switch_Key_Width/2, 0])
		cube([
			Switch_Key_Depth*2,
			Switch_Key_Width,
			Wall_Thickness+2
		]);
}

module meter() {
	translate([-Meter_Width/2, -Meter_Depth/2, 0])
		cube([
			Meter_Width,
			Meter_Depth,
			Wall_Thickness+2
		]);

	translate([
		-Meter_Clasp_Width/2,
		-Meter_Clasp_Depth - Meter_Depth/2,
		0
	])
		cube([
			Meter_Clasp_Width,
			Meter_Clasp_Depth*2 + Meter_Depth,
			Wall_Thickness+2
		]);
}

module symbol(file_name, svg_width, svg_height, size=Symbol_Height) {
	translate([-size * svg_width / svg_height / 2, 0, -Symbol_Depth])
		linear_extrude(Symbol_Depth+1)
			scale(size / svg_height)
				import(file_name, convexity=6);
}

module face() {
	x = Width/2 - Wall_Thickness - Front_Radius*0.75;
	y = Depth/2 + Wall_Thickness - Front_Radius*0.8;

	translate([0, Depth/2, Height-Wall_Thickness])
		rotate(Draft_Angle, [1,0,0])
			translate([0, -Depth/2, -1]) {
				translate([0, Depth/2-Meter_Depth/2-Chamfer_Size*1.75, 0])
					meter();
				translate([-x, -y, 0]) // Left Switch
					switch();
				translate([x, -y, 0]) // Right Switch
					switch();
				translate([-x, -y+Switch_Diameter-3, Wall_Thickness+1])
					symbol("symbol-standby.svg", 46.408, 53.102);
				translate([x, -y+Switch_Diameter-3, Wall_Thickness+1])
					symbol("symbol-plus-minus.svg", 70.556, 97.639);
				translate([0, -y-Switch_Diameter, Wall_Thickness+1])
					symbol("../logo-phoenix-health-2mm-paths-union.svg", 446.422, 497.29, Logo_Height);
			}
}

module back() {
	x = Width/4 - Back_Radius/2;
	w_ion = 52/6; // "ION MODULE" is 52 mm wide when Text_Height is 6
	w_pwr = 62/6; // "POWER 15 VDC" is 62 mm wide when Text_Height is 6

	translate([0, Depth/2+1, Height/2-Chamfer_Size/2])
		rotate(90, [1,0,0]) {
			translate([x, 0, 0])
				cylinder(d=Jack_Diameter, h=Wall_Thickness+2); // Right Jack
			translate([-x, 0, 0])
				cylinder(d=Jack_Diameter, h=Wall_Thickness+2); // Left Jack

			translate([Width/2-Back_Radius, Jack_Diameter/2+2, Text_Depth+1])
				rotate(180, [0, 1, 0])
					linear_extrude(Text_Depth+1)
						#text("ION MODULE", size=Text_Height);

			translate([-Width/2+Back_Radius+Text_Height*w_pwr, Jack_Diameter/2+2, Text_Depth+1])
				rotate(180, [0, 1, 0])
					linear_extrude(Text_Depth+1)
						#text("POWER 15 VDC", size=Text_Height);
		}
}

module wedge(width, height, length) {
	rotate(-90, [1,0,0])
		linear_extrude(length)
			polygon([
				[0, 0],       // origin
				[0, -height], // top
				[width, 0]    // right
			]);
}

module latches(where, offset=0) {
	width  = Latch_Depth + Tolerance * (where == "negative" ? 1 : 0);
	height = Latch_Depth + Tolerance * (where == "negative" ? 1 : 0);
	length = Latch_Width + Tolerance * (where == "negative" ? 2 : -2);

	z = -height + Wall_Thickness;               // Z translation for all
	w = Width/2 - Wall_Thickness + offset - e;  // Width at side walls
	d = Depth/2 - Wall_Thickness + offset - e*3;// Depth at back and front walls

	// Right Side Back
	translate([w, Depth/2 - Back_Radius - Latch_Width, z])
		wedge(width, height, length);
	// Right Side Front
	translate([w, -Depth/2 + Front_Radius, z])
		wedge(width, height, length);
	// Left Side Back
	translate([-w, Depth/2 - Back_Radius - Latch_Width, z])
		mirror([1,0,0])
			wedge(width, height, length);
	// Left Side Front
	translate([-w, -Depth/2 + Front_Radius, z])
		mirror([1,0,0])
			wedge(width, height, length);

	// Back Center
	translate([length/2, d, z])
		rotate(90, [0,0,1])
			wedge(width, height, length);
	// Back Left
	translate([-Width/2+Back_Radius+length, d, z])
		rotate(90, [0,0,1])
			wedge(width, height, length);
	// Back Right
	translate([Width/2-Back_Radius, d, z])
		rotate(90, [0,0,1])
			wedge(width, height, length);

	// Front Right
	translate([Width/2-Front_Radius-length, -d, z])
		rotate(-90, [0,0,1])
			wedge(width, height, length);
	// Front Left
	translate([-Width/2+Front_Radius, -d, z])
		rotate(-90, [0,0,1])
			wedge(width, height, length);
}

module supports() {
	width  = Latch_Depth;
	height = Latch_Depth;
	length = Latch_Width * 3;

	z = Wall_Thickness;               // Z translation for all
	w = Width/2 - Wall_Thickness + e; // Width at side walls
	d = Depth/2 - Wall_Thickness + e; // Depth at back and front walls

	// Right Side Back
	translate([w, Depth/2 - Back_Radius - length*0.75, z])
		mirror([1,0,0])
			wedge(width, height, length);
	// Right Side Front
	translate([w, -Depth/2 + Front_Radius - length, z])
		mirror([1,0,0])
			wedge(width, height, length*2);
	// Left Side Back
	translate([-w, Depth/2 - Back_Radius - length*0.75, z])
		wedge(width, height, length);
	// Left Side Front
	translate([-w, -Depth/2 + Front_Radius - length, z])
		wedge(width, height, length*2);

	// Back Center
	translate([-length/2, d, z])
		rotate(-90, [0,0,1])
			wedge(width, height, length);
	// Back Left
	translate([-Width/2+Back_Radius-length*0.25, d, z])
		rotate(-90, [0,0,1])
			wedge(width, height, length);
	// Back Right
	translate([Width/2-Back_Radius-length*0.75, d, z])
		rotate(-90, [0,0,1])
			wedge(width, height, length);

	// Front Right
	translate([Width/2-Front_Radius+length, -d, z])
		rotate(90, [0,0,1])
			wedge(width, height, length*2);
	// Front Left
	translate([-Width/2+Front_Radius+length, -d, z])
		rotate(90, [0,0,1])
			wedge(width, height, length*2);
}
