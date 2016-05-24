//================ main ================

// 1. just a joint base
// drawJointBase();

// 2. sample on how joints fit together
// TODO rail(); translate([0,-4.3,0]) rotate([0,0,180]) rail();

// Roco R2 curve left, 15 degrees
//drawCurve(358, 15);
//drawCurveRocoR(2, 15);
//color("blue")
//translate([-23/2,0,0])
//cube([23,13,4]);
// Roco G1/2 115mm
//scale(1.4)
drawStraightG(1/2);
//drawJointX();

//drawCurve(358, 15);
//translate([0,-115,0])
//drawStraightG(1/2);

//====================== API ======================
// Track starts and ends with joint.
// Joint takes 2 ties and is always the same (straight).
// By default all draw* methods traw track in Y-axis starting from origin.
//
//    Y->         JTTTTTTTTTT
//  X             J   T   T
//  |           0 J   T   T
//  V             J   T   T
//             JJJJTTTTTTTTTT

/// One half of joint (base, no tracks).
module drawJointBase() {translate([0, TIE_SPACING/2]) whole_joint_base();};

/// One half of whole joint (base + tracks).
/// Error margin added.
module drawJointX() {translate([0, TIE_SPACING/2]) whole_joint();};

/// Tie, center of tie is in the origin
module drawTie() {
    translate([0, -TIE_WIDTH/2]) tie();
}


//- R2 -> 358mm radius (12pc., 30º each)
//- R3 -> 419,6mm " " "
//- R4 -> 481,2mm " " "
//- R5 -> 542,8mm " " "
//- R6 -> 604,4mm " " "
//- R9 -> 826,4mm " (24pc., 15º each)????
module drawCurveRocoR(R, Angle) {curve(358+61.6*(R-2), Angle);}


/// Radius - millimeters (measured to the centre of the track)
/// Angle - degrees
/// Seems as left curve, but you know, look from another side,
/// and it is right curve ;)
module drawCurve(Radius, Angle) {curve(Radius, Angle);}

/// G4 920mm
/// G1 230mm
/// G1/2 115mm
/// G1/4 57,5mm
module drawStraightG(G) {straightG(G);}

//================= configuration ===================

GAUGE = 24;

DDD = 0.1;

LEN_STEPS = 3; // <<<

TRACK_WIDTH = 1.8;
TRACK_HEIGHT = 2.1;

TRACK_BASE_WIDTH = 4;
TRACK_BASE_JOINT_EXTRA_WIDTH = (7-TRACK_BASE_WIDTH) / 2;

TIE_LENGTH = 28;
TIE_WIDTH = 3;
TIE_HEIGHT = 2;
TIE_SPACING = 8.4; // TODO

JOINT_LENGTH = TIE_SPACING + TIE_WIDTH / 2; // TODO?
JOINT_WIDTH = 3; // TODO
JOINT_RAIL_ANGLE = 30;
JOINT_SIZE = 2;

_JOINT_EFFECTIVE_LENGTH = TIE_WIDTH + TIE_SPACING / 2;
_TIE_STEP = TIE_WIDTH + TIE_SPACING;
_TIE_DX = TIE_LENGTH / 2;
_TRACK_BASE_DX = GAUGE / 2 - (TRACK_BASE_WIDTH - TRACK_WIDTH) / 2;
_TRACK_BASE_X_CENTRE = -_TRACK_BASE_DX-TRACK_BASE_WIDTH/2;
_TRACK_TOTAL_HEIGHT = TRACK_HEIGHT + TIE_HEIGHT;

RENDERING_ERROR = 0.01;
XXX_HEAD_WIDTH = 0.4;

module rail() { // TODO deprecated
    union() {
        whole_joint_base();
        for (i = [1:LEN_STEPS]) {
            translate([0,i*_TIE_STEP]) tie_with_base();
        }
        // left track
        translate([-TRACK_WIDTH-GAUGE/2-DDD,
                   -JOINT_LENGTH+DDD,
                   TIE_HEIGHT])
            cube([TRACK_WIDTH,
                  LEN_STEPS*_TIE_STEP+JOINT_LENGTH+TIE_WIDTH-DDD,
                  TRACK_HEIGHT]);
        // right track
        translate([GAUGE/2+DDD,
                   JOINT_LENGTH - TIE_SPACING + DDD,
                   TIE_HEIGHT])
            cube([TRACK_WIDTH,
                  LEN_STEPS*_TIE_STEP + JOINT_LENGTH - TIE_SPACING - DDD,
                  TRACK_HEIGHT]);
    }
}

