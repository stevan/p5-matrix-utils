
use v5.40;
use experimental qw[ class ];

use Carp;
use List::Util;

use AbstractTensor;
use Vector;
use Operations;

class Matrix :isa(AbstractTensor) {
    field $shape :param :reader;
    field $data  :param :reader;

    ADJUST {
        $data = [ ($data) x $self->size ] unless ref $data;
        Carp::confess "Bad data size, expected ".$self->size." got (".(scalar @$data).")"
            if scalar @$data != $self->size;
    }

    method rank { 2 }

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

    method norms { [ $self->height, $self->width ] }

    method size { $self->rows * $self->cols }

    # --------------------------------------------------------------------------
    # Static Constructors
    # --------------------------------------------------------------------------

    sub initialize ($class, $shape, $initial) {
        return $class->new( shape => [ @$shape ], data => $initial )
    }

    # Build via f(x, y) ________________________________________________________

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

    # Building from others _____________________________________________________

    sub concat ($class, $a, $b) {
        Carp::confess "Rows must be equal to concat (".($a->rows).") != (".($a->rows).")"
            unless $a->rows == $b->rows;
        my @shape = ($a->rows, $a->cols + $b->cols);
        return $class->construct(
            \@shape,
            sub ($x, $y) {
                ($y < $a->cols) ? $a->at($x, $y) : $b->at($x, ($y - $a->cols));
            }
        )
    }

    sub stack ($class, $a, $b) {
        Carp::confess "Cols must be equal to stack (".($a->cols).") != (".($a->cols).")"
            unless $a->cols == $b->cols;
        my @shape = ($a->rows + $b->rows, $a->cols);
        return $class->construct(
            \@shape,
            sub ($x, $y) {
                ($x < $a->rows) ? $a->at($x, $y) : $b->at(($x - $a->rows), $y);
            }
        )
    }

    # Misc. Matrix Types _______________________________________________________

    sub square ($class, $size, $initial=0) {
        $class->initialize([ $size, $size ], $initial)
    }

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
    # Accessing Elements & Groups of Elements
    # --------------------------------------------------------------------------

    method at ($x, $y) { $self->_slice( $self->index($x, $y) ) }

    method row_at ($x) { $self->_slice( $self->row_indices($x) ) }
    method col_at ($y) { $self->_slice( $self->col_indices($y) ) }

    # TODO:
    # - some way of accessing the main diagonal
    #   - or with an offset
    # - getting a random rectangle
    # - getting a quadrant

    # --------------------------------------------------------------------------
    # Accessing Row/Col as Vectors
    # --------------------------------------------------------------------------

    method row_vector_at ($x) {
        return Vector->new(size => $self->cols, data => [ $self->row_at($x) ]);
    }

    method col_vector_at ($y) {
        return Vector->new(size => $self->rows, data => [ $self->col_at($y) ]);
    }

    # --------------------------------------------------------------------------
    # Moving elements
    # --------------------------------------------------------------------------

    # API IDEA:
    # The $wrap arg default is false, but if true, the
    # - shift_cols( $by, $wrap ) where $by is + (go right), and - (go left)
    # - shift_rows( $by, $wrap ) where $by is + (go down), and - (go up)
    # - shift( $by, $direction ) where $dir = N,S,E,W along with NE, NW, etc.

    # rename to shift_cols
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

    # TODO:
    # - add shift_vert
    # - or add shift( $dir, $by ) where $dir = N,S,E,W along with NE, NW, etc.
    #      - could represent the entire shift with a 3x3

    # FIXME: this is a poor name, fix it ...
    method copy_row ($from, $to) {
        return __CLASS__->construct(
            $self->copy_shape,
            sub ($x, $y) {
                return $self->at($from, $y) if $x == $to;
                return $self->at($x, $y);
            }
        )
    }

    # TODO:
    # - copy_column
    # - probably some others, can't think of any specific ones atm.

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
    # Reductions (scalar results)
    # --------------------------------------------------------------------------
    # FIXME:
    # these access data directly, which they should not!


    method reduce ($f, $initial) {
        return List::Util::reduce { $f->($a, $b) } $initial, @$data
    }

    method sum { $self->reduce(\&Operations::add, 0) }

    method min_value { $self->reduce(\&Operations::min, $data->[0]) }
    method max_value { $self->reduce(\&Operations::max, $data->[0]) }

    # --------------------------------------------------------------------------
    # Element-Wise Operations
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

    method to_string (@) {
        my @out;
        for (my $x = 0; $x < $self->rows; $x++) {
            push @out =>
                join ' ' =>
                    map { sprintf('%3s', $_) }
                        $self->_slice( $self->row_indices( $x ) );
        }
        return join "\n" => @out;
    }
}
