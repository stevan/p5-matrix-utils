
use v5.40;
use experimental qw[ class ];

class Vector {
    use List::Util qw[ min max ];

    use overload (
        '+'  => 'add',
        '-'  => 'sub',
        '*'  => 'mul',
        '/'  => 'div',
        '%'  => 'mod',
        '""' => 'to_string',
    );

    field $size :param :reader;
    field $data :param :reader;

    ADJUST {
        $data = [ ($data) x $size ] unless ref $data;
        die "Bad data size, expected ${size} got (".(scalar @$data).")"
            if scalar @$data != $size;
    }

    method at ($idx) { return $data->[ $idx ] }

    # --------------------------------------------------------------------------

    method unary_op ($f) {
        return Vector->new(
            size => $size,
            data => [ map $f->($_), @$data ]
        )
    }

    method binary_op ($f, $other) {
        return Vector->new(
            size => $size,
            data => [ map { $f->( $self->at($_), $other ) } 0 .. ($size - 1) ]
        ) unless blessed $other;

        return Vector->new(
            size => $size,
            data => [ map { $f->( $self->at($_), $other->at($_) ) } 0 .. ($size - 1) ]
        )
    }

    # --------------------------------------------------------------------------

    method neg { $self->unary_op(sub ($n) { -$n }) }

    method add ($other, @) { $self->binary_op(sub ($n, $m) { $n + $m }, $other) }
    method sub ($other, @) { $self->binary_op(sub ($n, $m) { $n - $m }, $other) }
    method mul ($other, @) { $self->binary_op(sub ($n, $m) { $n * $m }, $other) }
    method div ($other, @) { $self->binary_op(sub ($n, $m) { $n % $m }, $other) }
    method mod ($other, @) { $self->binary_op(sub ($n, $m) { $n / $m }, $other) }

    # --------------------------------------------------------------------------

    method to_string (@) { return '<' . (join ' ' => @$data) . '>' }

}
