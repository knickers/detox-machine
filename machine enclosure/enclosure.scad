// Resolution
$fs = 2; // [1:High, 2:Medium, 4:Low]
$fa = 0.01 + 0;
e = 0.005 + 0;

part = "Bottom"; // [Combined, Separated, Top, Bottom]
clip = "None"; // [None, Right, Left, Front, Back]

// Outer Width
width = 140; // [50:1:200]

// Outer Depth
depth = 100; // [50:1:150]

// Outer Height
height = 40; // [10:1:100]

Front_Radius = 40; // [1:1:50]
Back_Radius = 11; // [1:1:50]
Chamfer_Size = 10; // [0:1:30]
Draft_Angle = 8.53; // [0:0.01:22.5]

// Wall Thickness
wall = 2; // [1:0.5:5]


/* [Encolsure Case] */
/* [Encolsure Bottom] */




difference() {
	if (part == "Combined") {
		difference() {
			union() {
			}
			cube(width);
		}
	}
	else if (part == "Separated") {
	}
	else if (part == "Top") {
			top();
	}
	else if (part == "Bottom") {
		bottom();
	}

	if (clip == "Right") {
		translate([0, -depth/2-1, -1])
			cube([width/2+1, depth+2, height+2]);
	}
	else if (clip == "Left") {
		translate([-width/2-1, -depth/2-1, -1])
			cube([width/2+1, depth+2, height+2]);
	}
	else if (clip == "Front") {
		translate([-width/2-1, -depth/2-1, -1])
			cube([width+2, depth/2+1, height+2]);
	}
	else if (clip == "Back") {
		translate([-width/2-1, 0, -1])
			cube([width+2, depth/2+1, height+2]);
	}
}

module perimeter() {
	hull() {
		translate([-width/2+Back_Radius, +depth/2-Back_Radius, 0])
			circle(Back_Radius);

		translate([+width/2-Back_Radius, +depth/2-Back_Radius, 0])
			circle(Back_Radius);

		translate([-width/2+Front_Radius, -depth/2+Front_Radius, 0])
			circle(Front_Radius);

		translate([+width/2-Front_Radius, -depth/2+Front_Radius, 0])
			circle(Front_Radius);
	}
}

module main_shape(height, offset=0) {
	difference() {
		linear_extrude(height)
			offset(offset)
				perimeter();
		translate([0, depth/2, height])
			rotate(Draft_Angle, [1,0,0])
				translate([0, -depth/2, height/2])
					cube([width+2, depth*1.5, height], center=true);
	}
}

module body(height, chamfer_size, offset=0) {
	translate([0, depth/2, height-chamfer_size-e])
		rotate(Draft_Angle, [1,0,0])
			translate([0, -depth/2, 0])
				linear_extrude(chamfer_size, scale=[
					(width-chamfer_size*2)/width,
					(depth-chamfer_size*2)/depth
				])
					translate([0, depth/2, 0])
						projection(cut=true)
							rotate(-Draft_Angle, [1,0,0])
								translate([0, -depth/2, -height+1])
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

module fillet() {
	R = wall*0.9;

	// Right Side
	translate([width/2-R, depth/2, R])
		rotate(90, [1,0,0])
			arch(R, depth);

	// Left Side
	translate([-width/2+R, depth/2, R])
		rotate(90, [1,0,0])
			rotate(-90, [0,0,1])
				arch(R, depth);

	// Front Side
	translate([-width/2+R, depth/2, R])
		rotate(90, [1,0,0])
			rotate(90, [0,0,1])
				#arch(R, depth);
}

module top() {
	difference() {
		body(height, Chamfer_Size);
		translate([0, 0, -wall])
			body(height, Chamfer_Size-wall*4/5, -wall);
		fillet();
	}
}

module bottom() {
	linear_extrude(wall)
		offset(-wall)
			perimeter();
}
