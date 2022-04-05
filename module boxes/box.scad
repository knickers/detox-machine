// Outer Width
width = 65; // [0:1:200]

// Outer Depth
depth = 50; // [1:1:200]

// Outer Height
height = 10; // [1:1:200]

radius = 5; // [0:1:50]

wall = 1; // [0:0.5:5]

slot_a = 20;
slot_y = depth/3;

// Resolution
$fs = 2; // [1:High, 2:Medium, 4:Low]
$fa = 0.01 + 0;

part = "Box"; // [Box, Slot, Combined]

if (part == "Box") {
	box();
}
else if (part == "Slot") {
	difference() {
		slot();
		slot_negative();
	}
}
else if (part == "Combined") {
	difference() {
		union() {
			box();
			slot();
		}

		slot_negative();
	}
}

module slot(where="additive") {
	x = width*.75+wall*2;
	y = 5+wall*2;
	translate([0, -slot_y, 0])
		rotate(-slot_a, [1,0,0])
			translate([-x/2, 0, 0])
				cube([x, y, height*2]);
}
module slot_negative() {
	x = width*.75;
	y = 5;
	translate([0, -slot_y, 0]) {
		rotate(-slot_a, [1,0,0]) {
			translate([-x/2, wall, -1])
				cube([x, y, height*2+2]);    // Cutout Center
			translate([-width/2-1, wall, 0])
				cube([width+2, y, height]);  // Cutout Sides
		}
		translate([-width/2, 0, height+wall])
			cube([width, depth, height]);    // Flatten Top
		translate([-width/2, 0, -height])
			cube([width, depth, height]);    // Flatten Bottom
	}
}

module box() {
	difference() {
		linear_extrude(height)
			perimeter();

		translate([0, 0, wall])
			linear_extrude(height)
				offset(-wall)
					perimeter();
	}
}

module perimeter() {
	x = width/2-radius;
	y = depth/2-radius;
	hull() {
		translate([-x, +y, 0]) circle(radius);
		translate([+x, +y, 0]) circle(radius);
		translate([-x, -y, 0]) circle(radius);
		translate([+x, -y, 0]) circle(radius);
	};
}
