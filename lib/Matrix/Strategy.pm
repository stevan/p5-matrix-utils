
package Matrix::Strategy;

use v5.40;

sub eye ($, $size) {
    return Matrix->new(
        shape => [ $size, $size ],
        data  => [ map { (0) x ($_ - 1), 1, (0) x ($size - $_) } 1 .. $size ]
    )
}

sub diagonal ($, $vector) {
    my $size = $vector->size;

    my @new = (0) x ($size * $size);
    for (my $x = 0; $x < $size; $x++) {
        $new[$x * $size + $x] = $vector->at($x);
    }

    return Matrix->new(
        shape => [ $size, $size ],
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

__END__
