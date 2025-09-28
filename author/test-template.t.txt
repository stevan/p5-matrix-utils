# Perl Matrix Utils - Unit Test Template
#
# This template provides a comprehensive structure for creating unit tests
# for the Matrix and Vector classes. Use this as a reference when creating
# new test files.
#
# Usage:
# 1. Copy this template to your test directory (e.g., t/200-matrix/)
# 2. Rename it to match your test purpose (e.g., 270-new-method.t)
# 3. Replace the placeholder content with your actual tests
# 4. Follow the established patterns and naming conventions

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Exception;
use Data::Dumper;

# Import the modules you're testing
use Matrix;
use Vector;  # Add other modules as needed

# Optional: Create a sample object for reference (not always needed)
my $sample_matrix = Matrix->new( shape => [2, 2], data => [1, 2, 3, 4] );

# ============================================================================
# BASIC METHOD TESTS
# ============================================================================

subtest 'method_name - basic functionality' => sub {
    # Create test objects
    my $m = Matrix->new( shape => [2, 2], data => [1, 2, 3, 4] );

    # Test the method
    my $result = $m->method_name();

    # Verify return type
    isa_ok( $result, 'Matrix', 'method_name returns a Matrix' );

    # Verify dimensions
    is( $result->rows, 2, 'result matrix has 2 rows' );
    is( $result->cols, 2, 'result matrix has 2 columns' );

    # Verify specific elements
    is( $result->at(0, 0), 1, 'element at (0,0) is correct' );
    is( $result->at(0, 1), 2, 'element at (0,1) is correct' );
    is( $result->at(1, 0), 3, 'element at (1,0) is correct' );
    is( $result->at(1, 1), 4, 'element at (1,1) is correct' );
};

# ============================================================================
# DIFFERENT MATRIX SIZES
# ============================================================================

subtest 'method_name - with different matrix sizes' => sub {
    # Test with various matrix dimensions
    my $m1 = Matrix->new( shape => [3, 3], data => [1, 2, 3, 4, 5, 6, 7, 8, 9] );
    my $m2 = Matrix->new( shape => [2, 4], data => [1, 2, 3, 4, 5, 6, 7, 8] );
    my $m3 = Matrix->new( shape => [4, 2], data => [1, 2, 3, 4, 5, 6, 7, 8] );

    # Test each size
    my $result1 = $m1->method_name();
    isa_ok( $result1, 'Matrix', 'method_name returns a Matrix for 3x3' );
    is( $result1->rows, 3, '3x3 result has 3 rows' );
    is( $result1->cols, 3, '3x3 result has 3 columns' );

    my $result2 = $m2->method_name();
    isa_ok( $result2, 'Matrix', 'method_name returns a Matrix for 2x4' );
    is( $result2->rows, 2, '2x4 result has 2 rows' );
    is( $result2->cols, 4, '2x4 result has 4 columns' );

    # Add more specific element tests as needed
};

# ============================================================================
# FLOATING POINT NUMBERS
# ============================================================================

subtest 'method_name - with floating point numbers' => sub {
    my $m = Matrix->new( shape => [2, 2], data => [1.5, 2.5, 3.5, 4.5] );

    my $result = $m->method_name();

    isa_ok( $result, 'Matrix', 'method_name returns a Matrix' );
    is( $result->at(0, 0), 1.5, 'element at (0,0) is 1.5' );
    is( $result->at(0, 1), 2.5, 'element at (0,1) is 2.5' );
    is( $result->at(1, 0), 3.5, 'element at (1,0) is 3.5' );
    is( $result->at(1, 1), 4.5, 'element at (1,1) is 4.5' );
};

# ============================================================================
# NEGATIVE NUMBERS
# ============================================================================

subtest 'method_name - with negative numbers' => sub {
    my $m = Matrix->new( shape => [2, 2], data => [-1, -2, -3, -4] );

    my $result = $m->method_name();

    isa_ok( $result, 'Matrix', 'method_name returns a Matrix' );
    is( $result->at(0, 0), -1, 'element at (0,0) is -1' );
    is( $result->at(0, 1), -2, 'element at (0,1) is -2' );
    is( $result->at(1, 0), -3, 'element at (1,0) is -3' );
    is( $result->at(1, 1), -4, 'element at (1,1) is -4' );
};

# ============================================================================
# ERROR CONDITIONS
# ============================================================================

