#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Exception;

use Time::HiRes qw[ time sleep ];
use Data::Dumper qw[ Dumper ];

use Matrix;
use Vector;

class Machine::Stepper {
    field $steps :param :reader;

    field $trans :reader;
    field $state :reader;

    ADJUST {
        $trans = Matrix->eye($steps + 1)->shift_horz(1);
    }

    method start {
        return Vector->new( size => $steps + 1, data => [ 1, (0) x $steps ])
    }

    method step ($state) {
        return $state->matrix_multiply($trans);
    }
}

class Machine::LoopingStepper {
    field $steps :param :reader;

    field $trans :reader;
    field $state :reader;

    ADJUST {
        $trans = Matrix->eye($steps + 1)
                    ->shift_horz(1)->copy_row(0, $steps);
    }

    method start {
        return Vector->new( size => $steps + 1, data => [ 1, (0) x $steps ])
    }

    method step ($state) {
        return $state->matrix_multiply($trans);
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
    my $stepper = Machine::LoopingStepper->new( steps => 10 );

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

