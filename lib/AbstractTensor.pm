
use v5.40;
use experimental qw[ class ];

use Operations;

class AbstractTensor {
    use List::Util qw[ reduce ];

    use overload (
        %Operations::OVERLOADS,
        '""' => 'to_string',
    );

    ## -------------------------------------------------------------------------

    sub initialize; # ($class, $shape, data[] | scalar $initial)
    sub construct;  # ($class, $shape, $f)

    sub ones  ($class, $shape) { $class->initialize($shape, 1) }
    sub zeros ($class, $shape) { $class->initialize($shape, 0) }

    sub sequence ($class, $shape, $size, $offset=0) {
        $class->initialize([ @$shape ], [ $offset .. ($offset + ($size - 1)) ]);
    }

    ## -------------------------------------------------------------------------

    method rank;
    method shape;

    ## -------------------------------------------------------------------------

    method index; # (@coords) -> index
    method at;    # (@coords) -> value

    ## -------------------------------------------------------------------------

    method unary_op;  # ($f)         -> tensor
    method binary_op; # ($f, $other) -> tensor

    # Math Operations
    method neg { $self->unary_op(\&Operations::neg) }

    method add ($other) { $self->binary_op(\&Operations::add, $other) }
    method sub ($other) { $self->binary_op(\&Operations::sub, $other) }
    method mul ($other) { $self->binary_op(\&Operations::mul, $other) }
    method div ($other) { $self->binary_op(\&Operations::div, $other) }
    method mod ($other) { $self->binary_op(\&Operations::mod, $other) }

    # Comparison Operations
    method eq  ($other) { $self->binary_op(\&Operations::eq,  $other) }
    method ne  ($other) { $self->binary_op(\&Operations::ne,  $other) }
    method lt  ($other) { $self->binary_op(\&Operations::lt,  $other) }
    method le  ($other) { $self->binary_op(\&Operations::le,  $other) }
    method gt  ($other) { $self->binary_op(\&Operations::gt,  $other) }
    method ge  ($other) { $self->binary_op(\&Operations::ge,  $other) }
    method cmp ($other) { $self->binary_op(\&Operations::cmp, $other) }

    # Logicical Operations
    method not { $self->unary_op(\&Operations::not) }

    # Misc. Operations
    method min ($other) { $self->binary_op(\&Operations::min, $other) }
    method max ($other) { $self->binary_op(\&Operations::max, $other) }

    method trunc { $self->unary_op(\&Operations::trunc) }
    method fract { $self->unary_op(\&Operations::fract) }
    # FIXME: stupid namespace collisions!
    #method floor { $self->unary_op(\&Operations::floor) }
    #method ceil  { $self->unary_op(\&Operations::ceil)  }
    method abs   { $self->unary_op(\&Operations::abs)   }

    ## -------------------------------------------------------------------------

    method to_string;
}

