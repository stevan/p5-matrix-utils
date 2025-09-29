
use v5.40;
use experimental qw[ class ];

use Carp;
use List::Util;

use AbstractTensor;

class Vector :isa(AbstractTensor) {
    field $size :param :reader;
    field $data :param :reader;

    ADJUST {
        $data = [ ($data) x $size ] unless ref $data;
        Carp::confess "Bad data size, expected ${size} got (".(scalar @$data).")"
            if scalar @$data != $size;
    }

    method rank { 1 }

    # --------------------------------------------------------------------------
    # Static Constructors
    # --------------------------------------------------------------------------

    sub initialize ($class, $size, $initial) {
        return $class->new( size => $size, data => $initial )
    }

    sub construct ($class, $size, $f) {
        my @new = (0) x $size;
        for (my $i = 0; $i < $size; $i++) {
            $new[$i] = $f->( $i )
        }
        return $class->new( size => $size, data  => \@new );
    }

    sub concat ($class, $a, $b) {
        return $class->new(
            size => ($a->size + $b->size),
            data => [ $a->to_list, $b->to_list ]
        )
    }

    # --------------------------------------------------------------------------
    # accessing elements
    # --------------------------------------------------------------------------

    method at ($idx) {
        Carp::confess "Index out of bounds (${idx})"
            if $idx < 0 || $idx > ($size - 1);
        return $data->[ $idx ]
    }

    method index_of ($value) {
        my $i = 0;
        while ($i < $size) {
            return $i if $self->at( $i ) == $value;
            $i++;
        }
        return -1;
    }

    # --------------------------------------------------------------------------
    # Matrix multiplication
    # --------------------------------------------------------------------------

    method matrix_multiply ($other) {
        return Vector->new(
            size => $other->cols,
            data => [ map { $self->dot_product($other->col_vector_at($_)) } 0 .. ($other->cols - 1) ]
        )
    }

    # --------------------------------------------------------------------------
    # Reductions (scalar results)
    # --------------------------------------------------------------------------

    method reduce ($f, $initial) {
        return List::Util::reduce { $f->($a, $b) } $initial, @$data
    }

    method sum { $self->reduce(\&AbstractTensor::Ops::add, 0) }

    method min_value { $self->reduce(\&AbstractTensor::Ops::min, $data->[0]) }
    method max_value { $self->reduce(\&AbstractTensor::Ops::max, $data->[0]) }

    method dot_product ($other) {
        my $i = 0;
        return $self->reduce(sub ($acc, $x) { $acc + ($x * $other->at($i++)) }, 0)
    }

    # --------------------------------------------------------------------------
    # Element-Wise Operations
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

    method to_string (@) { return '<' . (join ' ' => @$data) . '>' }

    method to_list { return @$data }
}
