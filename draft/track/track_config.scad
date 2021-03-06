GAUGE = 16.5;
WHEELS_B = 14.55; // Back to back
WHEELS_K = 15.32; // Back to back + wheel inside gauge part thickness

// 1 - true, 0 - false
XXX_ANTIWARP = 0;

DDD = 0.1;

TRACK_WIDTH = 1.8;
TRACK_HEIGHT = 2.1;

TRACK_BASE_WIDTH = 4;
TRACK_BASE_JOINT_EXTRA_WIDTH = (7-TRACK_BASE_WIDTH) / 2;

TIE_LENGTH = 30;
TIE_WIDTH = 3;
TIE_HEIGHT = 2;
TIE_SPACING = 4.2; // TODO

JOINT_LENGTH = 4.2 + 3 / 2; // TIE_SPACING + TIE_WIDTH / 2;
JOINT_WIDTH = 3; // TODO
JOINT_RAIL_ANGLE = 30;
JOINT_SIZE = 2;

_JOINT_EFFECTIVE_LENGTH = 3 + 4.2 / 2; //TIE_WIDTH + TIE_SPACING / 2;
_TIE_STEP = TIE_WIDTH + TIE_SPACING;
_TIE_DX = TIE_LENGTH / 2;
_TRACK_BASE_DX = GAUGE / 2 - (TRACK_BASE_WIDTH - TRACK_WIDTH) / 2;
_TRACK_BASE_X_CENTRE = -_TRACK_BASE_DX-TRACK_BASE_WIDTH/2;
_TRACK_TOTAL_HEIGHT = TRACK_HEIGHT + TIE_HEIGHT;

RENDERING_ERROR = 0.01;
XXX_HEAD_WIDTH = 0.4;

































































