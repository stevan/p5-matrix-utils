

#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Exception;

use Time::HiRes qw[ time sleep ];
use Data::Dumper qw[ Dumper ];

use Matrix;
use Vector;

my $m1 = Matrix->initialize([3, 3], 0);
my $m2 = Matrix->initialize([3, 3], 3);

say "M1:";
say $m1;

say "M2:";
say $m2;

my $mask = Matrix->eye(3);
my $m3 = Matrix->construct(
    [ 3, 3 ],
    sub ($x, $y) {
        if ($mask->at($x, $y) == 0) {
            return $m1->at( $x, $y );
        } else {
            return $m2->at( $x, $y );
        }
    }
);

say "M1->MASK(M2, MASK):";
say $m3;

say $m3->sum;


pass("STFU");
done_testing;
