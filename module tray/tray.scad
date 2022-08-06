Tray_Outer_Width = 65.0;
width = Tray_Outer_Width;

Tray_Outer_Length = 50.0;
length = Tray_Outer_Length;

Tray_Height = 8.0;
height = Tray_Height;

Tray_Corner_Radius = 5.0;
radius = Tray_Corner_Radius;

Tray_Wall_Thickness = 1.0;
wall = Tray_Wall_Thickness;

Tray_Floor_Thickness = 0.6;

Large_Pipe_Diameter = 76.2;
large = Large_Pipe_Diameter / 2; // convert to radius
Large_Pipe_Angle = 30;

Small_Pipe_Diameter = 63.5;
small = Small_Pipe_Diameter / 2; // convert to radius
Small_Pipe_Angle = 32;

Pipe_Wall_Thickness = 1.3;
Wing_Distance = 5.0;
Wing_Separation = 7.0;
Wing_Offset = length/2-Wing_Distance;

Slot_Distance = 5;
Slot_Length = 40;
Slot_Offset = Slot_Length + Slot_Distance - width/2;
Slot_Height = 2;

Wire_Size = 2.1;

Curve_Resolution = 1; // [1:High, 2:Medium, 4:Low]
$fs = Curve_Resolution;
$fa = 0.01 + 0;

part = "Combined"; // [Tray, Slot, Slots, Combined]

if (part == "Tray") {
	tray();
}
else if (part == "Slot") {
	difference() {
		slot_positive();
		slot_negative();
	}
}
else if (part == "Slots") {
	slots();
}
else if (part == "Combined") {
	tray();
	slots();
}

module arch(thickness, length, radius, cutoff, rotation, angle=90, additional_rotation=0){
	rotate(rotation, [1,0,0])                          // Rotate to wing angle
		translate([0, radius, 0])                        // Move to origin
			rotate(-90, [0,0,1])                         // Align with tray
				rotate(90, [1,0,0])                      // Turn upright
					rotate(additional_rotation, [0,0,1])
						rotate_extrude(angle=angle)      // Create body
							translate([radius, 0, 0])    // Arch radius
								square([thickness, length]); // Arch shape
}

module slot_plug() {
	w = Wing_Separation + Pipe_Wall_Thickness*2 + wall*6;
	s = tan(Small_Pipe_Angle) * (height+1) - 1.5;
	l = tan(Large_Pipe_Angle) * (height+1) - 1.5;
	translate([0, length/2-w-Wing_Distance+wall*2.5, 0])
		rotate(90, [0,0,1])
			rotate(90, [1,0,0])
				linear_extrude(wall)
					polygon([
						[w-s, height+Slot_Height], // Q1
						[0-l, height+Slot_Height], // Q2
						[0, 0], // Q3
						[w, 0]  // Q4
					]);
}

module slot_positive() {
	difference() {
		union() {
			translate([Slot_Offset, Wing_Offset+wall, 0]) {
				// Small wing
				arch(Pipe_Wall_Thickness+wall*2,
					Slot_Length,
					small-wall,
					height-1,
					Small_Pipe_Angle,
					30 // arch arc
				);

				// Large wing
				translate([0, -Pipe_Wall_Thickness-Wing_Separation, 0])
					arch(Pipe_Wall_Thickness+wall*2,
						Slot_Length,
						large-wall,
						height-1,
						Large_Pipe_Angle,
						30
					);
			}

			translate([Slot_Offset-1, 0, 0])
				slot_plug();

			translate([Slot_Offset+wall-1-Slot_Length, 0, 0])
				slot_plug();
		}

		// Level off the top
		translate([Slot_Distance-width/2-1, 0, height+Slot_Height])
			cube([Slot_Length+2, length/2, large ]);

		l = tan(Small_Pipe_Angle) * (height);

		// Cut off the top outside corner
		multmatrix(m=[
			[1, 0, 0,                          Slot_Distance-width/2-1],
			[0, 1, -cos(Small_Pipe_Angle*2.3), length/2-Wing_Distance-l+1],
			[0, 0, 1,                          height-2],
			[0, 0, 0,                          1],
		])
			cube([Slot_Length+2, wall*5, 4]);

		L = tan(Large_Pipe_Angle) * (height);

		// Cut off the top inside corner
		multmatrix(m=[
			[1, 0, 0,                          Slot_Distance-width/2-1],
			[0, 1, -cos(Large_Pipe_Angle*2.4), length/2-Wing_Distance-Wing_Separation-Pipe_Wall_Thickness*4.9-L+1],
			[0, 0, 1,                          height-2],
			[0, 0, 0,                          1],
		])
			cube([Slot_Length+2, Pipe_Wall_Thickness*4, 4]);

		// Flatten the bottom of the arches
		translate([
			Slot_Distance-width/2-1,
			length/2-Pipe_Wall_Thickness*2-Wing_Distance-Wing_Separation-wall*2,
			-Pipe_Wall_Thickness*2
		])
			cube([
				Slot_Length+2,
				Pipe_Wall_Thickness*2 + Wing_Separation + wall*4,
				Pipe_Wall_Thickness*2
			]);
	}
}
module slot_negative() {
	translate([Slot_Offset+1, Wing_Offset, 0]) {
		// Small Wing
		#arch(Pipe_Wall_Thickness,
			Slot_Length+2,
			small,
			Small_Pipe_Diameter,
			Small_Pipe_Angle
		);

		translate([0, -Pipe_Wall_Thickness-Wing_Separation, 0]) {
			// Large Wing
			#arch(Pipe_Wall_Thickness,
				Slot_Length+2,
				large,
				Large_Pipe_Diameter,
				Large_Pipe_Angle
			);
		}
	}
}

module slot() {
	difference() {
		slot_positive();
		slot_negative();
	}
}

module slots() {
	slot();
	mirror([0,1,0])
		slot();
}

module slot_cutout() {
	translate([Slot_Offset-wall, Wing_Offset-wall-Pipe_Wall_Thickness, 0])
		arch(Wing_Separation-wall*2.75,
			Slot_Length-wall*2,
			small+Pipe_Wall_Thickness+wall,
			large,
			Small_Pipe_Angle+(Large_Pipe_Angle-Small_Pipe_Angle)/2+2,
			30,
			-1
		);
}

module tray() {
	difference() {
		linear_extrude(height)
			perimeter();

		// Cutout the main tray cavity
		translate([0, 0, Tray_Floor_Thickness])
			linear_extrude(height)
				offset(-wall)
					perimeter();

		// The wire hole
		translate([-width/2+wall+1, 0, Wire_Size/2+Tray_Floor_Thickness])
			rotate(-90, [0,1,0])
				cylinder(d=Wire_Size, h=wall+2, $fs=$fs*0.65);

		// Slot cutouts
		slot_cutout();
		mirror([0,1,0])
			slot_cutout();
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
