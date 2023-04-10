
shaftD = 5.9;

outD = 13.5;

h = 18;

$fn = 64;

MakeIt();

module MakeIt() {
    difference() {
        
        cylinder(d=outD, h=h);
        
        cylinder(d=shaftD, h=h);
        
    }
}

