#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Exception;

use Time::HiRes qw[ time sleep ];
use Data::Dumper qw[ Dumper ];

use Matrix;
use Vector;

use Matrix::TransitionMatrix;



my $m1 = Matrix->initialize([ 3, 3 ], 1);
my $m2 = Matrix->initialize([ 3, 3 ], 0);
my $m3 = Matrix->concat( $m1, $m2 );

say "M1:";
say $m1;

say "M2:";
say $m2;

say "M3:";
say $m3;

say "STACK:";
say Matrix->stack(
    Matrix->concat( $m1, $m2 ),
    Matrix->concat( $m2, $m1 ),
);
