trackSeparatorSimple([[-20,00],[0,5,2],[10,0], [40,0]],0.1);

module trackSeparatorSimple(Points, D) {
    _buildSeparatorWall(D)
       _buildSeparatorLine(Points); 
}

module _buildSeparatorLine(Points) {
    polygon(concat([[-500,500]],
        _buildSeparatorLine2(Points)
        ,[[500,500]])
        );
}

function _buildSeparatorLine2(Points, i = 0) =
    (i < len(Points) ? 
        concat((len(Points[i]) > 2 ?
                 _trickSeparatrJoint(Points[i], Points[i+1], Points[i][2]) : [Points[i]]),
               _buildSeparatorLine2(Points, i+1))
     : []);

function _trickSeparatrJoint(P1, P2, D) = 
    let (v = [ P2[0]-P1[0], P2[1]-P1[1]],
         dir_v = v / norm(v),
         dir_T = [-dir_v[1], dir_v[0]])
    [[P1[0], P1[1]],
     [P1[0] + D*(-dir_v[0]+dir_T[0]), P1[1] + D*(-dir_v[1]+dir_T[1])],
     [P2[0] + D*(dir_v[0]+dir_T[0]), P2[1] + D*(+dir_v[1]+dir_T[1])]];

module _buildSeparatorWall(D) {
    translate([0,0,-10])
    linear_extrude(20)
    difference() {
        offset(D) children(0);
        offset(-D) children(0);
    }
}
