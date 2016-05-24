include <track_config.scad>
use <track_basic.scad>
use <_track_separator_manual.scad>

// TODO
// R * 15cm print area
//   * distribute to make generating stl easier

// right turn
//drawSwitch(150, -358-0*61.6, 22.5, 1);

// right turn
//drawSwitch(150, -358-0*61.6, 22.5, 1);
*difference() {
    drawSwitch(230, -358, 30, 1, [45,0]);
    trackSeparatorMan(103.5, 358, 30, 16.7);
}

drawSwitch(230/2, -358+2*61.6, 45, 1, [0,0]);

//*** Wr15 ***
//difference() {
//    drawSwitch(230, -873.5, 15, 1, [-45,0]);
//    trackSeparatorMan(118, 873.5, 15, 7.7);
//}

//difference() {
//    drawSwitch(230*0.75, -358-0*61.6, 30, 1);
//    trackSeparatorMan(118, 358, 30, 19.17);
//}

module trackSeparatorMan(Str_Y, Cur_R, Cur_Angle, Angle) {
    _DR = _JOINT_EFFECTIVE_LENGTH / tan(Cur_Angle/2);
    _R = (abs(Cur_R) - _DR);
    _R1 = _R+GAUGE/2+TRACK_WIDTH/2;
    _R2 = _R-TIE_LENGTH;
    _XXX = 3.8;
    _NUDGE_SIZE = 1.3;
    pp = [// straight
          [-TIE_LENGTH,Str_Y],
          [-_XXX,Str_Y,_NUDGE_SIZE],
//          [_XXX,Str_Y],
//          [GAUGE/2+TRACK_WIDTH/2, Str_Y],
          // curve
//           [_R - cos(Angle)*_R1,
//            _JOINT_EFFECTIVE_LENGTH + sin(Angle)*_R1],
//           [_R - cos(Angle)*(_R+_XXX),
//            _JOINT_EFFECTIVE_LENGTH + sin(Angle)*(_R+_XXX), _NUDGE_SIZE],
           [_R - cos(Angle)*(_R-_XXX),
            _JOINT_EFFECTIVE_LENGTH + sin(Angle)*(_R-_XXX)],
           [_R - cos(Angle)*_R2,
            _JOINT_EFFECTIVE_LENGTH + sin(Angle)*_R2]
         ];
    trackSeparatorSimple(pp, 0.1);
}


// Wr15 Roco (geoline?)
//drawSwitch(230, -873.5, 15, 1);

//drawSwitch(230, -873.5, 15, min(1,max(0,cos($t*360)+0.5)) );

//drawSwitch(230, -358-0*61.6, 30, 0);
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
CROSSING_SPACING = 1.1; /// room between rail and check-rail
CHECK_RAIL_LEN = 12; // 1/2 actually
CHECK_RAIL_W = TRACK_WIDTH;
CHECK_RAIL_H = _TRACK_TOTAL_HEIGHT;
CHECK_RAIL_ANGLE = 10;
CHECK_RAIL_WING_LEN = 6;

_PP_W = 5; // pivot plate with
_PP_R = 1.5; // pivot plate with
_PP_H = 2;

/// TODO
module drawSwitch(Length, Radius, Angle, DXSlider, DistVecto)
    {_drawSwitch(Length, Radius, Angle, DXSlider, DistVecto);};

module _drawSwitch(Length, Radius, Angle, DXSlider, DistVector) {
    // TODO calc in 1 place
    _DR = _JOINT_EFFECTIVE_LENGTH / tan(Angle/2);
    _Radius = //TODO sign(Radius) * 
              (abs(Radius) - _DR);
    _plain_length = Length - 2*_JOINT_EFFECTIVE_LENGTH;
    _SWITCH_MECH_Y1 = sqrt(
            pow(_Radius + GAUGE/2 + TRACK_WIDTH, 2) - 
            pow(_Radius + GAUGE/2 - CROSSING_SPACING,2)
        );

