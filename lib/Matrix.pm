
use v5.40;
use experimental qw[ class ];

use Carp;

use Vector;
use Operations;

class Matrix {
    use overload (
        %Operations::OVERLOADS,
        '""' => 'to_string',
    );

    field $shape :param;
    field $data  :param;

    ADJUST {
        $data = [ ($data) x $self->size ] unless ref $data;
        Carp::confess "Bad data size, expected ".$self->size." got (".(scalar @$data).")"
            if scalar @$data != $self->size;
    }

    # --------------------------------------------------------------------------
    # Private methods
    # --------------------------------------------------------------------------

    method _slice (@indices) {
        ($_ >= 0 && $_ < $self->size)
            || Carp::confess "Index out of bounds (${_})"
                foreach @indices;
        return $data->@[ @indices ]
    }

    # --------------------------------------------------------------------------
    # Accessors
    # --------------------------------------------------------------------------

    method copy_shape { [ @$shape ] }

    method rows { $shape->[0] }
    method cols { $shape->[1] }

    method height { $self->rows - 1 }
    method width  { $self->cols - 1 }

    method size { $self->rows * $self->cols }

    # --------------------------------------------------------------------------
    # Static Constructors
    # --------------------------------------------------------------------------

    sub initialize ($class, $shape, $initial) {
        return $class->new( shape => [ @$shape ], data => $initial )
    }

    sub construct ($class, $shape, $f) {
        my ($rows, $cols) = @$shape;

        my @new = (0) x ($rows * $cols);
        for (my $x = 0; $x < $rows; $x++) {
            for (my $y = 0; $y < $cols; $y++) {
                $new[$x * $cols + $y] = $f->( $x, $y )
            }
        }

        return $class->new(
            shape => [ @$shape ],
            data  => \@new
        )
    }

    # --------------------------------------------------------------------------
    # Matrix Type Static Constructors
    # --------------------------------------------------------------------------

    sub eye ($class, $size) {
        return $class->new(
            shape => [ $size, $size ],
            data  => [ map { (0) x ($_ - 1), 1, (0) x ($size - $_) } 1 .. $size ]
        )
    }

    sub diagonal ($class, $vector) {
        my $size = $vector->size;

        my @new = (0) x ($size * $size);
        for (my $x = 0; $x < $size; $x++) {
            $new[$x * $size + $x] = $vector->at($x);
        }

        return $class->new(
            shape => [ $size, $size ],
            data  => \@new
        );
    }

    # --------------------------------------------------------------------------
    # Index calculators
    # --------------------------------------------------------------------------

    method index ($x, $y) {
        Carp::confess "Coord out of bounds x(${x})" if $x > $self->height;
        Carp::confess "Coord out of bounds x(${y})" if $y > $self->width;
        return $x * $self->cols + $y;
    }

    method row_indices ($x) {
        Carp::confess "Coord out of bounds x(${x})" if $x > $self->height;
        return $self->index( $x, 0 ) .. $self->index( $x, $self->width )
    }

    method col_indices ($y) {
        Carp::confess "Coord out of bounds x(${y})" if $y > $self->width;
        return map { $self->index( $_, $y ) } 0 .. $self->height;
    }

    # --------------------------------------------------------------------------
    # Accessing Elements
    # --------------------------------------------------------------------------

    method at ($x, $y) { $self->_slice( $self->index($x, $y) ) }

    method row_vector_at ($x) {
        return Vector->new(
            size => $self->cols,
            data => [ $self->_slice( $self->row_indices($x) ) ],
        )
    }

    method col_vector_at ($y) {
        return Vector->new(
            size => $self->rows,
            data => [ $self->_slice( $self->col_indices($y) ) ],
        )
    }

    # --------------------------------------------------------------------------
    # Moving elements
    # --------------------------------------------------------------------------

    method shift_horz ($by) {
        $by = -$by;

        return __CLASS__->construct(
            $self->copy_shape,
            sub ($x, $y) {
                return $self->_slice( $x * $self->cols + ($y + $by) )
                    if ($y + $by) >= 0 && $y < ($self->cols - $by);
                return 0;
            }
        )
    }

    # --------------------------------------------------------------------------
    # Generic Operations
    # --------------------------------------------------------------------------

    method unary_op ($f) {
        return __CLASS__->construct(
            $self->copy_shape,
            sub ($x, $y) { $f->( $self->at($x, $y) ) }
        )
    }

    method binary_op ($f, $other) {
        return __CLASS__->construct(
            $self->copy_shape,
            sub ($x, $y) { $f->( $self->at($x, $y), $other ) }
        ) unless blessed $other;

        return __CLASS__->construct(
            $self->copy_shape,
            sub ($x, $y) { $f->( $self->at($x, $y), $other->at($y) ) }
        ) if $other isa Vector;

        return __CLASS__->construct(
            $self->copy_shape,
            sub ($x, $y) { $f->( $self->at($x, $y), $other->at($x, $y) ) }
        )
    }

    # --------------------------------------------------------------------------
    # Math Operations
    # --------------------------------------------------------------------------

    method neg { $self->unary_op(\&Operations::neg) }

    method add ($other, @) { $self->binary_op(\&Operations::add, $other) }
    method sub ($other, @) { $self->binary_op(\&Operations::sub, $other) }
    method mul ($other, @) { $self->binary_op(\&Operations::mul, $other) }
    method div ($other, @) { $self->binary_op(\&Operations::div, $other) }
    method mod ($other, @) { $self->binary_op(\&Operations::mod, $other) }

    # --------------------------------------------------------------------------
    # Matrix Multiplication
    # --------------------------------------------------------------------------

    method matrix_multiply ($other) {
        # Matrix × Vector: Matrix (m×n) × Vector (n) = Vector (m)
        if ($other isa Vector) {
            return Vector->new(
                size => $self->rows,
                data => [ map { $self->row_vector_at($_)->dot_product($other) } 0 .. ($self->rows - 1) ]
            );
        }

        # Matrix × Matrix: Matrix (m×n) × Matrix (n×p) = Matrix (m×p)
        return __CLASS__->construct(
            [ $self->rows, $other->cols ],
            sub ($x, $y) {
                $self->row_vector_at($x)
                        ->dot_product($other->col_vector_at($y));
            }
        )
    }

    # --------------------------------------------------------------------------

    method to_string (@) {
        my @out;
        for (my $x = 0; $x < $self->rows; $x++) {
            push @out =>
                join ' ' =>
                    map { sprintf('%3d', $_) }
                        $self->_slice( $self->row_indices( $x ) );
        }
        return join "\n" => @out;
    }

}
