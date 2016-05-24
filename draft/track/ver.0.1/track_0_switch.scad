include <track_0.scad>


// right turn
drawSwitch(230, -358-0*61.6, 30, 0);
//drawSwitch(230, -358, 30, SWITCH_SLIDE_LEN);
//drawSwitch(230, -358, 30, 40);

// TODO 
//      lever

// TODO split for printing


///    | |     | | / /
///    | |     | |/ /
///    | |     | / /
///    | |     |  /
///    | |     /1/
///    | |    /  |     /
///    | |   / 0 |    /
///    | |  / /| |   / /
///    | | / / | |  / /
///    | |/ /  | | / /
///    | V /   | |/ /
///    | |/    | v /
XXX_SWITCH_CROSSING_1 = [GAUGE/2 + TRACK_WIDTH/2, 117]; // TODO calculate
CROSSING_SPACING = 1.1; /// room between rail and check-rail
CHECK_RAIL_LEN = 12; // 1/2 actually
CHECK_RAIL_W = TRACK_WIDTH;
CHECK_RAIL_H = _TRACK_TOTAL_HEIGHT;
CHECK_RAIL_ANGLE = 10;
CHECK_RAIL_WING_LEN = 6;

/// TODO
module drawSwitch(Length, Radius, Angle, DXSlider)
    {_drawSwitch(Length, Radius, Angle, DXSlider);};

module _drawSwitch(Length, Radius, Angle, DXSlider) {
    // TODO calc in 1 place
    _DR = _JOINT_EFFECTIVE_LENGTH / tan(Angle/2);
    _Radius = //TODO sign(Radius) * 
              (abs(Radius) - _DR);
    _SWITCH_MEX_Y0 = 0;
    _SWITCH_MEX_Y1 = sqrt(
            pow(_Radius + GAUGE/2 + TRACK_WIDTH, 2) - 
            pow(_Radius + GAUGE/2 - CROSSING_SPACING,2)
        );
    _SWITCH_MEX_LEN = _SWITCH_MEX_Y1 - _SWITCH_MEX_Y0;
    
    difference() {
        union() {
            _drawSwitchWOSwitchMech(Length, Radius, Angle);
        };
        translate([0, _JOINT_EFFECTIVE_LENGTH, 0])
            _switchMechMinus(_SWITCH_MEX_LEN);
    }
    //color("blue")
        translate([DXSlider, _JOINT_EFFECTIVE_LENGTH])
            _switchMechMoving(_SWITCH_MEX_LEN, Length, -_Radius, Angle);
}

module _drawSwitchWOSwitchMech(Length, Radius, Angle) {
// TODO calculated at wrong place
    _DR = _JOINT_EFFECTIVE_LENGTH / tan(Angle/2);
    _Radius = //TODO sign(Radius) * 
              (abs(Radius) - _DR);
    _plain_length = Length - 2*_JOINT_EFFECTIVE_LENGTH;

    _SWITCH_CROSSING_0_X = GAUGE/2-CROSSING_SPACING/2;
    _SWITCH_CROSSING_0_Y = sqrt(
            pow(_Radius + _SWITCH_CROSSING_0_X,2) - 
            pow(_Radius - _SWITCH_CROSSING_0_X,2)
        );
    _SWITCH_CROSSING_0_ANGLE =
            asin(_SWITCH_CROSSING_0_Y / (_Radius + _SWITCH_CROSSING_0_X));

    _SWITCH_CROSSING_1_X = GAUGE/2 + TRACK_WIDTH/2;
    _SWITCH_CROSSING_1_Y = sqrt(
            pow(_Radius + _SWITCH_CROSSING_1_X,2) - 
            pow(_Radius - _SWITCH_CROSSING_1_X,2)
        );
    
    _SWITCH_MECH_Y0 = 0;
    _SWITCH_MECH_Y1 = sqrt(
            pow(_Radius + GAUGE/2 + TRACK_WIDTH, 2) - 
            pow(_Radius + GAUGE/2 - CROSSING_SPACING,2)
        );
    debug = 0;

    if (debug == 1) {
        #translate([_SWITCH_CROSSING_0_X,
                    _SWITCH_CROSSING_0_Y+_JOINT_EFFECTIVE_LENGTH])
            cube([1, 1, 20], true);
        #translate([_SWITCH_CROSSING_1_X,
                    _SWITCH_CROSSING_1_Y+_JOINT_EFFECTIVE_LENGTH])
            cube([1, 1, 20], true);
    }

    //--------------- track drawing ----------------
    union() {
        // straight with no right track
        _straight(Length, 1, 1+4+8);
        // curve with no left track
        curve(Radius, Angle, 1, 2+4+8);

        // crossing
        intersection() {
            // only straight right track (without base)
            _straight(Length, 0, 2);
            // only curbe left track (without base)
            curve(Radius, Angle, 0, 1);
        }
        // ... beyond crossing tracks
        //color("violet", 1)
        difference() {
            union() {
                _straight(Length, 0, 2);
                curve(Radius, Angle, 0, 1);
                translate([0, _JOINT_EFFECTIVE_LENGTH]) {
                    // check rails on straight
                    translate([0, _SWITCH_CROSSING_0_Y])
                        _checkAndWingRails();
                    // check rails on curve
                    translate([_Radius,0])
                        rotate(-_SWITCH_CROSSING_0_ANGLE, [0,0,1])
                            translate([-_Radius,0])
                        mirror([1,0,0])
                            _checkAndWingRails();
                }
                // TODO switch things
                translate([0, _JOINT_EFFECTIVE_LENGTH])
                    _swichJoinBits(_SWITCH_MECH_Y0, _SWITCH_MECH_Y1);
            }
            // minus part
            translate([0, _JOINT_EFFECTIVE_LENGTH]) // TODO _joint
            union() {
                // wheel spacing
                translate([0,_plain_length]) rotate(90, [1, 0, 0])
                    linear_extrude(_plain_length) 
                        wheelSpacingProfile();
                    translate([_Radius, 0])
                        rotate_extrude(angle = -Angle, $fn = 200) // TODO $fn
                            translate([-_Radius, 0])
                                wheelSpacingProfile();
            }
        }
    }
}