    _PIVOT_Y0 = 1.5*TIE_SPACING+TIE_WIDTH; // TODO
    _PIVOT_Y1 = _SWITCH_MECH_Y1 - _PP_W/2; // TODO
    _PPX = CROSSING_SPACING + _PP_R;
    _PIVOT_XR = GAUGE/2-_PPX; // TODO
    _PIVOT_XL = -_PIVOT_XR + TRACK_WIDTH + CROSSING_SPACING; // TODO
    _PIVOT_ARM_LEN = _PIVOT_Y1 - _PIVOT_Y0;
    
    _PIVOT_ANGLE = asin(SWITCH_MOVEMENT / _PIVOT_ARM_LEN);

    _PA2 = _PIVOT_ANGLE / 2;
    _AL = DXSlider * _PIVOT_ANGLE;
/////    _AR = (1-DXSlider) * _PIVOT_ANGLE;
    
    // center position
    _PIVOT_Y0__ = _PIVOT_Y1 - cos(_PA2)*_PIVOT_ARM_LEN;
    _PIVOT_DX_0 = -sin(_PA2)*_PIVOT_ARM_LEN;
    _PIVOT_DX_0_ = -sin(_PIVOT_ANGLE-_AL)*_PIVOT_ARM_LEN;

    STOPPER_X = 2;

