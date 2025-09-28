# Quick Test Template - Minimal Structure
# Use this for simple, focused tests

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Exception;
use Data::Dumper;

use Matrix;  # Add other modules as needed

# Basic test structure
subtest 'method_name - what you're testing' => sub {
    # Setup
    my $m = Matrix->new( shape => [2, 2], data => [1, 2, 3, 4] );

    # Test
    my $result = $m->method_name();

    # Verify
    isa_ok( $result, 'Matrix', 'returns correct type' );
    is( $result->rows, 2, 'correct rows' );
    is( $result->cols, 2, 'correct columns' );
    is( $result->at(0, 0), 1, 'element (0,0) correct' );
    # Add more assertions as needed
};

# Error testing
subtest 'method_name - error conditions' => sub {
    my $m = Matrix->new( shape => [2, 2], data => [1, 2, 3, 4] );

    throws_ok { $m->method_name('invalid') } qr/error pattern/, 'throws error for invalid input';
};

done_testing;

__END__

# Quick Reference:
# - Matrix->new(shape => [rows, cols], data => [array])
# - Vector->new(size => n, data => [array])
# - $matrix->at(row, col) for elements
# - $vector->at(index) for elements
# - isa_ok($obj, 'Class', 'description')
# - is($got, $expected, 'description')
# - ok($condition, 'description')
# - like($string, qr/pattern/, 'description')
# - throws_ok { code } qr/pattern/, 'description' for exceptions
# - lives_ok { code } 'description' for non-throwing code
# - Run with: perl -Ilib t/file.t
