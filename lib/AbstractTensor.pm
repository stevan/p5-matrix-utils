
use v5.40;
use experimental qw[ class ];

use List::Util;

class AbstractTensor {
    # --------------------------------------------------------------------------
    # Overloads
    # --------------------------------------------------------------------------
    # NOTE: these might get annoying, might wanna remove the,
    # --------------------------------------------------------------------------
    use overload (
        '+'   => sub ($a, $b, @) { $a->add($b) },
        '-'   => sub ($a, $b, $swap) { $swap ? $a->neg : $a->sub($b) },
        '*'   => sub ($a, $b, @) { $a->mul($b) },
        '/'   => sub ($a, $b, @) { $a->div($b) },
        '%'   => sub ($a, $b, @) { $a->mod($b) },
        '**'  => sub ($a, $b, @) { $a->pow($b) },

        '!'   => sub ($n, @)     { $n->not },
        '=='  => sub ($n, $m, @) { $n->eq($m) },
        '!='  => sub ($n, $m, @) { $n->ne($m) },
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

        # to be visible 👀
        '""' => 'to_string',
    );

    # --------------------------------------------------------------------------
    # Internal data array implementation
    # --------------------------------------------------------------------------

    field $shape :param :reader;
    field $data  :param :reader;

    ADJUST {
        $data = [ ($data) x $self->size ] unless ref $data;
        Carp::confess "Bad data size, expected ".$self->size." got (".(scalar @$data).")"
            if scalar @$data != $self->size;
    }

    # --------------------------------------------------------------------------
    # Access to the internal data array
    # --------------------------------------------------------------------------

    method to_list { return @$data }

    method index_data_array ($index) {
        ($index >= 0 && $index < $self->size)
            || Carp::confess "Index out of bounds (${index})";
        return $data->[ $index ];
    }

    method slice_data_array (@indices) {
        ($_ >= 0 && $_ < $self->size)
            || Carp::confess "Index out of bounds (${_})"
                foreach @indices;
        return $data->@[ @indices ]
    }

    method reduce_data_array ($f, $initial) {
        return List::Util::reduce { $f->($a, $b) } $initial, @$data
    }

    # --------------------------------------------------------------------------
    # Abstract Constructors & Methods
    # --------------------------------------------------------------------------

    sub initialize; # ($class, $shape, data[] | scalar $initial)
    sub construct;  # ($class, $shape, $f)

    method rank;
    method size;

    method index; # (@coords) -> index

    method unary_op;  # ($f)         -> tensor
    method binary_op; # ($f, $other) -> tensor

    method to_string;

    # --------------------------------------------------------------------------
    # Static Constructors
    # --------------------------------------------------------------------------

    sub ones  ($class, $shape) { $class->initialize($shape, 1) }
    sub zeros ($class, $shape) { $class->initialize($shape, 0) }

    sub sequence ($class, $shape, $size, $offset=0) {
        $class->initialize([ @$shape ], [ $offset .. ($offset + ($size - 1)) ]);
    }

    # --------------------------------------------------------------------------
    # Element Access
    # --------------------------------------------------------------------------

    method at (@coords) { $self->index_data_array( $self->index(@coords) ) }

    ## -------------------------------------------------------------------------
    ## Math operations
    ## -------------------------------------------------------------------------

    # unary
    method neg { $self->unary_op(\&AbstractTensor::Ops::neg) }
    method abs { $self->unary_op(\&AbstractTensor::Ops::abs) }

    # binary
    method add ($other) { $self->binary_op(\&AbstractTensor::Ops::add, $other) }
    method sub ($other) { $self->binary_op(\&AbstractTensor::Ops::sub, $other) }
    method mul ($other) { $self->binary_op(\&AbstractTensor::Ops::mul, $other) }
    method div ($other) { $self->binary_op(\&AbstractTensor::Ops::div, $other) }
    method mod ($other) { $self->binary_op(\&AbstractTensor::Ops::mod, $other) }
    method pow ($other) { $self->binary_op(\&AbstractTensor::Ops::pow, $other) }

    ## -------------------------------------------------------------------------
    ## Comparison Operations
    ## -------------------------------------------------------------------------