subtest 'method_name - error conditions' => sub {
    my $m = Matrix->new( shape => [2, 2], data => [1, 2, 3, 4] );

    # Test invalid input
    throws_ok { $m->method_name('invalid_arg') } qr/error message pattern/, 'method_name with invalid argument should cause error';

    # Test boundary conditions
    throws_ok { $m->method_name(-1) } qr//, 'method_name with negative value should cause error';

    # Test specific error types
    throws_ok { $m->method_name() } 'Exception', 'method_name without arguments should throw Exception';

    # Add more error condition tests as needed
};

# ============================================================================
# EDGE CASES
# ============================================================================

subtest 'method_name - edge cases' => sub {
    # Test with single element matrix
    my $single = Matrix->new( shape => [1, 1], data => [42] );
    my $result_single = $single->method_name();

    isa_ok( $result_single, 'Matrix', 'method_name returns a Matrix' );
    is( $result_single->rows, 1, 'single element result has 1 row' );
    is( $result_single->cols, 1, 'single element result has 1 column' );
    is( $result_single->at(0, 0), 42, 'single element is correct' );

    # Test with zero matrix
    my $zeros = Matrix->new( shape => [2, 2], data => [0, 0, 0, 0] );
    my $result_zeros = $zeros->method_name();

    isa_ok( $result_zeros, 'Matrix', 'method_name returns a Matrix' );

    for my $i (0..1) {
        for my $j (0..1) {
            is( $result_zeros->at($i, $j), 0, "element at ($i,$j) is 0" );
        }
    }

    # Test with identity matrix
    my $eye = Matrix->eye(2);
    my $result_eye = $eye->method_name();

    isa_ok( $result_eye, 'Matrix', 'method_name returns a Matrix' );
    # Add specific tests for identity matrix behavior
};

# ============================================================================
# STATIC METHOD TESTS (if applicable)
# ============================================================================

subtest 'Class::method_name - static method functionality' => sub {
    # Test static/class methods
    my $result = Matrix->method_name([2, 2], sub { $_[0] + $_[1] });

    isa_ok( $result, 'Matrix', 'static method returns a Matrix' );
    is( $result->rows, 2, 'result has correct rows' );
    is( $result->cols, 2, 'result has correct columns' );

    # Test specific elements
    is( $result->at(0, 0), 0, 'element at (0,0) is 0' );
    is( $result->at(0, 1), 1, 'element at (0,1) is 1' );
    is( $result->at(1, 0), 1, 'element at (1,0) is 1' );
    is( $result->at(1, 1), 2, 'element at (1,1) is 2' );
};

# ============================================================================
# VECTOR INTERACTION TESTS (if applicable)
# ============================================================================

subtest 'method_name - with vector interaction' => sub {
    my $m = Matrix->new( shape => [2, 3], data => [1, 2, 3, 4, 5, 6] );
    my $v = Vector->new( size => 3, data => [2, 3, 4] );

    my $result = $m->method_name($v);

    isa_ok( $result, 'Vector', 'method_name with vector returns a Vector' );
    is( $result->size, 2, 'result vector has size 2' );

    # Test vector elements
    is( $result->at(0), 20, 'first element is 20' );
    is( $result->at(1), 47, 'second element is 47' );
};

# ============================================================================
# MATRIX OPERATION TESTS (if applicable)
# ============================================================================

subtest 'method_name - matrix operations' => sub {
    my $m1 = Matrix->new( shape => [2, 2], data => [1, 2, 3, 4] );
    my $m2 = Matrix->new( shape => [2, 2], data => [5, 6, 7, 8] );

    my $result = $m1->method_name($m2);

    isa_ok( $result, 'Matrix', 'method_name returns a Matrix' );
    is( $result->rows, 2, 'result has 2 rows' );
    is( $result->cols, 2, 'result has 2 columns' );

    # Test operation results
    is( $result->at(0, 0), 6, 'element at (0,0) is 6' );
    is( $result->at(0, 1), 8, 'element at (0,1) is 8' );
    is( $result->at(1, 0), 10, 'element at (1,0) is 10' );
    is( $result->at(1, 1), 12, 'element at (1,1) is 12' );
};

# ============================================================================
# COMPREHENSIVE LOOP TESTS (for large matrices)
# ============================================================================

subtest 'method_name - comprehensive element testing' => sub {
    my $m = Matrix->new( shape => [3, 3], data => [1, 2, 3, 4, 5, 6, 7, 8, 9] );

    my $result = $m->method_name();

    isa_ok( $result, 'Matrix', 'method_name returns a Matrix' );

    # Test all elements in a loop
    for my $i (0..2) {
        for my $j (0..2) {
            my $expected = $i * 3 + $j + 1;  # Adjust based on your method
            is( $result->at($i, $j), $expected, "element at ($i,$j) is $expected" );
        }
    }
};

