
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

    method sum { $self->reduce(\&Operations::add, 0) }

    method min_value { $self->reduce(\&Operations::min, 0) }
    method max_value { $self->reduce(\&Operations::max, 0) }

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
    method le  ($other) { $self->binary_op(\&Operations::lt,  $other) }
    method gt  ($other) { $self->binary_op(\&Operations::gt,  $other) }
    method ge  ($other) { $self->binary_op(\&Operations::ge,  $other) }
    method cmp ($other) { $self->binary_op(\&Operations::cmp, $other) }

    # Logicical Operations
    method not { $self->unary_op(\&Operations::not) }

    # Misc. Operations
    method min ($other) { $self->binary_op(\&Operations::min, $other) }
    method max ($other) { $self->binary_op(\&Operations::max, $other) }

    method trunc { $self->unary_op(\&Operations::trunc) }
    # FIXME: stupid namespace collisions!
    #method floor { $self->unary_op(\&Operations::floor) }
    #method ceil  { $self->unary_op(\&Operations::ceil)  }
    method abs   { $self->unary_op(\&Operations::abs)   }

    # --------------------------------------------------------------------------

    method to_string (@) { return '<' . (join ' ' => @$data) . '>' }

    method to_list { return @$data }
}