    # binary
    method eq  ($other) { $self->binary_op(\&AbstractTensor::Ops::eq,  $other) }
    method ne  ($other) { $self->binary_op(\&AbstractTensor::Ops::ne,  $other) }
    method lt  ($other) { $self->binary_op(\&AbstractTensor::Ops::lt,  $other) }
    method le  ($other) { $self->binary_op(\&AbstractTensor::Ops::le,  $other) }
    method gt  ($other) { $self->binary_op(\&AbstractTensor::Ops::gt,  $other) }
    method ge  ($other) { $self->binary_op(\&AbstractTensor::Ops::ge,  $other) }
    method cmp ($other) { $self->binary_op(\&AbstractTensor::Ops::cmp, $other) }

    ## -------------------------------------------------------------------------
    ## Logical Operations
    ## -------------------------------------------------------------------------

    method not { $self->unary_op(\&AbstractTensor::Ops::not) }
    method and ($other) { $self->binary_op(\&AbstractTensor::Ops::and, $other) }
    method or  ($other) { $self->binary_op(\&AbstractTensor::Ops::or, $other)  }

    ## -------------------------------------------------------------------------
    ## Numerical Operations
    ## -------------------------------------------------------------------------
    no builtin; # stupid floor/ceil mismatches

    # unary
    method trunc { $self->unary_op(\&AbstractTensor::Ops::trunc) }
    method fract { $self->unary_op(\&AbstractTensor::Ops::fract) }

    method round_down { $self->unary_op(\&AbstractTensor::Ops::round_down) }
    method round_up   { $self->unary_op(\&AbstractTensor::Ops::round_up) }

    method clamp ($min, $max) {
        $self->unary_op(sub ($n) { AbstractTensor::Ops::clamp($min, $max, $n) })
    }

    # binary
    method min ($other) { $self->binary_op(\&AbstractTensor::Ops::min, $other) }
    method max ($other) { $self->binary_op(\&AbstractTensor::Ops::max, $other) }

    ## -------------------------------------------------------------------------
}


package AbstractTensor::Ops {
    use v5.40;

    ## -------------------------------------------------------------------------
    ## Math operations
    ## -------------------------------------------------------------------------

    # unary
    sub neg ($n)     { -$n }
    sub abs ($n)     { abs($n) }

    # binary
    sub add ($n, $m) { $n + $m }
    sub sub ($n, $m) { $n - $m }
    sub mul ($n, $m) { $n * $m }
    sub div ($n, $m) { $n / $m }
    sub mod ($n, $m) { $n % $m }
    sub pow ($n, $m) { $n ** $m }

    ## -------------------------------------------------------------------------
    ## Comparison Operations
    ## -------------------------------------------------------------------------

    # binary
    sub eq  ($n, $m) { $n == $m ? 1 : 0 }
    sub ne  ($n, $m) { $n != $m ? 1 : 0 }
    sub lt  ($n, $m) { $n <  $m ? 1 : 0 }
    sub le  ($n, $m) { $n <= $m ? 1 : 0 }
    sub gt  ($n, $m) { $n >  $m ? 1 : 0 }
    sub ge  ($n, $m) { $n >= $m ? 1 : 0 }

    # binary
    sub cmp ($n, $m) { $n <=> $m }

    ## -------------------------------------------------------------------------
    ## Logical Operations
    ## -------------------------------------------------------------------------

    sub not ($n) { !$n ? 1 : 0 }
    sub and ($n, $m) { $n && $m ? 1 : 0 }
    sub or  ($n, $m) { $n || $m ? 1 : 0 }

    ## -------------------------------------------------------------------------
    ## Numerical Operations
    ## -------------------------------------------------------------------------

    # unary
    sub trunc ($n) { int($n) }
    sub fract ($n) { int($n) - $n }

    sub round_down ($n) { floor($n) }
    sub round_up   ($n) { ceil($n) }

    # binary
    sub min ($n, $m) { $n < $m ? $n : $m }
    sub max ($n, $m) { $n > $m ? $n : $m }

    # ternary
    sub clamp ($min, $max, $n) { max($min, min($max, $n)) }

}





