
use v5.40;
use experimental qw[ class ];

use Matrix;


use constant ___ => 0;
use constant ISA => 1; # Class inherits from class
use constant CAN => 2; # Class contains method
use constant OVR => 3; # Method overrides ancestor method

my $MOP = Matrix->initialize([ 7, 7 ] [
#[Obj]    [Ani][spk][mov]     [Dog][spk][brk]
 ___,      ___, ___, ___,      ___, ___, ___,  # Object

 ISA,      ___, ___, ___,      ___, ___, ___,  # Animal ISA Object
 ___,      CAN, ___, ___,      ___, ___, ___,  # speak() contained in Animal
 ___,      CAN, ___, ___,      ___, ___, ___,  # move() contained in Animal

 ISA,      ___, ___, ___,      ___, ___, ___,  # Dog ISA Animal
 ___,      ___, OVR, ___,      CAN, ___, ___,  # speak() overrides Animal.speak, contained in Dog
 ___,      ___, ___, ___,      CAN, ___, ___,  # bark() contained in Dog
]);

