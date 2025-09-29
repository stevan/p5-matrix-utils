
use v5.40;
use experimental qw[ class ];

use AbstractTensor;

use Time::HiRes qw[ time sleep ];

package Toys::Shader::Color {
    sub websafe ($pixel, $c) {
        sprintf "\e[48;5;%dm%s\e[0m" => AbstractTensor::clamp(0, 216, $c), $pixel
    }

    sub rgb ($pixel, @color) {
        sprintf "\e[48;2;%s;%s;%sm%s\e[0m" =>
            (map { AbstractTensor::clamp(0, 255, $_) } @color), $pixel
    }
}

package Toys::Shader::Palettes {
    use constant WebSafe => Matrix->new(shape => [ 6, 36 ], data  => [ 16 .. 231 ]);
}

class Toys::Shader {
    field $matrix  :param;
    field $palette :param;
    field $shader  :param = sub ($x, $y, $c) { $c };

    field $formatter;
    field $pixel;
    field $y_deform;

    method matrix :lvalue { $matrix }

    ADJUST {
        if (lc($palette) eq 'websafe') {
            $formatter = \&Toys::Shader::Color::websafe;
        } elsif (lc($palette) eq 'rgb') {
            $formatter = \&Toys::Shader::Color::rgb;
        } else {
            Carp::confess "Unknown palette (${palette})";
        }
        $pixel     = '  ';
        $y_deform  = length($pixel);
    }

    method run ($x_pos, $y_pos) {
        my ($rows, $cols) = ($matrix->rows, $matrix->cols);
        my $data = $matrix->data;
        for (my $x = 0; $x < $rows; $x++) {
            for (my $y = 0; $y < $cols; $y++) {
                printf "\e[%d;%dH%s" =>
                                  $x + $x_pos, # adjust the xy position
                    ($y * $y_deform) + $y_pos, # make it square pixels

                    # run the shader ...
                    $formatter->(
                        $pixel,
                        $shader->( $x, $y, $data->[$x * $cols + $y] ),
                    );
            }
        }
    }
}
