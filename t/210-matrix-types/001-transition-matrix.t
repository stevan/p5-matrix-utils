use v5.40;
use experimental qw[ class ];

use Test::More;
use Data::Dumper;

use Matrix::TransitionMatrix;

subtest 'TransitionMatrix create method - basic initialization' => sub {
    my $tm = Matrix::TransitionMatrix->create(3);

    isa_ok( $tm, 'Matrix::TransitionMatrix', 'create returns a TransitionMatrix' );
    isa_ok( $tm, 'Matrix', 'TransitionMatrix isa Matrix' );
    is( $tm->rows, 4, 'matrix has correct number of rows (steps + 1)' );
    is( $tm->cols, 4, 'matrix has correct number of columns (steps + 1)' );
    is( $tm->size, 16, 'matrix has correct total size' );

    # Check that it's an identity matrix shifted horizontally by 1
    # Expected structure for 3 steps:
    # [0 1 0 0]
    # [0 0 1 0]
    # [0 0 0 1]
    # [0 0 0 0]
    is( $tm->at(0, 0), 0, 'element at (0,0) is 0' );
    is( $tm->at(0, 1), 1, 'element at (0,1) is 1' );
    is( $tm->at(0, 2), 0, 'element at (0,2) is 0' );
    is( $tm->at(0, 3), 0, 'element at (0,3) is 0' );

    is( $tm->at(1, 0), 0, 'element at (1,0) is 0' );
    is( $tm->at(1, 1), 0, 'element at (1,1) is 0' );
    is( $tm->at(1, 2), 1, 'element at (1,2) is 1' );
    is( $tm->at(1, 3), 0, 'element at (1,3) is 0' );

    is( $tm->at(2, 0), 0, 'element at (2,0) is 0' );
    is( $tm->at(2, 1), 0, 'element at (2,1) is 0' );
    is( $tm->at(2, 2), 0, 'element at (2,2) is 0' );
    is( $tm->at(2, 3), 1, 'element at (2,3) is 1' );

    is( $tm->at(3, 0), 0, 'element at (3,0) is 0' );
    is( $tm->at(3, 1), 0, 'element at (3,1) is 0' );
    is( $tm->at(3, 2), 0, 'element at (3,2) is 0' );
    is( $tm->at(3, 3), 0, 'element at (3,3) is 0' );
};

subtest 'TransitionMatrix create method - different step counts' => sub {
    # Test with 1 step
    my $tm1 = Matrix::TransitionMatrix->create(1);
    isa_ok( $tm1, 'Matrix::TransitionMatrix', 'create(1) returns a TransitionMatrix' );
    is( $tm1->rows, 2, '1 step matrix has 2 rows' );
    is( $tm1->cols, 2, '1 step matrix has 2 columns' );

    # Expected structure for 1 step:
    # [0 1]
    # [0 0]
    is( $tm1->at(0, 0), 0, 'element at (0,0) is 0' );
    is( $tm1->at(0, 1), 1, 'element at (0,1) is 1' );
    is( $tm1->at(1, 0), 0, 'element at (1,0) is 0' );
    is( $tm1->at(1, 1), 0, 'element at (1,1) is 0' );

    # Test with 5 steps
    my $tm5 = Matrix::TransitionMatrix->create(5);
    isa_ok( $tm5, 'Matrix::TransitionMatrix', 'create(5) returns a TransitionMatrix' );
    is( $tm5->rows, 6, '5 step matrix has 6 rows' );
    is( $tm5->cols, 6, '5 step matrix has 6 columns' );

    # Check diagonal pattern is shifted by 1
    for my $i (0..4) {
        is( $tm5->at($i, $i), 0, "diagonal element at ($i,$i) is 0" );
        is( $tm5->at($i, $i+1), 1, "shifted diagonal element at ($i,".($i+1).") is 1" );
    }
    is( $tm5->at(5, 5), 0, 'last diagonal element is 0' );
};

subtest 'TransitionMatrix steps method' => sub {
    my $tm3 = Matrix::TransitionMatrix->create(3);
    is( $tm3->steps, 3, 'steps method returns correct number of steps' );

    my $tm7 = Matrix::TransitionMatrix->create(7);
    is( $tm7->steps, 7, 'steps method returns correct number of steps for larger matrix' );

    my $tm1 = Matrix::TransitionMatrix->create(1);
    is( $tm1->steps, 1, 'steps method returns correct number of steps for small matrix' );
};

