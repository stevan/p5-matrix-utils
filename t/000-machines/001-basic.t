#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Exception;

use Time::HiRes qw[ time sleep ];
use Data::Dumper qw[ Dumper ];

use Matrix;
use Vector;

use Matrix::TransitionMatrix;

class Machine::Stepper {
    field $steps   :param :reader;
    field $looping :param :reader = false;

    field $trans :reader;

    ADJUST {
        $trans = Matrix::TransitionMatrix->create($steps);
        $trans = $trans->copy_row(0, $steps) if $looping;
    }

    method start { $trans->intitial_state_vector }

    method step ($state) {
        return $trans->transition($state);
    }
}

subtest '... testing 10 step stepper' => sub {
    my $stepper = Machine::Stepper->new( steps => 10 );

    my $state = $stepper->start;

    is($state->to_string, q[<1 0 0 0 0 0 0 0 0 0 0>], '... got the expected state (<1 0 0 0 0 0 0 0 0 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 1 0 0 0 0 0 0 0 0 0>], '... got the expected state (<0 1 0 0 0 0 0 0 0 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 1 0 0 0 0 0 0 0 0>], '... got the expected state (<0 0 1 0 0 0 0 0 0 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 0 1 0 0 0 0 0 0 0>], '... got the expected state (<0 0 0 1 0 0 0 0 0 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 0 0 1 0 0 0 0 0 0>], '... got the expected state (<0 0 0 0 1 0 0 0 0 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 0 0 0 1 0 0 0 0 0>], '... got the expected state (<0 0 0 0 0 1 0 0 0 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 0 0 0 0 1 0 0 0 0>], '... got the expected state (<0 0 0 0 0 0 1 0 0 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 0 0 0 0 0 1 0 0 0>], '... got the expected state (<0 0 0 0 0 0 0 1 0 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 0 0 0 0 0 0 1 0 0>], '... got the expected state (<0 0 0 0 0 0 0 0 1 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 0 0 0 0 0 0 0 1 0>], '... got the expected state (<0 0 0 0 0 0 0 0 0 1 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 0 0 0 0 0 0 0 0 1>], '... got the expected state (<0 0 0 0 0 0 0 0 0 0 1>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 0 0 0 0 0 0 0 0 0>], '... got the expected state (<0 0 0 0 0 0 0 0 0 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 0 0 0 0 0 0 0 0 0>], '... got the expected state (<0 0 0 0 0 0 0 0 0 0 0>)');
};


subtest '... testing 10 step loop-stepper' => sub {
    my $stepper = Machine::Stepper->new( steps => 10, looping => true );

    my $state = $stepper->start;

    is($state->to_string, q[<1 0 0 0 0 0 0 0 0 0 0>], '... got the expected state (<1 0 0 0 0 0 0 0 0 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 1 0 0 0 0 0 0 0 0 0>], '... got the expected state (<0 1 0 0 0 0 0 0 0 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 1 0 0 0 0 0 0 0 0>], '... got the expected state (<0 0 1 0 0 0 0 0 0 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 0 1 0 0 0 0 0 0 0>], '... got the expected state (<0 0 0 1 0 0 0 0 0 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 0 0 1 0 0 0 0 0 0>], '... got the expected state (<0 0 0 0 1 0 0 0 0 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 0 0 0 1 0 0 0 0 0>], '... got the expected state (<0 0 0 0 0 1 0 0 0 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 0 0 0 0 1 0 0 0 0>], '... got the expected state (<0 0 0 0 0 0 1 0 0 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 0 0 0 0 0 1 0 0 0>], '... got the expected state (<0 0 0 0 0 0 0 1 0 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 0 0 0 0 0 0 1 0 0>], '... got the expected state (<0 0 0 0 0 0 0 0 1 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 0 0 0 0 0 0 0 1 0>], '... got the expected state (<0 0 0 0 0 0 0 0 0 1 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 0 0 0 0 0 0 0 0 1>], '... got the expected state (<0 0 0 0 0 0 0 0 0 0 1>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 1 0 0 0 0 0 0 0 0 0>], '... got the expected state (<0 1 0 0 0 0 0 0 0 0 0>)');

    lives_ok { $state = $stepper->step($state); } '... stepper->stepped successfully';
    is($state->to_string, q[<0 0 1 0 0 0 0 0 0 0 0>], '... got the expected state (<0 0 1 0 0 0 0 0 0 0 0>)');
};

done_testing;

__END__

class Machine::Rotate {
    use constant SHAPE => [ 2, 2 ];
    use constant STEPS => [
        map { Matrix->new( shape => SHAPE, data => $_ ) }
        [
            1, 0,
            0, 0,
                    ],
        [
            0, 1,
            0, 0,
                    ],
        [
            0, 0,
            1, 0,
                    ],
        [
            0, 0,
            0, 1,
                    ]
    ];

    field $state :reader;
    field $cycle :reader;

    ADJUST {
        $state = Matrix->initialize( SHAPE, 0 );
        $cycle = Machine::IndexCycle->new;
    }

    method step  {
        $state += STEPS->[ $cycle->step->index ];
        $self;
    }
}

