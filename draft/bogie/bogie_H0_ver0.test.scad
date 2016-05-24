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

MIN_DDD = 0.5;

SIDE_THICKNESS = 3;
XXX_ROUNDNESS = 1;

_bogie();

module pyr(H, Y1, Y2, Th) {
    rotate(-90,[0,1,0])
    translate([0,0,-Th/2])
    linear_extrude(Th)
    polygon([[0,0],[Y1,0],[Y2,H],[0,H]]);
}

module pyr2(H, Y1, Y2, Th) {
    rotate(-90,[0,1,0])
    translate([0,0,-Th/2])
    linear_extrude(Th)
    polygon([[0,0],[Y1,0],[Y2,H],[0,H]]);
}

B_SIDE_THICKNESS = 2;

module _sideRight2() {
    translate([0,0,AXLE_HEIGHT])
    rotate(90,[1,0,0])
    difference() {
        union() {
            linear_extrude(2)
                yyyy();
            linear_extrude(2.3) offset(MIN_DDD, true)
                xxxx_tri();
            linear_extrude(2.3) offset(MIN_DDD, true)
                mirror([1,0,0]) xxxx_tri();
            linear_extrude(1) {
                mirror([1,0,0]) xxxx_tri();
            }
            translate([-2.75,-2.25])
                pyr(2.5, B_SIDE_THICKNESS+1.5,B_SIDE_THICKNESS,MIN_DDD);
            translate([2.75,-2.25])
                pyr(2.5, B_SIDE_THICKNESS+1.5,B_SIDE_THICKNESS,MIN_DDD);
            translate([-3,-2.75])
                cube([6,MIN_DDD,B_SIDE_THICKNESS+1.5]);
        }
        translate([0,0,-1])
        linear_extrude(5)
            union() {
            xxxx();
            mirror([1,0,0]) xxxx();
            }
    }
    translate([-1.25,0,3])
        cylinder(2.5,1,1, $fn=10);
    translate([1.25,0,3])
        cylinder(2.5,1,1, $fn=10);
    translate([-1.25,-2.5,3])
        cylinder(2.5,1,1, $fn=10);
    translate([1.25,-2.5,3])
        cylinder(2.5,1,1, $fn=10);
//    translate([0,-2.5,5])
//        pyr(3,2,5,4);
    
    translate([-AXLE_DISTANCE/2, 0, AXLE_HEIGHT])
        rotate(90, [1,0,0])
            cylinder(SIDE_THICKNESS,2,2, $fn=20);
//    translate([AXLE_DISTANCE/2, 0, AXLE_HEIGHT])
//        _axleCover();
}

module yyyy() {
    yyyy_();
    mirror([1,0,0]) yyyy_();
}

module yyyy_() {
    hull() {
        translate([0,3]) circle(1);
        translate([0,-2.5]) circle(1);
        translate([-4,-2.5]) circle(1);
        translate([-10,3]) circle(1);
    }
    hull() {
        translate([-14,3]) circle(1);
        translate([-10,3]) circle(1);
    }
    hull() {
        translate([-14,3]) circle(1);
        translate([-15,2]) circle(1);
        translate([-15,0.5]) circle(1);
        translate([-13.75,-1.5]) circle(0.5);
        translate([-13,1]) circle(0.5);
    }
}

module xxxx() {
//    translate([3,0,-4]) cube(5,B_SIDE_THICKNESS,10);
//    //
//    translate([-4,-B_SIDE_THICKNESS]) cube([8,5,0.6]);
//    translate([-1.5,-1.3, -3]) cylinder(3,1,1, $fn=10);
//    translate([1.5,-1.3, -3]) cylinder(3,1,1, $fn=10);
//    translate([-3,-B_SIDE_THICKNESS,-3.6]) cube([6,5,0.6]);
//    // 
//    
    hull() {
        translate([-2,2]) circle(0.5, $fn=10);
        translate([2,2]) circle(0.5, $fn=10);
        translate([-2,-1.75]) circle(0.5, $fn=10);
        translate([2,-1.75]) circle(0.5, $fn=10);
    }
    xxxx_tri();
    hull() {
        translate([-12.5,1]) circle(1, $fn=10);
        translate([-10.5,1]) circle(1, $fn=10);
        translate([-10.5,-1]) circle(1, $fn=10);
        translate([-12.5,-1]) circle(1, $fn=10);
    }
}

module xxxx_tri() {
    hull() {
        translate([-7,1.75]) circle(0.5, $fn=10);
        translate([-4.5,2]) circle(0.5, $fn=10);
        translate([-5,-0.5]) circle(0.5, $fn=10);
    }
}

module _bogie() {
    difference() {
        union() {
            translate([0,-SP_WHEEL_OUTER_DISTANCE/2])
                _sideRight2();
            translate([0,SP_WHEEL_OUTER_DISTANCE/2])
                mirror([0,1,0])
                    _sideRight2();

            // connecting sides... & following the standards since 2016
            difference() {
                union() {
                    translate([0,0,6.75])
                        cube([6, 16, 6], true);
                    translate([0,0,6.5])
                        cube([5, 28, 2], true);
                }
                cylinder(30, 2, 2, $fn=20);
                translate([0,0,6.5])
                    cube([5-2*MIN_DDD, 30, 0.8], true);
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
