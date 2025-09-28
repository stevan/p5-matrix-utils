

#!perl

use v5.40;
use experimental qw[ class ];

#use Test::More;
#use Test::Exception;

use Time::HiRes qw[ time sleep ];
use Data::Dumper qw[ Dumper ];

use Matrix;
use Vector;

my $m = Matrix->new(
    shape => [ 12, 18 ],
    data  => [ (1) x 216 ]
);

my $ones = Matrix->ones([ 12, 18 ]);

#say $m;

my $offset_x = 3;
my $offset_y = 15;

while (true) {
    $m->run_shader(sub ($x, $y, $c) {
        $x += $offset_x;
        $y += $offset_y;
        $y *= 2; # make it square pixels
        printf "\e[${x};${y}H\e[48;5;${c}m  \e[0m";
    });

    sleep(0.03);
    $m = $m->add($ones);
}

print "\n\n";

#pass("STFU");
#done_testing;
