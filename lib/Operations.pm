
package Operations;

use v5.40;

our %OVERLOADS = (
    '+'  => 'add',
    '-'  => 'sub',
    '*'  => 'mul',
    '/'  => 'div',
    '%'  => 'mod',
);

sub neg ($n)     { -$n }
sub add ($n, $m) { $n + $m }
sub sub ($n, $m) { $n - $m }
sub mul ($n, $m) { $n * $m }
sub div ($n, $m) { $n / $m }
sub mod ($n, $m) { $n % $m }



__END__