subtest 'TransitionMatrix intitial_state_vector method' => sub {
    my $tm = Matrix::TransitionMatrix->create(3);
    my $state = $tm->intitial_state_vector;

    isa_ok( $state, 'Matrix::TransitionMatrix::StateVector', 'intitial_state_vector returns a StateVector' );
    isa_ok( $state, 'Vector', 'StateVector isa Vector' );
    is( $state->size, 4, 'state vector has correct size (steps + 1)' );

    # Check initial state is [1, 0, 0, 0] (state 0 is active)
    is( $state->at(0), 1, 'initial state at position 0 is 1' );
    is( $state->at(1), 0, 'initial state at position 1 is 0' );
    is( $state->at(2), 0, 'initial state at position 2 is 0' );
    is( $state->at(3), 0, 'initial state at position 3 is 0' );
};

subtest 'StateVector create method - basic initialization' => sub {
    my $state = Matrix::TransitionMatrix::StateVector->create(4, 0);

    isa_ok( $state, 'Matrix::TransitionMatrix::StateVector', 'StateVector create returns a StateVector' );
    isa_ok( $state, 'Vector', 'StateVector isa Vector' );
    is( $state->size, 4, 'state vector has correct size' );

    # Check initial state is [1, 0, 0, 0] (state 0 is active)
    is( $state->at(0), 1, 'state at position 0 is 1' );
    is( $state->at(1), 0, 'state at position 1 is 0' );
    is( $state->at(2), 0, 'state at position 2 is 0' );
    is( $state->at(3), 0, 'state at position 3 is 0' );
};

subtest 'StateVector create method - different initial states' => sub {
    # Test with initial state 1
    my $state1 = Matrix::TransitionMatrix::StateVector->create(4, 1);

    isa_ok( $state1, 'Matrix::TransitionMatrix::StateVector', 'StateVector create returns a StateVector' );
    is( $state1->size, 4, 'state vector has correct size' );

    # Check initial state is [0, 1, 0, 0] (state 1 is active)
    is( $state1->at(0), 0, 'state at position 0 is 0' );
    is( $state1->at(1), 1, 'state at position 1 is 1' );
    is( $state1->at(2), 0, 'state at position 2 is 0' );
    is( $state1->at(3), 0, 'state at position 3 is 0' );

    # Test with initial state 2
    my $state2 = Matrix::TransitionMatrix::StateVector->create(4, 2);

    # Check initial state is [0, 0, 1, 0] (state 2 is active)
    is( $state2->at(0), 0, 'state at position 0 is 0' );
    is( $state2->at(1), 0, 'state at position 1 is 0' );
    is( $state2->at(2), 1, 'state at position 2 is 1' );
    is( $state2->at(3), 0, 'state at position 3 is 0' );

    # Test with initial state 3 (last state)
    my $state3 = Matrix::TransitionMatrix::StateVector->create(4, 3);

    # Check initial state is [0, 0, 0, 1] (state 3 is active)
    is( $state3->at(0), 0, 'state at position 0 is 0' );
    is( $state3->at(1), 0, 'state at position 1 is 0' );
    is( $state3->at(2), 0, 'state at position 2 is 0' );
    is( $state3->at(3), 1, 'state at position 3 is 1' );
};

subtest 'StateVector create method - different sizes' => sub {
    # Test with 2 states
    my $state2 = Matrix::TransitionMatrix::StateVector->create(2, 0);
    is( $state2->size, 2, '2-state vector has correct size' );
    is( $state2->at(0), 1, 'state at position 0 is 1' );
    is( $state2->at(1), 0, 'state at position 1 is 0' );

    # Test with 6 states
    my $state6 = Matrix::TransitionMatrix::StateVector->create(6, 3);
    is( $state6->size, 6, '6-state vector has correct size' );
    is( $state6->at(3), 1, 'state at position 3 is 1' );
    for my $i (0..5) {
        next if $i == 3;
        is( $state6->at($i), 0, "state at position $i is 0" );
    }
};

subtest 'TransitionMatrix transition method - basic transitions' => sub {
    my $tm = Matrix::TransitionMatrix->create(3);
    my $initial_state = $tm->intitial_state_vector;

    # Test transition from initial state [1, 0, 0, 0]
    my $next_state = $tm->transition($initial_state);

    isa_ok( $next_state, 'Vector', 'transition returns a Vector' );
    is( $next_state->size, 4, 'transition result has correct size' );

    # After transition, should be [0, 1, 0, 0] (moved to next state)
    is( $next_state->at(0), 0, 'state at position 0 is 0' );
    is( $next_state->at(1), 1, 'state at position 1 is 1' );
    is( $next_state->at(2), 0, 'state at position 2 is 0' );
    is( $next_state->at(3), 0, 'state at position 3 is 0' );
};

