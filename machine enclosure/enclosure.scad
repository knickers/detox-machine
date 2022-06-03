// Resolution
$fs = 2; // [1:High, 2:Medium, 4:Low]
$fa = 0.01 + 0;

part = "Bottom"; // [Combined, Separated, Top, Bottom]

/* [Encolsure Case] */

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

/* [Encolsure Bottom] */




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
	difference() {
		top();
		translate([0, -depth, -1])
			cube([width, depth*2, height+2]);
	}
}
else if (part == "Bottom") {
	bottom();
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

module angled_chamfer(chamfer_size, offset=0) {
	/*
	*/
	translate([0, depth/2, 0])
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

module top() {
	/*
	difference() {
		linear_extrude(height)
			difference() {
				perimeter();
				offset(-wall)
					perimeter();
			}
	}
	*/
	/*
	difference() {
		union() {
			translate([0, 0, height-Chamfer_Size])
				angled_chamfer(Chamfer_Size);
			main_shape(height-Chamfer_Size);
		}
		translate([0, 0, height-Chamfer_Size])
			angled_chamfer(Chamfer_Size-wall, -wall);
		main_shape(height-Chamfer_Size, -wall);
	}
	*/
	difference() {
		union() {
			translate([0, 0, height-Chamfer_Size])
				angled_chamfer(Chamfer_Size);
			main_shape(height-Chamfer_Size);
		}
		scale([
			(width-wall*1)/width,
			(depth-wall*2)/depth,
			(height-wall)/height
		]) {
			translate([0, 0, height-Chamfer_Size])
				angled_chamfer(Chamfer_Size);
			main_shape(height-Chamfer_Size);
		}
	}
}

module bottom() {
	linear_extrude(wall)
		offset(-wall)
			perimeter();
}
