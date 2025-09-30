
use v5.40;
use experimental qw[ class ];

use Carp;

use AbstractTensor;

class Vector :isa(AbstractTensor) {
    # --------------------------------------------------------------------------
    # Static Constructors
    # --------------------------------------------------------------------------

    sub concat ($class, $a, $b) {
        return $class->initialize(($a->size + $b->size), [ $a->to_list, $b->to_list ])
    }

    # --------------------------------------------------------------------------
    # accessing elements
    # --------------------------------------------------------------------------

    method index_of ($value) {
        my $i = 0;
        while ($i < $self->size) {
            return $i if $self->at( $i ) == $value;
            $i++;
        }
        return -1;
    }

    # --------------------------------------------------------------------------
    # Matrix multiplication
    # --------------------------------------------------------------------------

    method matrix_multiply ($other) {
        return Vector->initialize(
            $other->cols,
            [ map { $self->dot_product($other->col_vector_at($_)) } 0 .. ($other->cols - 1) ]
        )
    }

    # --------------------------------------------------------------------------
    # Reductions (scalar results)
    # --------------------------------------------------------------------------

    method sum { $self->reduce_data_array(\&AbstractTensor::Ops::add, 0) }

    method min_value { $self->reduce_data_array(\&AbstractTensor::Ops::min, $self->at(0)) }
    method max_value { $self->reduce_data_array(\&AbstractTensor::Ops::max, $self->at(0)) }

    method dot_product ($other) {
        my $i = 0;
        return $self->reduce_data_array(sub ($acc, $x) { $acc + ($x * $other->at($i++)) }, 0)
    }

    # --------------------------------------------------------------------------
    # Element-Wise Operations
    # --------------------------------------------------------------------------

    method unary_op ($f) {
        return Vector->initialize(
            $self->size,
            [ map { $f->( $self->at($_) ) } 0 .. ($self->size - 1) ]
        )
    }

    method binary_op ($f, $other) {
        return Vector->initialize(
            $self->size,
            [ map { $f->( $self->at($_), $other ) } 0 .. ($self->size - 1) ]
        ) unless blessed $other;

        return Vector->initialize(
            $self->size,
            [ map { $f->( $self->at($_), $other->at($_) ) } 0 .. ($self->size - 1) ]
        )
    }

    # --------------------------------------------------------------------------

    method to_string (@) { return '<' . (join ' ' => $self->to_list) . '>' }
}
