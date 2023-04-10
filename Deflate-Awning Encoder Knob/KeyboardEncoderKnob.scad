
shaftD = 5.9;

outD = 13.5;

h = 16;

clearD = 10;
clearH = 13;

$fn = 64;

MakeIt();

module MakeIt() {
    difference() {
        
        cylinder(d=outD, h=h);
        
        cylinder(d=shaftD, h=h);
        
        cylinder(d=clearD, h=clearH);
        
    }
}

