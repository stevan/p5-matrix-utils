#!perl

use v5.40;
use experimental qw[ class ];

use Data::Dumper qw[ Dumper ];

use Matrix;
use Vector;


my $x = Matrix->eye(10);
say $x;

say "...";
my $y = ($x + $x->col_vector_at(3) + $x->row_vector_at(5)) * 10;
say $y;

