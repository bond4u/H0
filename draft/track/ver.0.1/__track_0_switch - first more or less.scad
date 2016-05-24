include <track_0.scad>

//drawSwitch(230, -358, 30, 0);
//drawSwitch(230, -358, 30, SWITCH_SLEDGE_LEN);
drawSwitch(230, -358, 30, SWITCH_SLEDGE_LEN+SWITCH_SLIDE_LEN);
//drawSwitch(230, -358, 30, 50);

//drawStraightG(1/2);

//translate([-50,_JOINT_EFFECTIVE_LENGTH,0]) {
//    color("green")
//        _switchMechStatic(40);
//    color("blue")
//        _switchMechMoving(40, -358, 30);
//}

// TODO 
//      stops
//      join moving tech
//      moving tech inside from real track
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
            _drawSwitchWOSwitchMex(Length, Radius, Angle);
            translate([0, _JOINT_EFFECTIVE_LENGTH])
                // switch MEX
                //color("green")
                    translate(0, _SWITCH_MEX_Y0)
                        _switchMechStaticP(_SWITCH_MEX_LEN);
        };
        translate([0, _JOINT_EFFECTIVE_LENGTH + _SWITCH_MEX_Y0])
            _switchMechStaticM(_SWITCH_MEX_LEN);
    }
    //color("blue")
        translate([-DXSlider, _JOINT_EFFECTIVE_LENGTH])
            _switchMechMoving(_SWITCH_MEX_LEN, Radius, Angle);

}

module _drawSwitchWOSwitchMex(Length, Radius, Angle) {
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
    