# ============================================================================
# PERFORMANCE/STRESS TESTS (if applicable)
# ============================================================================

subtest 'method_name - with larger matrices' => sub {
    # Create a larger matrix for stress testing
    my @data = (1..100);  # 10x10 matrix
    my $large_m = Matrix->new( shape => [10, 10], data => \@data );

    my $result = $large_m->method_name();

    isa_ok( $result, 'Matrix', 'method_name returns a Matrix' );
    is( $result->rows, 10, 'large matrix result has 10 rows' );
    is( $result->cols, 10, 'large matrix result has 10 columns' );

    # Test a few key elements
    is( $result->at(0, 0), 1, 'first element is correct' );
    is( $result->at(9, 9), 100, 'last element is correct' );
};

# ============================================================================
# ALWAYS END WITH done_testing
# ============================================================================

done_testing;

__END__

# ============================================================================
# TESTING GUIDELINES AND BEST PRACTICES
# ============================================================================

# 1. FILE NAMING CONVENTIONS:
#    - Use descriptive names: 210-access.t, 220-constructors.t, etc.
#    - Group related tests: 200-matrix/, 100-vector/, etc.
#    - Use consistent numbering within directories

# 2. TEST STRUCTURE:
#    - Always start with proper Perl version and experimental features
#    - Import Test::More and Data::Dumper
#    - Import the modules you're testing
#    - Use subtests to organize related tests
#    - Always end with done_testing

# 3. SUBTEST NAMING:
#    - Use descriptive names: 'method_name - basic functionality'
#    - Include the method name and what aspect you're testing
#    - Be consistent with existing test patterns

# 4. TEST COVERAGE:
#    - Basic functionality with simple cases
#    - Different matrix/vector sizes
#    - Floating point numbers
#    - Negative numbers
#    - Error conditions and edge cases
#    - Single element matrices
#    - Zero matrices
#    - Identity matrices (if applicable)

# 5. ASSERTION PATTERNS:
#    - Use isa_ok() to verify return types
#    - Use is() for exact value comparisons
#    - Use ok() for boolean conditions
#    - Use like() for pattern matching in error messages
#    - Use throws_ok() to test that code throws exceptions
#    - Use lives_ok() to test that code doesn't throw exceptions
#    - Use dies_ok() to test that code dies (alternative to throws_ok)

# 6. ERROR TESTING:
#    - Use throws_ok { code } qr/pattern/, 'description' for exception testing
#    - Use throws_ok { code } 'Exception::Class', 'description' for specific exception types
#    - Use lives_ok { code } 'description' to test that code doesn't die
#    - Use dies_ok { code } 'description' as alternative to throws_ok
#    - Test boundary conditions and invalid inputs

# 7. MATRIX/VECTOR CREATION:
#    - Use Matrix->new(shape => [rows, cols], data => [array])
#    - Use Vector->new(size => n, data => [array])
#    - Use Matrix->eye(n) for identity matrices
#    - Use Matrix->initialize([rows, cols], value) for constant matrices

# 8. ELEMENT ACCESS:
#    - Use $matrix->at(row, col) for matrix elements
#    - Use $vector->at(index) for vector elements
#    - Remember that indices are 0-based

# 9. DIMENSION VERIFICATION:
#    - Always check $result->rows and $result->cols
#    - For vectors, check $result->size
#    - Verify dimensions match expectations

# 10. LOOP TESTING:
#     - Use nested loops for comprehensive element testing
#     - Be careful with loop bounds (0..rows-1, 0..cols-1)
#     - Use descriptive test messages in loops

# 11. COMMENTS:
#     - Add comments explaining complex test logic
#     - Document expected mathematical results
#     - Explain any non-obvious test setup

# 12. RUNNING TESTS:
#     - Use: perl -Ilib t/directory/test-file.t
#     - Use: prove -Ilib t/directory/test-file.t
#     - Always include -Ilib to find the modules

# 13. DEBUGGING:
#     - Use Data::Dumper to inspect objects when debugging
#     - Add diag() statements for debugging output
#     - Use explain() to show complex data structures
#     - Use Test::Exception functions for cleaner exception testing

# 14. CONSISTENCY:
#     - Follow the same patterns as existing tests
#     - Use consistent variable names ($m, $v, $result, etc.)
#     - Use consistent test descriptions and formatting
