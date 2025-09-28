#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Exception;

use Time::HiRes qw[ time sleep ];
use Data::Dumper qw[ Dumper ];

use Matrix;
use Vector;

use Toys::Shader;

#my $websafe = Toys::Shader->new(
#    matrix  => Toys::Shader::Palettes->WebSafe,
#    palette => 'websafe',
#    shader  => sub ($x, $y, $c) { $c }
#);
#$websafe->run(3, 10);

#my $SIZE   = 32;
#my $factor = 256 / $SIZE;
#
#my $rgb = Toys::Shader->new(
#    matrix  => Matrix->square($SIZE),
#    palette => 'rgb',
#    shader  => sub ($x, $y, $c) {
#        map $_ * $factor,
#            $x + $c,
#            $y + $c,
#            $x + $c,
#    }
#);
#
#$rgb->run(0, 0);
#
#
#print "\n\n";

pass("STFU");
done_testing;