    difference() {
        union() {
            _drawSwitchWOSwitchMech(Length, Radius, Angle);
            // TODO switch things
            translate([0, _JOINT_EFFECTIVE_LENGTH])
                _swichJoinBits(_PIVOT_Y0, _PIVOT_Y1, _PIVOT_XL, _PIVOT_XR);
        };
        translate([_PIVOT_DX_0, _JOINT_EFFECTIVE_LENGTH+_PIVOT_Y0__, 0])
            union() {
                translate([0, 0, TIE_HEIGHT/2])
                    cube([2*TIE_LENGTH, TIE_WIDTH+0.5, TIE_HEIGHT], true);
                translate([STOPPER_X-_PIVOT_DX_0+SWITCH_MOVEMENT/2, TIE_WIDTH/2,-1])
                    union() {
                        translate([DDD,0])
                            cylinder(10, 1+DDD, 1+DDD, $fn=4);
                        translate([-SWITCH_MOVEMENT-DDD,0])
                            cylinder(10, 1+DDD, 1+DDD, $fn=4);
                    }
            }
    }
    //_PIVOT_DX_0_+-_PIVOT_DX_0
    color("orange") {
        translate(1*DistVector)
        translate([_PIVOT_DX_0_, _JOINT_EFFECTIVE_LENGTH+_PIVOT_Y0__, 0])
            difference() {
                union() {
                    translate([-_PIVOT_DX_0,0,TIE_HEIGHT/2])
                        cube([TIE_LENGTH+20, TIE_WIDTH, TIE_HEIGHT], true);
                    // TODO copied
                    translate([_PIVOT_XL,0,0])
                        cylinder(TIE_HEIGHT+_PP_H, _PP_R-DDD, _PP_R-DDD, $fn=20);
                    translate([_PIVOT_XR,0,0])
                        cylinder(TIE_HEIGHT+_PP_H, _PP_R-DDD, _PP_R-DDD, $fn=20);
                    // stopper
                    translate([-_PIVOT_DX_0,TIE_WIDTH/2,0])
                         {
                            translate([STOPPER_X,0])
                                cylinder(TIE_HEIGHT, 1-DDD, 1-DDD, $fn=4);
                        }
                };
                translate([-_PIVOT_DX_0,TIE_WIDTH/2,0])
                    union() {
                        translate([2+1,-2])
                            cube([0.3,20,20]);
                        translate([2+1-5,-1-1, -0.1])
                            cube([5.1,1,20]);
                    }
            }
    }
    translate(2*DistVector)
    color("blue") {
        union() {
        translate([0, _JOINT_EFFECTIVE_LENGTH+_PIVOT_Y1, TIE_HEIGHT+1])
            pivot_cover(_PIVOT_XL, _PIVOT_XR);
        translate([0, _JOINT_EFFECTIVE_LENGTH+_PIVOT_Y0, TIE_HEIGHT+1])
            pivot_cover(_PIVOT_XL+_PIVOT_DX_0_, _PIVOT_XR+_PIVOT_DX_0_);
        }
    }
    color("green")
        translate(3*DistVector)
        translate([0, _JOINT_EFFECTIVE_LENGTH]) union() {
            // left moving track ------------------------------------
            translate([_PIVOT_XL,_PIVOT_Y1]) rotate(_AL-_PA2,[0,0,1]) translate([-_PIVOT_XL,-_PIVOT_Y1])
            // track itself
            difference() {
                intersection() {
                    union() {
                        // curve left track
                        translate([_PIVOT_XL,_PIVOT_Y1]) rotate(_PA2,[0,0,1]) translate([-_PIVOT_XL,-_PIVOT_Y1])
                        union() {
                        plainCurve(-_Radius, -atan(_SWITCH_MECH_Y1/_Radius), 0, 1);
                        // base++
                            rotate(-atan((TRACK_WIDTH + CROSSING_SPACING)/_PIVOT_ARM_LEN),[0,0,1])
                            translate([-GAUGE/2-1, 0, TIE_HEIGHT])
                                cube([2, _SWITCH_MECH_Y1, 1]);
                        }
                        // pivot plate up
                        translate([_PIVOT_XL, _PIVOT_Y1, TIE_HEIGHT])
                            __pivot_plate();
                        // pivot plate up
                        translate([_PIVOT_XL+_PIVOT_DX_0, _PIVOT_Y0__, TIE_HEIGHT])
                            __pivot_plate();
                    }
                    union() {
                        translate([_PIVOT_XL,_PIVOT_Y1]) rotate(_PA2,[0,0,1]) translate([-_PIVOT_XL,-_PIVOT_Y1])
                        _switchArea(_SWITCH_MECH_Y1, -1);
                        ; // TODO spacing for straight going stuff
                    }
                }
                translate([_PIVOT_XL,_PIVOT_Y1]) rotate(-_PA2,[0,0,1]) translate([-_PIVOT_XL,-_PIVOT_Y1])
                    wheelSpacing(_plain_length, _Radius, Angle, 1);
            }
            // right moving track ------------------------------------
            translate([_PIVOT_XR,_PIVOT_Y1]) rotate(_AL-_PA2,[0,0,1]) translate([-_PIVOT_XR,-_PIVOT_Y1])
            // track itself
            difference() {
                intersection() {
                    union() {
                        // curve left track
                        translate([_PIVOT_XL,_PIVOT_Y1]) rotate(-_PA2,[0,0,1]) translate([-_PIVOT_XL,-_PIVOT_Y1])
                        union() {
                        _plainStraight(_SWITCH_MECH_Y1, 0, 2);
                        // base++
                        translate([GAUGE/2-1, 0, TIE_HEIGHT])
                            cube([2, _SWITCH_MECH_Y1, 1]);
                        }
                        // pivot plate up
                        translate([_PIVOT_XR, _PIVOT_Y1, TIE_HEIGHT])
                            mirror([1,0,0]) __pivot_plate();
                        // pivot plate up
                        translate([_PIVOT_XR+_PIVOT_DX_0, _PIVOT_Y0__, TIE_HEIGHT])
                            mirror([1,0,0]) __pivot_plate();
                    }
                    union() {
                        translate([_PIVOT_XL,_PIVOT_Y1]) rotate(-_PA2,[0,0,1]) translate([-_PIVOT_XL,-_PIVOT_Y1])
                        _switchArea(_SWITCH_MECH_Y1, -1);
                        ; // TODO spacing for straight going stuff
                    }
                }
                translate([_PIVOT_XL,_PIVOT_Y1]) rotate(_PA2,[0,0,1]) translate([-_PIVOT_XL,-_PIVOT_Y1])
                    wheelSpacing(_plain_length, _Radius, Angle, 2);
            }
        }
        // pivot points
        if (1==0){
        translate([0, _JOINT_EFFECTIVE_LENGTH]) union() {
            translate([_PIVOT_XL,_PIVOT_Y0]) cube([1,1,20],true);
            translate([_PIVOT_XR,_PIVOT_Y0]) cube([1,1,20],true);
            translate([_PIVOT_XL,_PIVOT_Y1]) cube([1,1,20],true);
            translate([_PIVOT_XR,_PIVOT_Y1]) cube([1,1,20],true);
        }}
}