// straight with end-points
module straightG(G) {
    _length = 230 * G;
    _plain_length = _length - 2*_JOINT_EFFECTIVE_LENGTH;
    union() {
        // starting joint
        drawJointX();
        // ending joint
        translate([0, _length])
            rotate(180)
                drawJointX();
        // the rest of the track
        translate([0, _JOINT_EFFECTIVE_LENGTH])
            plainStraight(_plain_length);
    }
}

// straight with tie spaces at the end
// length in mm
module plainStraight(length) {
    _tie_count = round ( (length + TIE_WIDTH) / _TIE_STEP) - 1;
    _tie_spacing = (length - _tie_count*TIE_WIDTH) / (_tie_count+1);
    union() {
        // track
        translate([0,length])
        rotate(90, [1, 0, 0])
            linear_extrude(length)
                trackPlusBaseProfile();
        // ties
        for (i = [1:_tie_count]) {
            _start_length = (i * (TIE_WIDTH+_tie_spacing) - TIE_WIDTH/2);
            translate([0, _start_length])
                drawTie();
        }
    }
}

// curve with end-joints
// joints themselves are straight, so for joint-free part we
// need to have tighter radius
//  TODO draw that romb with height = _JOINT_EFFECTIVE_LENGTH
module curve(Radius, Angle) {
    // TODO works for left (Radius positive)
    _DR = _JOINT_EFFECTIVE_LENGTH / tan(Angle/2);
    _Radius = Radius - _DR;
    union() {
        // starting joint
        drawJointX();
        // ending joint
        translate([-Radius, 0])
            rotate(Angle)
                translate([Radius, 0])
                    rotate(180)
                        drawJointX();
        translate([0, _JOINT_EFFECTIVE_LENGTH])
            plainCurve(_Radius, Angle);
    }
}

// Curve starts and ends with tie spacing
module plainCurve(Radius, Angle) {
    _length = Angle * PI / 180 * Radius;
    echo (_length);
    _tie_count = round ( (_length + TIE_WIDTH) / _TIE_STEP) - 1;
    _tie_spacing = (_length - _tie_count*TIE_WIDTH) / (_tie_count+1);
    union() {
        // track base + track
        translate([-Radius, 0])
            rotate_extrude(angle = Angle, $fn = 200) // TODO $fn
                translate([Radius, 0])
                    trackPlusBaseProfile();
        // ties
        for (i = [1:_tie_count]) {
            _start_length = (i * (TIE_WIDTH+_tie_spacing) - TIE_WIDTH/2);
            translate([-Radius, 0])
                rotate(_start_length / _length * Angle)
                    translate([Radius, 0])
                        drawTie();
        }
    }
}

module trackPlusBaseProfile() {
    union() {
        trackProfile();
        trackBaseProfile();
    }
}

module trackBaseProfile() {
    union() {
        // left profile
        translate([-TRACK_BASE_WIDTH-_TRACK_BASE_DX,0])
            square([TRACK_BASE_WIDTH,
                    TIE_HEIGHT + RENDERING_ERROR]);
        // right profile
        translate([_TRACK_BASE_DX,0])
            square([TRACK_BASE_WIDTH,
                    TIE_HEIGHT + RENDERING_ERROR]);
    }
}

module trackProfile() {
    union() {
        // left profile
        leftTrackProfile();
        // right profile
        rightTrackProfile();
    }
}

module leftTrackProfile() {
    translate([-TRACK_WIDTH-GAUGE/2,TIE_HEIGHT])
        square([TRACK_WIDTH, TRACK_HEIGHT]);
}

module rightTrackProfile() {
    mirror()
        leftTrackProfile();
}

/////////////////////////////////////////

module tie_with_base() {
    union() {
        tie();
        translate([_TRACK_BASE_DX, -TIE_SPACING, 0]) {
            cube([TRACK_BASE_WIDTH, TIE_SPACING, TIE_HEIGHT]);
        }
        translate([-_TRACK_BASE_DX-TRACK_BASE_WIDTH, -TIE_SPACING, 0]) {
            cube([TRACK_BASE_WIDTH, TIE_SPACING, TIE_HEIGHT]);
        }
    }
}

module tie() {
    translate([-_TIE_DX, 0, 0]) {
        cube([TIE_LENGTH, TIE_WIDTH, TIE_HEIGHT]);
    }
}

module tie_half() { // TODO
    cube([TIE_LENGTH / 2, TIE_WIDTH, TIE_HEIGHT]);
}

