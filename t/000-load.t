#!perl

use v5.40;
use experimental qw[ class ];

use Data::Dumper qw[ Dumper ];

use Matrix;
use Vector;

my $v1 = Vector->new( size => 2, data => [ 2, 3 ] );
my $v2 = Vector->new( size => 2, data => [ 4, 1 ] );

say 'v1 = ', $v1;
say 'v2 = ', $v2;
say 'v1 . $v2 = ' . $v1->dot_product($v2);
say 'expected: 11';
say '';

my $m1 = Matrix->new( shape => [ 2, 3 ], data => [
    1, 2, 3,
    4, 5, 6,
]);
my $m2 = Matrix->new( shape => [ 3, 2 ], data => [
  7,  8,
  9, 10,
 11, 12,
] );

say "m1 = \n", $m1, "\n";
say "m2 = \n", $m2, "\n";
say "m1 . m2 = \n", $m1->matrix_multiply($m2), "\n";
say q[expected:
|  58  64 |
| 139 154 |
];


my $t = Matrix->eye(10)->shift_horz(1); # + Matrix->diagonal( Vector->new( size => 10, data => 1 ) );
my $s1 = Matrix->new(shape => [ 1, 10 ], data => [ 1, (0) x 9 ]);
my $s1 = Vector->new(size => 10, data => [ 1, (0) x 9 ]);

say "s1 = ", $s1, "\n";
say "t  = \n", $t, "\n";
say "s2 = ", (my $s2 = $s1->matrix_multiply($t));
say "s3 = ", (my $s3 = $s2->matrix_multiply($t));
say "s4 = ", (my $s4 = $s3->matrix_multiply($t));
say "s5 = ", (my $s5 = $s4->matrix_multiply($t));
say "s6 = ", (my $s6 = $s5->matrix_multiply($t));
say "s7 = ", (my $s7 = $s6->matrix_multiply($t));
say "s8 = ", (my $s8 = $s7->matrix_multiply($t));
say "s9 = ", (my $s9 = $s8->matrix_multiply($t));
say "s0 = ", ($s9->matrix_multiply($t));