module __pivot_plate() {
    difference() {
        translate([-GAUGE+_PP_W/2, -_PP_W/2])
            cube([GAUGE, _PP_W, 1]);
        cylinder(10,_PP_R+DDD,_PP_R+DDD, true, $fn=20);
    }
}

module pivot_cover(XL, XR) {
    _len = XR - XL + 2*_PP_R;
    difference() {
        translate([XL-_PP_R,-_PP_W/2])
            cube([_len, _PP_W, 1]);
        union() {
            translate([XL,0])
                cylinder(10,_PP_R+DDD,_PP_R, true, $fn=20);
            translate([XR,0])
                cylinder(10,_PP_R+DDD,_PP_R, true, $fn=20);
        }
    }
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
        _straight(Length, 1, 4+8);
        // curve with no left track
        curve(Radius, Angle, 1, 4+8);

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

        difference() {
            union() {
                translate([0, _JOINT_EFFECTIVE_LENGTH]) {
                    // straight right track
                    _plainStraight(Length - 2*_JOINT_EFFECTIVE_LENGTH, 0, 1+2);
                    // curve left track
                    plainCurve(-_Radius, -Angle, 0, 1+2);
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
            translate([0, _JOINT_EFFECTIVE_LENGTH])
                union() {
                    // wheel spacing
                    wheelSpacing(_plain_length, _Radius, Angle);
                    _switchArea(_SWITCH_MECH_Y1, 1);
                }
        }
    }
}

module wheelSpacing(_plain_length, _Radius, Angle, Mode=1+2) {
    union() {
        if (Mode%2==1) {
            translate([0,_plain_length]) rotate(90, [1, 0, 0])
                linear_extrude(_plain_length) 
                    wheelSpacingProfile();
        }
        if (floor(Mode/2)%2==1) {
            translate([_Radius, 0])
                rotate_extrude(angle = -Angle, $fn = 200) // TODO $fn
                    translate([-_Radius, 0])
                        wheelSpacingProfile();
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

////////////////////////////////////////////////////////////////////////////////
//     SWITCH
////////////////////////////////////////////////////////////////////////////////

SWITCH_XXX = 0.45; // how wide is end-point
SWITCH_MOVEMENT = SWITCH_XXX + CROSSING_SPACING + SWITCH_XXX;

module _switchArea(Length, Delta) {
    translate([0, 0, TIE_HEIGHT-(Delta-1)*DDD+0.01])
        linear_extrude(TRACK_HEIGHT+Delta*DDD)
            polygon(points =
                [[-GAUGE/2-SWITCH_XXX-Delta*DDD, -2*Delta*DDD],
                 [-GAUGE/2-Delta*DDD, Length+Delta*DDD],
                 [GAUGE/2+TRACK_WIDTH+Delta*DDD, Length+Delta*DDD],
                 [GAUGE/2+SWITCH_XXX+Delta*DDD, -2*Delta*DDD]]
                ); // TODO XXX front and low should be tilted like that /   \
}

module _swichJoinBits(Y0, Y1, XL, XR) {
    union() {
        // "lower" join part
        translate([0,Y0,0])
            translate([-(GAUGE+TRACK_WIDTH)/2, 0, 0])
                cube([GAUGE+TRACK_WIDTH, TIE_WIDTH, TIE_HEIGHT]); // TODO
        // "upper" join part
        translate([0,Y1,0])
            union() {
                translate([-GAUGE/2+TRACK_WIDTH, -_PP_W/2, 0])
                    cube([GAUGE+2*TRACK_WIDTH, _PP_W, TIE_HEIGHT]); // TODO
                translate([XL,0,0])
                    cylinder(TIE_HEIGHT+_PP_H, _PP_R-DDD, _PP_R-DDD, $fn=20);
                translate([XR,0,0])
                    cylinder(TIE_HEIGHT+_PP_H, _PP_R-DDD, _PP_R-DDD, $fn=20);
            }
    }
}

