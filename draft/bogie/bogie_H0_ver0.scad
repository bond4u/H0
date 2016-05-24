AXLE_DISTANCE = 23;
BOGIE_BOLSTER_HEIGHT = 7.9;

WHEEL_D = 11.5;

AXLE_HEIGHT = WHEEL_D / 2;
AXLE_INNER_SPACING = 11.5; // between that area only axle itself 

// spacing for axle/wheels to fit
SP_AXLE_LEN = 26;
SP_WHEEL_OUTER_DISTANCE = 21;
SP_WHEEL_DIAMETER = 14; //
SP_WHEEL_WIDTH = (SP_WHEEL_OUTER_DISTANCE-AXLE_INNER_SPACING)/2;
SP_AXLE_D = 3;
SP_AXLE_END_ANGLE_2 = 35; // _2 means half of the angle

SP_AXLE_END_LEN = (SP_AXLE_D / 2) / tan(SP_AXLE_END_ANGLE_2);

//

SIDE_THICKNESS = 3;
XXX_ROUNDNESS = 1;

_bogie();

module _bogie() {
    difference() {
        union() {
            translate([0,-SP_WHEEL_OUTER_DISTANCE/2])
                _sideRight();
            translate([0,SP_WHEEL_OUTER_DISTANCE/2])
                mirror([0,1,0])
                    _sideRight();

            // connecting sides... & following the standards since 2016
            difference() {
                union() {
                    translate([0,0,7])
                        cube([6, 16, 6], true);
                    translate([0,0,7])
                        cube([3, 25.5, 6], true);
                }
                cylinder(30, 2, 2, $fn=20);
            }
        };
        _totalAxleSpacing();
    }
}

module _sideRight() {
    difference() {
        union() {
            minkowski(){
                sphere(XXX_ROUNDNESS, $fn=8);
                rotate(90, [1,0,0])
                    translate([0,0,XXX_ROUNDNESS])
                        linear_extrude(SIDE_THICKNESS-2*XXX_ROUNDNESS)
                            offset(-XXX_ROUNDNESS)
                                _xxxProfile();
            };
            translate([-AXLE_DISTANCE/2, 0, AXLE_HEIGHT])
                _axleCover();
            translate([AXLE_DISTANCE/2, 0, AXLE_HEIGHT])
                _axleCover();
        }
        //
        translate([0,0,6.5])
            cube([6, 10, 4],true);
    }
    *translate([0,5.5,7.25])
        cube([AXLE_DISTANCE+SP_AXLE_D+2*1 ,1, 5.5], true);
}

module _axleCover() {
    rotate(90, [1,0,0])
        cylinder(SIDE_THICKNESS,2.5,2.5, $fn=20);
}

module _xxxProfile() {
    _xxxProfileHalf();
    mirror([1,0,0])
        _xxxProfileHalf();
}

module _xxxProfileHalf() {
    _y_up = 10;
    _y_down = 3;
    _x_max = AXLE_DISTANCE/2+5.5;
    _up_corner = 2.5;
    _wheelx_2 = 2;
    polygon([
        // *** uper row center
        [-0.01,_y_up],
        // move to right
        [_x_max-_up_corner,_y_up],
        [_x_max,_y_up-_up_corner],
        [_x_max,AXLE_HEIGHT],
        // around the axle holder
        [AXLE_DISTANCE/2+_wheelx_2, AXLE_HEIGHT-_wheelx_2],
        [AXLE_DISTANCE/2+_wheelx_2, AXLE_HEIGHT+_wheelx_2],
        [AXLE_DISTANCE/2-_wheelx_2, AXLE_HEIGHT+_wheelx_2],
        [AXLE_DISTANCE/2-_wheelx_2, AXLE_HEIGHT-_wheelx_2/2],
        [AXLE_DISTANCE/2-_wheelx_2-4, _y_down],
        [-0.01,_y_down],
    ]);
}

module _totalAxleSpacing() {
    translate([-AXLE_DISTANCE/2, 0, AXLE_HEIGHT])
        _axleSpacing();
    translate([AXLE_DISTANCE/2, 0, AXLE_HEIGHT])
        _axleSpacing();
}

// spacing for one axle, axle centre along Y axis
module _axleSpacing() {
    // 
    rotate(90, [1,0,0])
        cylinder(SP_AXLE_LEN-2*SP_AXLE_END_LEN+0.1,
            SP_AXLE_D/2, SP_AXLE_D/2, true, $fn=20);
    // right end
    translate([0,-SP_AXLE_LEN/2+SP_AXLE_END_LEN])
        _axleEndSpaceRight();
    // left end
    translate([0,SP_AXLE_LEN/2-SP_AXLE_END_LEN])
        mirror([0,1,0])
            _axleEndSpaceRight();
    // right end
    translate([0,-AXLE_INNER_SPACING/2])
        _wheelSpaceRight();
    // left end
    translate([0,AXLE_INNER_SPACING/2])
        mirror([0,1,0])
            _wheelSpaceRight();
}

module _axleEndSpaceRight() { // torwards -Y
    rotate(90, [1,0,0])
        cylinder(SP_AXLE_END_LEN, SP_AXLE_D/2, 0, $fn=20);
    // TODO
}

module _wheelSpaceRight() { // torwards -Y
    rotate(90, [1,0,0])
        cylinder(SP_WHEEL_WIDTH, SP_WHEEL_DIAMETER/2, SP_WHEEL_DIAMETER/2, $fn=20);
}
