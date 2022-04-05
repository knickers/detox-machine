// Outer Width
width = 140; // [50:1:200]

// Outer Depth
depth = 100; // [50:1:150]

// Outer Height
height = 40; // [10:1:100]

// Bottom Radius
radius = 40; // [0:1:50]

// Fillet Radius
fillet = 10;

// Wall Thickness
wall = 2; // [1:0.5:5]

// Resolution
$fs = 2; // [1:High, 2:Medium, 4:Low]
$fa = 0.01 + 0;

part = "Bottom"; // [Combined, Separated, Top, Bottom]

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

module top() {
	difference() {
		linear_extrude(height)
			difference() {
				perimeter();
				offset(-wall)
					perimeter();
			}

		/*
		translate([-width/2-1, -depth/2-1, height])
			cube([width+2, depth+2, height]);
		*/
	}
}

module bottom() {
	/*
	linear_extrude(wall)
		offset(-wall)
			perimeter();
	*/
	translate([0, 0, wall])
		rotate(180, [0, 1, 0])
			linear_extrude(height=wall, scale=0.97)
				perimeter();
}
module perimeter() {
	hull() {
		translate([-width/2+fillet, +depth/2-fillet, 0])
			circle(fillet);

		translate([+width/2-fillet, +depth/2-fillet, 0])
			circle(fillet);

		translate([-width/2+radius, -depth/2+radius, 0])
			circle(radius);

		translate([+width/2-radius, -depth/2+radius, 0])
			circle(radius);
	}
}