    _SWITCH_MEX_Y0 = 0;
    _SWITCH_MEX_Y1 = sqrt(
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
        // tracks between crossing

        // TODO broken 
        // TODO moving bit
        // TODO moving handle
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
// teeth width (left-right)
SWITCH_SLEDGE_LEN = 7.5;
// border around 
SWITCH_XXX = 3; // extra width to hold together

SWITCH_BASE_W = GAUGE + SWITCH_SLIDE_LEN + 2*SWITCH_SLEDGE_LEN +
        2*SWITCH_XXX + TRACK_WIDTH;
SWITCH_BASE_DX = GAUGE / 2 + SWITCH_XXX + TRACK_WIDTH+SWITCH_SLIDE_LEN;

SWITCH_MOVING_MECH_X0 = SWITCH_XXX+SWITCH_SLIDE_LEN+SWITCH_SLEDGE_LEN;

SWITCH_GUIDE_W = 3;
SWITCH_GUIDE_HW = 1;
SWITCH_GUIDE_DIST_1 = 5; // from the base end
SWITCH_GUIDE_ANGLE = JOINT_RAIL_ANGLE;

module _switchMechStatic(Length) {
    difference() {
        _switchMechStaticP(Length);
        _switchMechStaticM(Length);
    }
}

module _switchMechStaticP(Length) {
    translate([-SWITCH_BASE_DX, 0, 0]) {
        // base
        cube([SWITCH_BASE_W, Length, TIE_HEIGHT-10*RENDERING_ERROR]);
    }
}

module _switchMechStaticM(Length) {
    translate([-SWITCH_BASE_DX, 0, 0]) {
        union() {
            // bottom left
            translate([SWITCH_XXX, SWITCH_GUIDE_DIST_1])
                _switchGuideTrack(-1);
            // bottom left
            translate([SWITCH_XXX,
                       Length - SWITCH_GUIDE_DIST_1 - SWITCH_GUIDE_W])
                _switchGuideTrack(1);
            // inner spacing....
            translate([SWITCH_XXX-DDD,
                       SWITCH_GUIDE_DIST_1+SWITCH_GUIDE_W + SWITCH_GUIDE_HW-DDD,
                       -RENDERING_ERROR])
                cube([SWITCH_BASE_W-2*(SWITCH_XXX-DDD),
                      Length-2*(
                          SWITCH_GUIDE_DIST_1+SWITCH_GUIDE_HW+SWITCH_GUIDE_W-DDD),
                      TIE_HEIGHT+2*RENDERING_ERROR]);
            // TODO clear old tracks
            translate([0, SWITCH_GUIDE_DIST_1-DDD, TIE_HEIGHT-2*DDD]) {
                // base
                cube([SWITCH_BASE_W,
                      Length - 2*SWITCH_GUIDE_DIST_1 + 2*DDD,
                      TRACK_HEIGHT+2*DDD+RENDERING_ERROR]);
            }
        }
    }
}

module _switchGuideTrack(Dir) {
    _dx = Dir * TIE_HEIGHT * tan(SWITCH_GUIDE_ANGLE);
    translate([-DDD, 0, -RENDERING_ERROR])
        rotate(90, [0,0,1]) rotate(90, [1,0,0])
            linear_extrude(SWITCH_SLIDE_LEN+2*SWITCH_SLEDGE_LEN+GAUGE+TRACK_WIDTH+2*DDD)
                _switchGuideProfile(_dx);
    // left teeth
    translate([SWITCH_SLIDE_LEN+SWITCH_SLEDGE_LEN-DDD, _dx, -RENDERING_ERROR])
        cube([SWITCH_SLEDGE_LEN+2*DDD,
              SWITCH_GUIDE_W+2*DDD,
              _TRACK_TOTAL_HEIGHT + 2*RENDERING_ERROR]);
    // right teeth
    translate([SWITCH_SLIDE_LEN+SWITCH_SLEDGE_LEN+GAUGE+TRACK_WIDTH-DDD, _dx, -RENDERING_ERROR])
        cube([SWITCH_SLEDGE_LEN+2*DDD,
              SWITCH_GUIDE_W+2*DDD,
              _TRACK_TOTAL_HEIGHT + 2*RENDERING_ERROR]);
}

module _switchGuideProfile(_DX, Sign=1) {
    polygon(points =
        [[0 - Sign*DDD, TIE_HEIGHT + 2*RENDERING_ERROR],
         [SWITCH_GUIDE_W + Sign*DDD, TIE_HEIGHT + 2*RENDERING_ERROR],
         [SWITCH_GUIDE_W + Sign*DDD + _DX, -RENDERING_ERROR],
         [0 - Sign*DDD + _DX, -RENDERING_ERROR]]);
}

///////////////////////////////////////////////////////////////////
module _switchMechMoving(Length, CRadius, CAngle) {
    translate([-SWITCH_BASE_DX, 0, 0])
        union() {
            // "lower" teeths
            translate([SWITCH_MOVING_MECH_X0, SWITCH_GUIDE_DIST_1])
                _movingMechTeeth(-1);
            translate([SWITCH_MOVING_MECH_X0+GAUGE+TRACK_WIDTH, SWITCH_GUIDE_DIST_1])
                _movingMechTeeth(-1);
            // "upper" teeths
            translate([SWITCH_MOVING_MECH_X0,
                       Length-SWITCH_GUIDE_DIST_1-SWITCH_GUIDE_W])
                _movingMechTeeth(1);
            translate([SWITCH_MOVING_MECH_X0+GAUGE+TRACK_WIDTH,
                       Length-SWITCH_GUIDE_DIST_1-SWITCH_GUIDE_W])
                _movingMechTeeth(1);
            // track base
//            translate([SWITCH_MOVING_MECH_X0+DDD, SWITCH_GUIDE_DIST_1+SWITCH_GUIDE_W+SWITCH_GUIDE_HW+DDD])
//            cube([SWITCH_SLEDGE_LEN-2*DDD, 
//                  Length - 2*(SWITCH_GUIDE_DIST_1+SWITCH_GUIDE_W+SWITCH_GUIDE_HW+DDD)
//                  , TIE_HEIGHT+RENDERING_ERROR]);
//            translate([SWITCH_MOVING_MECH_X0+GAUGE+TRACK_WIDTH-DDD, SWITCH_GUIDE_DIST_1+SWITCH_GUIDE_W+SWITCH_GUIDE_HW+DDD])
//            cube([SWITCH_SLEDGE_LEN-2*DDD, 
//                  Length - 2*(SWITCH_GUIDE_DIST_1+SWITCH_GUIDE_W+SWITCH_GUIDE_HW+DDD)
//                  , TIE_HEIGHT+RENDERING_ERROR]);
            
            // track
            intersection() {
                union() {
                    translate([SWITCH_MOVING_MECH_X0+GAUGE/2+TRACK_WIDTH, 0, 0])
                        _plainStraight(Length, 1, 1+2+4+8);
                    translate([SWITCH_MOVING_MECH_X0+GAUGE/2+TRACK_WIDTH+SWITCH_SLIDE_LEN, 0, 0])
                        plainCurve(CRadius, -CAngle, 0, 1+2+4+8);
                };
                //
                translate([0, SWITCH_GUIDE_DIST_1+DDD, TIE_HEIGHT])
                cube([SWITCH_BASE_W,
                       Length -2*SWITCH_GUIDE_DIST_1-2*DDD,
                       TRACK_HEIGHT]);
            }
        }
}

module _movingMechTeeth(Dir) {
    _dx = Dir * TIE_HEIGHT * tan(SWITCH_GUIDE_ANGLE);
    translate([DDD, 0, -RENDERING_ERROR])
        rotate(90, [0,0,1]) rotate(90, [1,0,0])
            linear_extrude(SWITCH_SLEDGE_LEN-2*DDD)
                _switchGuideProfile(_dx, -1);
}
