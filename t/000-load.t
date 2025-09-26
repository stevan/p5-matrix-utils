#!perl

use v5.40;
use experimental qw[ class ];

use Data::Dumper qw[ Dumper ];


use Matrix;
use Vector;


my $m1 = Matrix->new( shape => [ 10, 10 ], data => 1 );
my $m2 = Matrix->new( shape => [ 10, 10 ], data => 2 );

my $v1 = Vector->new( size => 10, data => [ 0 .. 9 ] );
my $v2 = Vector->new( size => 10, data => 1 );

say Matrix->diagonal($v1)->shift_horz(1) + Matrix->eye([ 10, 10 ]);