subtest 'TransitionMatrix transition method - multiple transitions' => sub {
    my $tm = Matrix::TransitionMatrix->create(3);
    my $state = $tm->intitial_state_vector;

    # First transition: [1, 0, 0, 0] -> [0, 1, 0, 0]
    $state = $tm->transition($state);
    is( $state->at(0), 0, 'after 1st transition: state at position 0 is 0' );
    is( $state->at(1), 1, 'after 1st transition: state at position 1 is 1' );
    is( $state->at(2), 0, 'after 1st transition: state at position 2 is 0' );
    is( $state->at(3), 0, 'after 1st transition: state at position 3 is 0' );

    # Second transition: [0, 1, 0, 0] -> [0, 0, 1, 0]
    $state = $tm->transition($state);
    is( $state->at(0), 0, 'after 2nd transition: state at position 0 is 0' );
    is( $state->at(1), 0, 'after 2nd transition: state at position 1 is 0' );
    is( $state->at(2), 1, 'after 2nd transition: state at position 2 is 1' );
    is( $state->at(3), 0, 'after 2nd transition: state at position 3 is 0' );

    # Third transition: [0, 0, 1, 0] -> [0, 0, 0, 1]
    $state = $tm->transition($state);
    is( $state->at(0), 0, 'after 3rd transition: state at position 0 is 0' );
    is( $state->at(1), 0, 'after 3rd transition: state at position 1 is 0' );
    is( $state->at(2), 0, 'after 3rd transition: state at position 2 is 0' );
    is( $state->at(3), 1, 'after 3rd transition: state at position 3 is 1' );

    # Fourth transition: [0, 0, 0, 1] -> [0, 0, 0, 0] (absorbing state)
    $state = $tm->transition($state);
    is( $state->at(0), 0, 'after 4th transition: state at position 0 is 0' );
    is( $state->at(1), 0, 'after 4th transition: state at position 1 is 0' );
    is( $state->at(2), 0, 'after 4th transition: state at position 2 is 0' );
    is( $state->at(3), 0, 'after 4th transition: state at position 3 is 0' );
};

subtest 'TransitionMatrix transition method - with different initial states' => sub {
    my $tm = Matrix::TransitionMatrix->create(3);

    # Test starting from state 1
    my $state1 = Matrix::TransitionMatrix::StateVector->create(4, 1);
    my $next_state1 = $tm->transition($state1);

    # Should transition from [0, 1, 0, 0] to [0, 0, 1, 0]
    is( $next_state1->at(0), 0, 'from state 1: state at position 0 is 0' );
    is( $next_state1->at(1), 0, 'from state 1: state at position 1 is 0' );
    is( $next_state1->at(2), 1, 'from state 1: state at position 2 is 1' );
    is( $next_state1->at(3), 0, 'from state 1: state at position 3 is 0' );

    # Test starting from state 2
    my $state2 = Matrix::TransitionMatrix::StateVector->create(4, 2);
    my $next_state2 = $tm->transition($state2);

    # Should transition from [0, 0, 1, 0] to [0, 0, 0, 1]
    is( $next_state2->at(0), 0, 'from state 2: state at position 0 is 0' );
    is( $next_state2->at(1), 0, 'from state 2: state at position 1 is 0' );
    is( $next_state2->at(2), 0, 'from state 2: state at position 2 is 0' );
    is( $next_state2->at(3), 1, 'from state 2: state at position 3 is 1' );
};

subtest 'TransitionMatrix transition method - edge cases' => sub {
    my $tm = Matrix::TransitionMatrix->create(1);

    # Test with single step transition matrix
    my $state = Matrix::TransitionMatrix::StateVector->create(2, 0);
    my $next_state = $tm->transition($state);

    # Should transition from [1, 0] to [0, 1]
    is( $next_state->at(0), 0, 'single step: state at position 0 is 0' );
    is( $next_state->at(1), 1, 'single step: state at position 1 is 1' );

    # Next transition should go to [0, 0] (absorbing)
    $next_state = $tm->transition($next_state);
    is( $next_state->at(0), 0, 'single step absorbing: state at position 0 is 0' );
    is( $next_state->at(1), 0, 'single step absorbing: state at position 1 is 0' );
};

subtest 'TransitionMatrix integration test - complete state machine' => sub {
    my $tm = Matrix::TransitionMatrix->create(4);
    my $state = $tm->intitial_state_vector;

    # Verify we start in state 0
    is( $state->at(0), 1, 'initial: state 0 is active' );

    # Step through all states
    for my $step (1..4) {
        $state = $tm->transition($state);
        is( $state->at($step), 1, "step $step: state $step is active" );

        # All other states should be 0
        for my $i (0..4) {
            next if $i == $step;
            is( $state->at($i), 0, "step $step: state $i is inactive" );
        }
    }

    # Final transition should go to absorbing state
    $state = $tm->transition($state);
    for my $i (0..4) {
        is( $state->at($i), 0, "absorbing: state $i is inactive" );
    }
};

done_testing;

__END__
