include <track_config.scad>
use <track_primitives.scad>

//demo_track_basic();
module demo_track_basic(){
    translate([0,0]) drawCurveRocoR(2, 15);
    translate([-75,0]) drawStraightG(1/2);
}

_straight(20);

//================ main ================

// 2. sample on how joints fit together
// TODO rail(); translate([0,-4.3,0]) rotate([0,0,180]) rail();

// Roco R2 curve left, 15 degrees
//drawCurve(358, 15);

// Roco G1/2 115mm
//drawStraightG(1/2);

//drawCurve(358, 15);
//translate([0,-115,0])
//drawStraightG(1/2);

//drawSwitch(230, -358, 30);

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

//- R2 -> 358mm radius (12pc., 30º each)
//- R3 -> 419,6mm " " "
//- R4 -> 481,2mm " " "
//- R5 -> 542,8mm " " "
//- R6 -> 604,4mm " " "
//- R9 -> 826,4mm " (24pc., 15º each)????
// negative = turn right;
module drawCurveRocoR(R, Angle) {curve(sign(R)*(358+61.6*(abs(R)-2)), Angle);}


/// Radius - millimeters (measured to the centre of the track;
///          negative -> turn right)
/// Angle - degrees
/// Seems as left curve, but you know, look from another side,
/// and it is right curve ;)
module drawCurve(Radius, Angle) {curve(Radius, Angle);}

/// G4 920mm
/// G1 230mm
/// G1/2 115mm
/// G1/4 57,5mm
module drawStraightG(G) {straightG(G);}

// straight with end-points
module straightG(G) {
    _straight(230 * G);
}

module _straight(Length, DrawBaseFlag=1, DrawTrackFlag=1+2+4+8) {
    _length = Length;
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
            _plainStraight(_plain_length, DrawBaseFlag, DrawTrackFlag);
    }
}

// straight with tie spaces at the end
// length in mm
module _plainStraight(length, DrawBaseFlag=1, DrawTrackFlag = 1+2+4+8) {
    _tie_count = round ( (length + TIE_WIDTH) / _TIE_STEP) - 1;
    _tie_spacing = (length - _tie_count*TIE_WIDTH) / (_tie_count+1);
    union() {
        // track
        translate([0,length])
        rotate(90, [1, 0, 0])
            linear_extrude(length)
                trackPlusBaseProfile(DrawTrackFlag);
        // ties
        if (DrawBaseFlag) {
            for (i = [1:_tie_count]) {
                _start_length = (i * (TIE_WIDTH+_tie_spacing) - TIE_WIDTH/2);
                translate([0, _start_length])
                    drawTie();
            }
        }
    }
}

// curve with end-joints
// joints themselves are straight, so for joint-free part we
// need to have tighter radius
//  TODO draw that romb with height = _JOINT_EFFECTIVE_LENGTH
module curve(Radius, Angle, DrawBaseFlag=1, DrawTrackFlag=1+2+4+8) {
    // TODO works for left (Radius positive)
    _DR = _JOINT_EFFECTIVE_LENGTH / tan(Angle/2);
    _Radius = sign(Radius) * (abs(Radius) - _DR);
    Angle = sign(_Radius) * Angle;
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
            plainCurve(_Radius, Angle, DrawBaseFlag, DrawTrackFlag);
    }
}

// Curve starts and ends with tie spacing
module plainCurve(Radius, Angle, DrawBaseFlag=1, DrawTrackFlag=1+2) {
    _length = Angle * PI / 180 * Radius;
    _tie_count = round ( (_length + TIE_WIDTH) / _TIE_STEP) - 1;
    _tie_spacing = (_length - _tie_count*TIE_WIDTH) / (_tie_count+1);
    union() {
        // track base + track
        translate([-Radius, 0])
            rotate_extrude(angle = Angle, $fn = 200) // TODO $fn
                translate([Radius, 0])
                    trackPlusBaseProfile(DrawTrackFlag);
        if (DrawBaseFlag) {
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
}
