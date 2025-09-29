
use v5.40;
use experimental qw[ class ];

use Carp;

use Matrix;
use Vector;

class Matrix::TransitionMatrix :isa(Matrix) {

    sub create ($class, $steps, $loop = undef) {
        return $class->eye($steps + 1)->shift_horz(1);
    }

    method steps { $self->width }

    method intitial_state_vector {
        Matrix::TransitionMatrix::StateVector->create( $self->cols, 0 )
    }

    method transition ($state) {
        return $state->matrix_multiply($self);
    }
}

class Matrix::TransitionMatrix::StateVector :isa(Vector) {
    sub create ($class, $steps, $initial_state = 0) {
        my @new  = (0) x $steps;
        $new[$initial_state] = 1;
        return $class->initialize( $steps, \@new )
    }
}
