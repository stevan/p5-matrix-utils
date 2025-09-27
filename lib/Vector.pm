
use v5.40;
use experimental qw[ class ];

use Carp;
use List::Util;

use Operations;

class Vector {
    use overload (
        %Operations::OVERLOADS,
        '""' => 'to_string',
    );

    field $size :param :reader;
    field $data :param :reader;

    ADJUST {
        $data = [ ($data) x $size ] unless ref $data;
        Carp::confess "Bad data size, expected ${size} got (".(scalar @$data).")"
            if scalar @$data != $size;
    }

    # --------------------------------------------------------------------------

    method at ($idx) { return $data->[ $idx ] }

    # --------------------------------------------------------------------------

    method sum { $self->reduce(\&Operations::add, 0) }

    method dot_product ($other) {
        my $i = 0;
        return $self->reduce(sub ($acc, $x) { $acc + ($x * $other->at($i++)) }, 0)
    }

    method matrix_multiply ($other) {
        return Vector->new(
            size => $size,
            data => [ map { $self->dot_product($other->col_vector_at($_)) } 0 .. ($size - 1) ]
        )
    }

    # --------------------------------------------------------------------------

    method reduce ($f, $initial) {
        return List::Util::reduce { $f->($a, $b) } $initial, @$data
    }

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

    method neg { $self->unary_op(\&Operations::neg) }

    method add ($other, @) { $self->binary_op(\&Operations::add, $other) }
    method sub ($other, @) { $self->binary_op(\&Operations::sub, $other) }
    method mul ($other, @) { $self->binary_op(\&Operations::mul, $other) }
    method div ($other, @) { $self->binary_op(\&Operations::div, $other) }
    method mod ($other, @) { $self->binary_op(\&Operations::mod, $other) }

    # --------------------------------------------------------------------------

    method to_string (@) { return '<' . (join ' ' => @$data) . '>' }

}
