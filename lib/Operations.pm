
package Operations;

use v5.40;

## ------------------------------------
## NOTE:
## If you use these overloads ....
## you must implement the same methods
## in the class, which is pretty easy
## but just FYI, no magic here
## ------------------------------------

our %OVERLOADS = (
    '+'   => sub ($a, $b, @) { $a->add($b) },
    '-'   => sub ($a, $b, $swap) { $swap ? $a->neg : $a->sub($b) },
    '*'   => sub ($a, $b, @) { $a->mul($b) },
    '/'   => sub ($a, $b, @) { $a->div($b) },
    '%'   => sub ($a, $b, @) { $a->mod($b) },
    '**'  => sub ($a, $b, @) { $a->pow($b) },

    '!'   => sub ($n, @)     { $n->not },
    '=='  => sub ($n, $m, @) { $n->eq($m) },
    '=='  => sub ($n, $m, @) { $n->ne($m) },
    '<'   => sub ($n, $m, @) { $n->lt($m) },
    '<='  => sub ($n, $m, @) { $n->le($m) },
    '>'   => sub ($n, $m, @) { $n->gt($m) },
    '>='  => sub ($n, $m, @) { $n->ge($m) },

    '<=>' => sub ($n, $m, @) { $n->cmp($m) },

    # TODO:
    # - also atan2 cos sin exp abs log sqrt int
    # - consider <> to do some kind of iteration hmmm, 🤔

    # to be clear ...
    'neg' => sub ($a, @) { $a->neg },
);

## Overloaded operations

sub neg ($n)     { -$n }
sub add ($n, $m) { $n + $m }
sub sub ($n, $m) { $n - $m }
sub mul ($n, $m) { $n * $m }
sub div ($n, $m) { $n / $m }
sub mod ($n, $m) { $n % $m }
sub pow ($n, $m) { $n ** $m }

sub eq  ($n, $m) { $n == $m }
sub ne  ($n, $m) { $n == $m }
sub lt  ($n, $m) { $n <  $m }
sub le  ($n, $m) { $n <= $m }
sub gt  ($n, $m) { $n >  $m }
sub ge  ($n, $m) { $n >= $m }
sub cmp ($n, $m) { $n <=> $m }

sub not ($n) { !$n }
# TODO: and, or, xor, etc.

## Misc. Operations

sub min ($n, $m) { $n < $m ? $n : $m }
sub max ($n, $m) { $n > $m ? $n : $m }

sub trunc ($n) { int($n) }

# avoid collision silliness with builtins
sub Operations::floor ($n) { floor($n) }
sub Operations::ceil  ($n) { ceil($n) }
sub Operations::abs   ($n) { abs($n) }


__END__
