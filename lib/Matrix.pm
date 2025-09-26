
use v5.40;
use experimental qw[ class ];


package Matrix::Builder {
    sub eye ($, $eye_shape) {
        my ($rows, $cols) = @$eye_shape;

        return Matrix->new(
            shape => $eye_shape,
            data  => [ map { (0) x ($_ - 1), 1, (0) x ($rows - $_) } 1 .. $rows ]
        )
    }

    sub diagonal ($, $vector) {
        my $vsize = $vector->size;
        my $msize = $vsize * $vsize;

        my @new = (0) x $msize;
        for (my $x = 0; $x < $vsize; $x++) {
            $new[$x * $vsize + $x] = $vector->at($x);
        }

        return Matrix->new(
            shape => [ $vsize, $vsize ],
            data  => \@new
        );
    }

    sub transform ($, $shape, $f) {
        my ($rows, $cols) = @$shape;

        my @new = (0) x ($rows * $cols);
        for (my $x = 0; $x < $rows; $x++) {
            for (my $y = 0; $y < $cols; $y++) {
                $new[$x * $rows + $y] = $f->( $x, $y )
            }
        }

        return Matrix->new(
            shape => [ @$shape ],
            data  => \@new
        )
    }
}

class Matrix {
    use List::Util qw[ min max ];

    use overload (
        '+'  => 'add',
        '-'  => 'sub',
        '*'  => 'mul',
        '/'  => 'div',
        '%'  => 'mod',
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

    sub eye ($, $shape)  { Matrix::Builder->eye($shape)  }
    sub diagonal ($, $v) { Matrix::Builder->diagonal($v) }

    # --------------------------------------------------------------------------

    method shift_horz ($by) {
        my ($rows, $cols) = @$shape;

        $by = -$by;

        return Matrix::Builder->transform(
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
        return ( ($x * $shape->[0]) .. (($x * $shape->[0]) + ($shape->[1] - 1)) )
    }

    method is_compatible_with ($other) {
        return @$shape eq $other->shape->@*
    }

    # --------------------------------------------------------------------------

    method unary_op ($f) {
        return Matrix::Builder->transform(
            [ @$shape ],
            sub ($x, $y) { $f->( $self->at($x, $y) ) }
        )
    }

    method binary_op ($f, $other) {
        return Matrix::Builder->transform(
            [ @$shape ],
            sub ($x, $y) { $f->( $self->at($x, $y), $other->at($x, $y) ) }
        )
    }

    # --------------------------------------------------------------------------

    method neg { $self->unary_op(sub ($n) { -$n }) }

    method add ($other, @) { $self->binary_op(sub ($n, $m) { $n + $m }, $other) }
    method sub ($other, @) { $self->binary_op(sub ($n, $m) { $n - $m }, $other) }
    method mul ($other, @) { $self->binary_op(sub ($n, $m) { $n * $m }, $other) }
    method div ($other, @) { $self->binary_op(sub ($n, $m) { $n % $m }, $other) }
    method mod ($other, @) { $self->binary_op(sub ($n, $m) { $n / $m }, $other) }

    # --------------------------------------------------------------------------

    method to_string (@) {
        my ($rows, $cols) = @$shape;
        my @out;
        for (my $x = 0; $x < $rows; $x++) {
            push @out =>
                join ' ' =>
                    map { sprintf('%2d', $_) }
                        $data->@[ $self->row_indices( $x ) ];
        }
        return join "\n" => @out;
    }

}
