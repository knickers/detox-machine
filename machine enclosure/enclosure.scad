// Resolution
$fs = 2; // [1:High, 2:Medium, 4:Low]
$fa = 0.01 + 0;
e = 0.005 + 0;

Part = "Top"; // [Combined, Separated, Top, Bottom]
Clipping_Plane = "None"; // [None, Right, Left, Front, Back]


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
Text_Height = 6.00;


/* [Latch] */
Latch_Width = 4.00;
Latch_Depth = 1.00;




difference() {
	if (Part == "Combined") {
		difference() {
			union() {
			}
			cube(Width);
		}
	}
	else if (Part == "Separated") {
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

module main_shape(height, offset=0) {
	difference() {
		linear_extrude(height)
			offset(offset)
				perimeter();
		translate([0, Depth/2, height])
			rotate(Draft_Angle, [1,0,0])
				translate([0, -Depth/2, height/2])
					cube([Width+2, Depth*1.5, height], center=true);
	}
}

module body(height, chamfer_size, offset=0) {
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
									main_shape(height, offset);

	main_shape(height-chamfer_size, offset);
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

module face() {
	sx = Width/2 - Front_Radius*0.75 - Wall_Thickness;
	sy = Depth/2 - Front_Radius + Wall_Thickness;

	translate([0, Depth/2, Height-Wall_Thickness])
		rotate(Draft_Angle, [1,0,0])
			translate([0, -Depth/2, -1]) {
				translate([sx, -sy, 0])
					switch();
				translate([-sx, -sy, 0])
					switch();
				translate([0, Depth/2-Meter_Depth/2-Chamfer_Size*1.75, 0])
					meter();
			}
}

module top() {
	difference() {
		body(Height, Chamfer_Size);
		translate([0, 0, -Wall_Thickness])
			body(Height, Chamfer_Size-Wall_Thickness*4/5, -Wall_Thickness);
		if (!$preview)
			fillet();
		face();
	}
}

module bottom() {
	linear_extrude(Wall_Thickness)
		offset(-Wall_Thickness)
			perimeter();
}