module base_joint(dx) {
    __JOINT_INDENT = sin(JOINT_RAIL_ANGLE) * TIE_HEIGHT / 2;
    difference() {
        ///
        translate([0,0.001,0])
        rotate(90, [1, 0, 0])
        linear_extrude(height = JOINT_LENGTH + TIE_WIDTH + dx)
            polygon(points =
                [[-JOINT_WIDTH/2 - __JOINT_INDENT - dx, 0-0.01],
                 [JOINT_WIDTH/2 - __JOINT_INDENT  + dx, 0],
                 [JOINT_WIDTH/2 + __JOINT_INDENT  + dx, TIE_HEIGHT+0.01],
                 [-JOINT_WIDTH/2 + __JOINT_INDENT - dx, TIE_HEIGHT]]
        );
        // xxx
//        translate([-2-dx,-2,0])
//            rotate(45, [0,0,1])
//                translate([-JOINT_SIZE/2,-JOINT_SIZE/2,-0.01])
//                    cube([JOINT_SIZE,JOINT_SIZE,TIE_HEIGHT+0.02]);
        // TODO first is depth, second is distance along rail "axis"
        translate([-0.75-dx,-2,-0.01])
                rotate(135, [0,0,1])
                    cube([5,5,TIE_HEIGHT+0.02]);
    }
}

// starting from tie edge
module whole_joint() {
    _left_track_length = JOINT_LENGTH+TIE_WIDTH-DDD;
    _right_track_length = _TIE_STEP-JOINT_LENGTH-DDD;
    union() {
        // joint base
        whole_joint_base();
        // rendering error
        translate([0, TIE_WIDTH+RENDERING_ERROR])
            rotate([90])
                linear_extrude(2*RENDERING_ERROR)
                    trackPlusBaseProfile();
        // left track
        translate([0, TIE_WIDTH])
            rotate([90])
                linear_extrude(_left_track_length)
                    leftTrackProfile();
        // right track
        translate([0, TIE_WIDTH])
            rotate([90])
                linear_extrude(_right_track_length)
                    rightTrackProfile();
    }
}

module whole_joint_base()
{
    difference(){
    union() {
        // very first TIE in joint (small bit)
        translate([0, -_TIE_STEP]) {
            intersection() {
                union() {
                    tie();
                    translate([_TRACK_BASE_DX, 0, 0]) {
                        cube([TRACK_BASE_WIDTH + TRACK_BASE_JOINT_EXTRA_WIDTH, TIE_WIDTH, TIE_HEIGHT]);
                    }
                }
                translate([_TRACK_BASE_DX + TRACK_BASE_WIDTH/2, 0, 0]){
                    cube(TIE_LENGTH, TIE_WIDTH, TIE_HEIGHT);
                };
            }
        };
        // second TIE in joint (bigger bit)
        intersection() {
            tie();
            translate([-(GAUGE/2+TRACK_BASE_WIDTH/5), 0, 0]){
                cube(TIE_LENGTH, TIE_WIDTH, TIE_HEIGHT);
            }
        }
        // joint base sample
        // TODO DDD
        translate([_TRACK_BASE_DX - TRACK_BASE_JOINT_EXTRA_WIDTH, -TIE_SPACING, 0]) {
            cube([TRACK_BASE_WIDTH + 2*TRACK_BASE_JOINT_EXTRA_WIDTH, _TIE_STEP, TIE_HEIGHT]);
        }
        // joint
        translate([_TRACK_BASE_X_CENTRE, TIE_WIDTH]) {
            base_joint(-DDD); // a bit smaller
        }
        // antiwrap
/*        translate([-_TRACK_BASE_DX-TRACK_BASE_WIDTH/2, -_JOINT_EFFECTIVE_LENGTH])
            antiwarp();
        translate([_TRACK_BASE_DX+TRACK_BASE_WIDTH, -_JOINT_EFFECTIVE_LENGTH])
            antiwarp();
*/
    };
        // anti-joint
        translate([-_TRACK_BASE_X_CENTRE, -_TIE_STEP]) {
            //translate([-0.005, 0, -0.001]) scale(1.01)
                rotate(180, [0, 0, 1]) base_joint(DDD); // a bit larger
        };
    }
}

/////
module antiwarp() {
    _length = 5;
    _r = 10; // track dir
    _rx = 15;
    union() {
        translate([-XXX_HEAD_WIDTH/2, -_length-_r])
            cube([XXX_HEAD_WIDTH+0.1, _length+RENDERING_ERROR+_r, TIE_HEIGHT/2]);
        translate([0, -_length-_r]) scale([_rx/_r,1])
            cylinder(TIE_HEIGHT/2,_r,_r);
    }
}