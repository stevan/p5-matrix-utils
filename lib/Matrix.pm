
use v5.40;
use experimental qw[ class ];

use Vector;
use Operations;
use Matrix::Strategy;

class Matrix {
    use List::Util qw[ min max ];

    use overload (
        %Operations::OVERLOADS,
        '""' => 'to_string',
    );

    field $shape :param :reader;
    field $data  :param :reader;

    field $size :reader;

    ADJUST {
        $size = $shape->[0] * $shape->[1];
        $data = [ ($data) x $size ] unless ref $data;
        die "Bad data size, expected ${size} got (".(scalar @$data).")"
            if scalar @$data != $size;
    }

    # --------------------------------------------------------------------------

    sub eye      ($, $size)   { Matrix::Strategy->eye($size)        }
    sub diagonal ($, $vector) { Matrix::Strategy->diagonal($vector) }

    # --------------------------------------------------------------------------

    method shift_horz ($by) {
        my ($rows, $cols) = @$shape;

        $by = -$by;

        return Matrix::Strategy->transform(
            [ @$shape ],
            sub ($x, $y) {
                return $data->[ $x * $rows + ($y + $by) ]
                    if ($y + $by) >= 0 && $y < ($cols - $by);
                return 0;
            }
        )
    }

    # --------------------------------------------------------------------------

    method at ($x, $y) { return $data->[ $x * $shape->[1] + $y ] }

    method index ($x, $y) { $x * $shape->[1] + $y }

    method row_indices ($x) {
        return $self->index( $x, 0 ) .. $self->index( $x, ($shape->[1] - 1) )
    }

    method col_indices ($y) {
        my ($rows, $cols) = @$shape;
        return map { $cols * $_ + $y } 0 .. ($rows - 1);
    }

    # --------------------------------------------------------------------------

    method row_vector_at ($x) {
        return Vector->new(
            size => $shape->[1],
            data => [ $data->@[ $self->row_indices($x) ] ],
        )
    }

    method col_vector_at ($y) {
        return Vector->new(
            size => $shape->[0],
            data => [ $data->@[ $self->col_indices($y) ] ],
        )
    }

    # --------------------------------------------------------------------------

    method unary_op ($f) {
        return Matrix::Strategy->transform(
            [ @$shape ],
            sub ($x, $y) { $f->( $self->at($x, $y) ) }
        )
    }

    method binary_op ($f, $other) {
        return Matrix::Strategy->transform(
            [ @$shape ],
            sub ($x, $y) { $f->( $self->at($x, $y), $other ) }
        ) unless blessed $other;

        return Matrix::Strategy->transform(
            [ @$shape ],
            sub ($x, $y) { $f->( $self->at($x, $y), $other->at($y) ) }
        ) if $other isa Vector;

        return Matrix::Strategy->transform(
            [ @$shape ],
            sub ($x, $y) { $f->( $self->at($x, $y), $other->at($x, $y) ) }
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

    method matrix_multiply ($other) {
        return Matrix::Strategy->transform(
            [ $shape->[0], $other->shape->[1] ],
            sub ($x, $y) {
                $self->row_vector_at($x)
                        ->dot_product($other->col_vector_at($y));
            }
        )
    }

    # --------------------------------------------------------------------------

    method to_string (@) {
        my ($rows, $cols) = @$shape;
        my @out;
        for (my $x = 0; $x < $rows; $x++) {
            push @out =>
                join ' ' =>
                    map { sprintf('%3d', $_) }
                        $data->@[ $self->row_indices( $x ) ];
        }
        return join "\n" => @out;
    }

}
