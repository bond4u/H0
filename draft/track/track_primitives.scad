include <track_config.scad>

// 1. just a joint base
drawJointBase();

////////////////////////////// API ///////////////////////////////////////////

/// One half of joint (base, no tracks).
module drawJointBase() {translate([0, TIE_SPACING/2]) whole_joint_base();};

/// One half of whole joint (base + tracks).
/// Error margin added.
module drawJointX() {translate([0, TIE_SPACING/2]) whole_joint();};

/// Tie, center of tie is in the origin
module drawTie() {
    translate([0, -TIE_WIDTH/2]) tie();
}

//////////////////////////////////////////////////////////////////////////////

//================== TIE ==================
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

//================== JOINT =====================

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
                tie();
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
        if (XXX_ANTIWARP > 0) {
            translate([-_TRACK_BASE_DX-TRACK_BASE_WIDTH/2, -_JOINT_EFFECTIVE_LENGTH])
                antiwarp();
            translate([_TRACK_BASE_DX+TRACK_BASE_WIDTH, -_JOINT_EFFECTIVE_LENGTH])
                antiwarp();
        }
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

//===================== TRACK ============================
module trackPlusBaseProfile(DrawTrackFlag = 1+2+4+8) {
    union() {
        trackProfile(DrawTrackFlag);
        trackBaseProfile(DrawTrackFlag);
    }
}

module trackBaseProfile(DrawTrackFlag=4+8) {
    union() {
        // left profile
        if (floor(DrawTrackFlag/4)%2==1) {
            translate([-TRACK_BASE_WIDTH-_TRACK_BASE_DX,0])
                square([TRACK_BASE_WIDTH,
                        TIE_HEIGHT + RENDERING_ERROR]);
        }
        // right profile
        if (floor(DrawTrackFlag/8)%2==1) {
            translate([_TRACK_BASE_DX,0])
                square([TRACK_BASE_WIDTH,
                        TIE_HEIGHT + RENDERING_ERROR]);
        }
    }
}

module trackProfile(DrawTrackFlag) {
    union() {
        // left profile
        if (DrawTrackFlag%2==1){
            leftTrackProfile();
        }
        // right profile
        if (floor(DrawTrackFlag/2)%2==1){
            rightTrackProfile();
        }
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
