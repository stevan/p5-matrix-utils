#!perl

use v5.40;
use experimental qw[ class ];

$|++;

#use Test::More;
#use Test::Exception;
#
#pass("STFU");
#done_testing;

use Time::HiRes qw[ time sleep ];
use Data::Dumper qw[ Dumper ];

use Matrix;
use Vector;

my $n = 3;

my $gear  = Vector->initialize(3, [ ((1 / 3600), (1 / 60),  1) ]);
my $mod   = Vector->initialize(3, [ (        24,       60, 60) ]);
my $clock = Vector->initialize(3, 1);

printf("%02d:%02d:%02d\r", ($clock * $gear * $_ % $mod)->to_list ),
#printf("%s      \r", ($clock * $gear * $_ % $mod) ),
    sleep(0.1)
        foreach 0 .. 10000;



