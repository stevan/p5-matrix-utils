
use v5.40;
use experimental qw[ class ];

use Carp;

use Tensor;

class Vector :isa(Tensor) {
    # --------------------------------------------------------------------------
    # Vector specific methods
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
    # Static Constructors
    # --------------------------------------------------------------------------

    sub concat ($class, $a, $b) {
        return $class->initialize(($a->size + $b->size), [ $a->to_list, $b->to_list ])
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

    method min_value { $self->reduce_data_array(\&Tensor::Ops::min) }
    method max_value { $self->reduce_data_array(\&Tensor::Ops::max) }

    method dot_product ($other) {
        my $i = 0;
        return $self->reduce_data_array(sub ($acc, $x) { $acc + ($x * $other->at($i++)) }, 0)
    }

    # --------------------------------------------------------------------------

    method to_string (@) { return '<' . (join ' ' => $self->to_list) . '>' }
}
