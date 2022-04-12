Outer_Width = 65;
width = Outer_Width;

Outer_Length = 50;
length = Outer_Length;

Outer_Height = 8;
height = Outer_Height;

Corner_Radius = 5;
radius = Corner_Radius;

Wall_Thickness = 1;
wall = Wall_Thickness;

Larger_Diameter = 76;
large = Larger_Diameter / 2; // convert to radius

Smaller_Diameter = 64;
small = Smaller_Diameter / 2; // convert to radius

Pipe_Thickness = 1.3;
Wing_Distance = 5;
Wing_Separation = 7;
Wing_Angle = 30;
Wing_Offset = length/2-Wing_Distance;

Wire_Size = 2;

Curve_Resolution = 1; // [1:High, 2:Medium, 4:Low]
$fs = Curve_Resolution;
$fa = 0.01 + 0;

part = "Combined"; // [Tray, Slots, Combined]

if (part == "Tray") {
	tray();
}
else if (part == "Slots") {
	difference() {
		slots("positive");
		slots("negative");
	}
}
else if (part == "Combined") {
	difference() {
		union() {
			tray();
			slots("positive");
		}

		slots("negative");
	}
}

module arch(thickness, length, radius, additional_rotation=0) {
	rotate(Wing_Angle, [1,0,0])                          // Rotate to wing angle
		translate([0, radius, 0])                        // Move to origin
			rotate(-90, [0,0,1])                         // Align with tray
				rotate(90, [1,0,0])                      // Turn upright
					rotate(additional_rotation, [0,0,1]) // Additional rotation
						rotate_extrude(angle=35)         // Create body
							translate([radius, 0, 0])    // Arch radius
								square([thickness, length]); // Arch shape
}

module slot_positive() {
	translate([0, Wing_Offset+wall, 0]) {
		arch(Pipe_Thickness+wall*2, width/2, small-wall); // Small Wing

		translate([0, -Pipe_Thickness, 0]) {
			arch(Wing_Separation, width/2, small+Pipe_Thickness); // Water Hole

			translate([0, -Wing_Separation, 0])
				arch(Pipe_Thickness+wall*2, width/2, large-wall); // Large Wing
		}
	}
}
module slot_negative() {
	translate([wall, Wing_Offset, 0]) {
		#arch(Pipe_Thickness, width/2, small); // Small Wing

		translate([0, -wall-Pipe_Thickness, 0]) {
			translate([0, wall-Wing_Separation, 0])
				#arch(Pipe_Thickness, width/2, large); // Large Wing
		}
	}
}

module slot(where="positive") {
	if (where == "positive") {
		difference() {
			slot_positive();
			slot_negative();
		}
	}
	else { // if (where == "negative") {
		translate([-wall, Wing_Offset-wall-Pipe_Thickness, 0])
			arch(Wing_Separation-wall*2,
				width/2-wall*2,
				small+Pipe_Thickness+wall,
				-1
			);
	}
}

module slots(where="positive") {
	difference() {
		union() {
			slot(where);
			mirror([0,1,0])
				slot(where);
		}

		translate([0, 0, height*1.5+height])
			cube([width*2, length*2, height*3], true);
		translate([0, 0, -height])
			cube([width*2, length*2, height], true);
	}
}

module tray() {
	difference() {
		linear_extrude(height)
			perimeter();

		translate([0, 0, wall])
			linear_extrude(height)
				offset(-wall)
					perimeter();

		translate([-width/2+wall+1, 0, Wire_Size/2+wall])
			rotate(-90, [0,1,0])
				cylinder(d=Wire_Size, h=wall+2, $fs=$fs*0.75);
	}
}

module perimeter() {
	x = width/2-radius;
	y = length/2-radius;
	hull() {
		translate([-x, +y, 0]) circle(radius);
		translate([+x, +y, 0]) circle(radius);
		translate([-x, -y, 0]) circle(radius);
		translate([+x, -y, 0]) circle(radius);
	};
}