module wheelSpacingProfile() {
    translate([-GAUGE/2, -1])
        square([CROSSING_SPACING, _TRACK_TOTAL_HEIGHT+2]);
    translate([GAUGE/2-CROSSING_SPACING, -1])
        square([CROSSING_SPACING, _TRACK_TOTAL_HEIGHT+2]);
}

module _checkRail(XTRA_LEN = 0) {
    // straight part
    translate([-GAUGE/2 + CROSSING_SPACING, -XTRA_LEN])
        cube([CHECK_RAIL_W, CHECK_RAIL_LEN+XTRA_LEN, CHECK_RAIL_H]);
    // end
    translate([-GAUGE/2 + CROSSING_SPACING + CHECK_RAIL_W/2,
               CHECK_RAIL_LEN])
        rotate(-CHECK_RAIL_ANGLE, [0,0,1]) {
            // joint
            cylinder(CHECK_RAIL_H, CHECK_RAIL_W/2, CHECK_RAIL_W/2, $fn=20);
            // wing part
            translate([-CHECK_RAIL_W/2, 0])
                cube([CHECK_RAIL_W, CHECK_RAIL_WING_LEN, CHECK_RAIL_H]);
        }
}

module _checkAndWingRails() {
    // left check
    _checkRail(0.1);
    mirror([0,1,0])
        _checkRail(0.1);
    // wing for right
    mirror([1,0,0])
        _checkRail();
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//     SWITCH
/////////////////////////////////////////////////////////////////////////////////////////////////////////

// how much slide (left-right)?
SWITCH_SLIDE_LEN = TRACK_WIDTH + CROSSING_SPACING;
// how far left left sliding part reaches
SWITCH_SLIDE_MIN_X = -GAUGE/2 - TRACK_WIDTH - SWITCH_SLIDE_LEN;
// 
SWITCH_SLIDE_WIDTH_XXX = 3*GAUGE;

// teeth width (left-right)
SWITCH_GUIDE_ANGLE = JOINT_RAIL_ANGLE;


/// DX, DY - how much smaller? neg = hole
module _switchMechMinus(Length, DX=-DDD,DY=0) {
    difference() {
    union() {
        translate([SWITCH_SLIDE_MIN_X + DX, 0, 1])
            rotate(90, [0,1,0]) rotate(90, [0,0,1])
                linear_extrude(SWITCH_SLIDE_WIDTH_XXX)
                    _switchSlideProfile(Length, DX, DY);
        // "low" xxx
        translate([0,2+DX,1+DY])
            cylinder(5, 2, 2, $fn=4);
        if (DX < 0) {
            translate([SWITCH_SLIDE_LEN,2+DX,1+DY])
                cylinder(5, 2, 2, $fn=4);
        }
        // "low" xxx
        translate([0,Length-(2+DX),1+DY])
            cylinder(5, 2, 2, $fn=4);
        if (DX < 0) {
            translate([SWITCH_SLIDE_LEN,Length-(2+DX),1+DY])
                cylinder(5, 2, 2, $fn=4);
        }
    };
        if (DX > 0) { // TODO
            translate([-3,0,1])
                cube([0.5, 4, 2]);
            translate([-3,2,1])
                cube([GAUGE/2-1, 2, 2]);
            //
            translate([-3,Length,1])
                mirror([0,1,0])
                cube([0.5, 5, 2]);
            translate([-3,Length-2,1])
                mirror([0,1,0])
                cube([GAUGE/2-1, 2.5, 2]);
        }
    }
}

module _switchSlideProfile(Length, DX, DY=0) {
    _hhh = _TRACK_TOTAL_HEIGHT;
    _dx = _hhh * tan(SWITCH_GUIDE_ANGLE);
    _dx2 = DY * tan(SWITCH_GUIDE_ANGLE);
    polygon(points =
        [[0 + _dx2 + DX, DY - RENDERING_ERROR],
         [0 + _dx + DX, _hhh + RENDERING_ERROR],
         [Length - _dx - DX, _hhh + RENDERING_ERROR],
         [Length - _dx2 - DX, DY - RENDERING_ERROR]]);
}

module _switchMechMoving(SwitchLen, StraightLen, CRadius, CAngle) {
    intersection() {
        union() {
            // curved tracks
            translate()
                plainCurve(CRadius, -CAngle, 0, 1+2+4+8);
            // straight tracks
            translate([-SWITCH_SLIDE_LEN, 0])
                _plainStraight(StraightLen, 1, 1+2+4+8);
            //
            _swichJoinBits(0, SwitchLen);
        }
        _switchMechMinus(SwitchLen, DDD, 0.25); // TODO make smaller
    }
}

module _swichJoinBits(Y0, Y1) {
    union() {
        // "lower" join part
        translate([0,Y0,0])
            translate([-GAUGE/2+CROSSING_SPACING, -1.5, 0])
                cube([GAUGE-2*CROSSING_SPACING, 5, TIE_HEIGHT+0.5]);
        // "upper" join part
        translate([0,Y1,0])
            translate([-TIE_LENGTH/2, -(5-1.5), 0])
                cube([TIE_LENGTH, 5, TIE_HEIGHT+0.5]);
    }
}
