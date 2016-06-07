gauge=24;
// testlaius
/*translate([30,-gauge/2,4])
 cube([4,gauge,4]);*/
//translate([0, 50, 0])
 sirge(leng = 50, supp = 1);
/*translate([-0,0,0])
 rotate([0,0,180])
  sirge(leng = 50, supp = 1);*/

module sirge(leng=225, supp=5)
{
  translate([0,gauge/2+3,0])
   roobas(leng);
  translate([leng-4,-gauge/2-3,0])
   rotate([0,0,180])
    roobas(leng);
  samm = (leng-31.5)/supp - 1;
  for(n = [0 : supp])
  {
    translate([12.5 + samm*n, 0, 0])
     suurpalk();
  }
  translate([0, 0, 0])
   ots();
  translate([leng-4, 0, 0])
   rotate([0,0,180])
    ots();
  translate([4,-2,3.7])
   scale(0.5)
    rotate([0,0,-90])
     linear_extrude(0.5)
      text("v9");
}

module profiil() {
 udx=1.7;
 udy=7.6-1.2-2.5;
 mdx=3.8;
 mdy=1.2;
 ldx=1.7;
 ldy=2.5;
 translate([0,mdy+ldy,0])
 union() {
  // upper (rail)
  translate([0,udy/2,0])
   square([udx,udy], true);
  // middle (below rail)
  translate([0,-mdy/2,0])
   square([mdx,mdy], true);
  // lower part
  // 4---1
  //  3-2
  translate([0,-mdy-ldy/2,0])
   polygon([
    [mdx/2,ldy/2],//1
    [ldx/2,-ldy/2],//2
    [-ldx/2,-ldy/2],//3
    [-mdx/2,ldy/2]]);//4
 }
}
//profiil();
module roobas(leng = 225)
{
  len = leng;
  u_w = 1.7; // upper wid
  m_w = 3.80; // middle wid
  m_h = 1.2; // middle hei
  h = 7.6; //whole hei
  m_l = 2.5; // middle lower
  translate([0,u_w-m_w,0])
  difference() 
  {
    rotate([90, 0, 90])
    linear_extrude(len)
    profiil();
    translate([-0.1, -2, 3.7])
     cube([4.5, 4, 4]);
    translate([leng-4, -2, -0.3])
     cube([4.2, 4, 4]);
    // cut the rail
    translate([4,-2.6,3.7])
     rotate([0,0,-2.5])
      cube([6,2,4]);
    translate([leng-5.8,-2.85,3.7])
     rotate([0,0,2.5])
      cube([6,2,4]);
  }  
}
//roobas();
module palk()
{
 translate([0,0,2.64])
  cube([6.64, 42.3, 1.64]);
}
//palk();
module suurpalk()
{
 vo=6;
 translate([0,-(gauge/2+vo),0])
  cube([3.5, gauge+vo*2, 4.3]);
}
//suurpalk();
module ots()
{
  ol=gauge+2;
  dy=-8;
  ddy=0.5;
    difference()
    {
     union()
     {
       // plaat
      translate([0, -ol/2, 2.5])
       cube([16,ol,1.2]);
      // aas
      translate([3.5,-ddy*6,0])
       cube([3,15,3]);
      // klamber
      //translate([-3.0,-8,1])
       //cube([7,7,1.5]);
      // keel
      translate([-10.5,dy+ddy,1])
       cube([13,7.5,1.5]);
      // keele tipp
      rotate([0,-10,0])
       translate([-10.2,dy+ddy,3.3])
        cube([1.6,7.5,1.1]);
      // support
      translate([0.5,-1,0.5])
       cube([6,1,2.5]);
      translate([0.5,-7.5,0.5])
       cube([5,1,2.5]);
     }
     union()
     {
       // auk läbi plaadi
       translate([2.5,0,0.8])
        cube([5,8.5,3.5]);
       // süvend all
       translate([8.2,0,0.6])
        cube([3,8.5,2.4]);
       // tipu lõige
       rotate([0,10,0])
        translate([-12,dy,1.2])
         cube([4,8,2]);
       // klambri lõige
       rotate([0,3,0])
        translate([-12,dy,-1])
         cube([12,8.5,2]);
     }
    }
}
//ots();
