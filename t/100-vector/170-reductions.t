use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Exception;
use Data::Dumper;

use Vector;

subtest 'sum method - basic summation' => sub {
    my $v = Vector->new( size => 4, data => [1, 2, 3, 4] );
    my $sum = $v->sum;

    is( $sum, 10, 'sum of [1,2,3,4] is 10' );

    # Test with different values
    my $v2 = Vector->new( size => 5, data => [1, 2, 3, 4, 5] );
    my $sum2 = $v2->sum;
    is( $sum2, 15, 'sum of [1..5] is 15' );

    # Test with negative numbers
    my $v3 = Vector->new( size => 4, data => [-1, -2, -3, -4] );
    my $sum3 = $v3->sum;
    is( $sum3, -10, 'sum of negative numbers is correct' );

    # Test with mixed signs
    my $v4 = Vector->new( size => 4, data => [1, -2, 3, -4] );
    my $sum4 = $v4->sum;
    is( $sum4, -2, 'sum of mixed signs is correct' );
};

subtest 'sum method - with floating point numbers' => sub {
    my $v = Vector->new( size => 4, data => [1.5, 2.5, 3.5, 4.5] );
    my $sum = $v->sum;

    is( $sum, 12.0, 'sum of floating point numbers is correct' );

    # Test with more precision
    my $v2 = Vector->new( size => 4, data => [0.1, 0.2, 0.3, 0.4] );
    my $sum2 = $v2->sum;
    is( $sum2, 1.0, 'sum of small floating point numbers is correct' );
};

subtest 'sum method - edge cases' => sub {
    # Test with zero vector
    my $zeros = Vector->new( size => 4, data => [0, 0, 0, 0] );
    my $sum_zeros = $zeros->sum;
    is( $sum_zeros, 0, 'sum of zero vector is 0' );

    # Test with single element
    my $single = Vector->new( size => 1, data => [42] );
    my $sum_single = $single->sum;
    is( $sum_single, 42, 'sum of single element is the element itself' );

    # Test with larger vector
    my @data = (1..100);
    my $large = Vector->new( size => 100, data => \@data );
    my $sum_large = $large->sum;
    is( $sum_large, 5050, 'sum of 1..100 is 5050' );
};

subtest 'min_value method - finding minimum value' => sub {
    my $v = Vector->new( size => 4, data => [5, 2, 8, 1] );
    my $min = $v->min_value;

    is( $min, 1, 'min_value of [5,2,8,1] is 1' );

    # Test with different values
    my $v2 = Vector->new( size => 5, data => [9, 8, 7, 6, 5] );
    my $min2 = $v2->min_value;
    is( $min2, 5, 'min_value of [9..5] is 5' );

    # Test with negative numbers
    my $v3 = Vector->new( size => 4, data => [-1, -5, -3, -2] );
    my $min3 = $v3->min_value;
    is( $min3, -5, 'min_value of negative numbers is correct' );

    # Test with mixed signs
    my $v4 = Vector->new( size => 4, data => [1, -2, 3, -4] );
    my $min4 = $v4->min_value;
    is( $min4, -4, 'min_value of mixed signs is correct' );
};

subtest 'min_value method - with floating point numbers' => sub {
    my $v = Vector->new( size => 4, data => [1.5, 2.5, 0.5, 3.5] );
    my $min = $v->min_value;

    is( $min, 0.5, 'min_value of floating point numbers is correct' );

    # Test with negative floating point
    my $v2 = Vector->new( size => 4, data => [-1.5, -2.5, -0.5, -3.5] );
    my $min2 = $v2->min_value;
    is( $min2, -3.5, 'min_value of negative floating point numbers is correct' );
};

subtest 'min_value method - edge cases' => sub {
    # Test with all same values
    my $same = Vector->new( size => 4, data => [5, 5, 5, 5] );
    my $min_same = $same->min_value;
    is( $min_same, 5, 'min_value of all same values is that value' );

    # Test with single element
    my $single = Vector->new( size => 1, data => [42] );
    my $min_single = $single->min_value;
    is( $min_single, 42, 'min_value of single element is the element itself' );

    # Test with zero vector
    my $zeros = Vector->new( size => 4, data => [0, 0, 0, 0] );
    my $min_zeros = $zeros->min_value;
    is( $min_zeros, 0, 'min_value of zero vector is 0' );
};

subtest 'max_value method - finding maximum value' => sub {
    my $v = Vector->new( size => 4, data => [5, 2, 8, 1] );
    my $max = $v->max_value;

    is( $max, 8, 'max_value of [5,2,8,1] is 8' );

    # Test with different values
    my $v2 = Vector->new( size => 5, data => [1, 2, 3, 4, 5] );
    my $max2 = $v2->max_value;
    is( $max2, 5, 'max_value of [1..5] is 5' );

    # Test with negative numbers
    my $v3 = Vector->new( size => 4, data => [-1, -5, -3, -2] );
    my $max3 = $v3->max_value;
    is( $max3, -1, 'max_value of negative numbers is correct' );

    # Test with mixed signs
    my $v4 = Vector->new( size => 4, data => [1, -2, 3, -4] );
    my $max4 = $v4->max_value;
    is( $max4, 3, 'max_value of mixed signs is correct' );
};

subtest 'max_value method - with floating point numbers' => sub {
    my $v = Vector->new( size => 4, data => [1.5, 2.5, 0.5, 3.5] );
    my $max = $v->max_value;

    is( $max, 3.5, 'max_value of floating point numbers is correct' );

    # Test with negative floating point
    my $v2 = Vector->new( size => 4, data => [-1.5, -2.5, -0.5, -3.5] );
    my $max2 = $v2->max_value;
    is( $max2, -0.5, 'max_value of negative floating point numbers is correct' );
};

subtest 'max_value method - edge cases' => sub {
    # Test with all same values
    my $same = Vector->new( size => 4, data => [5, 5, 5, 5] );
    my $max_same = $same->max_value;
    is( $max_same, 5, 'max_value of all same values is that value' );

    # Test with single element
    my $single = Vector->new( size => 1, data => [42] );
    my $max_single = $single->max_value;
    is( $max_single, 42, 'max_value of single element is the element itself' );

    # Test with zero vector
    my $zeros = Vector->new( size => 4, data => [0, 0, 0, 0] );
    my $max_zeros = $zeros->max_value;
    is( $max_zeros, 0, 'max_value of zero vector is 0' );
};

subtest 'reduce method - custom reduction operations' => sub {
    my $v = Vector->new( size => 4, data => [1, 2, 3, 4] );

    # Test multiplication reduction
    my $product = $v->reduce(sub { $_[0] * $_[1] }, 1);
    is( $product, 24, 'reduce with multiplication gives 1*2*3*4 = 24' );

    # Test string concatenation
    my $concat = $v->reduce(sub { $_[0] . $_[1] }, '');
    is( $concat, '1234', 'reduce with concatenation gives "1234"' );

    # Test finding maximum with reduce
    my $max_reduce = $v->reduce(sub { $_[0] > $_[1] ? $_[0] : $_[1] }, 0);
    is( $max_reduce, 4, 'reduce to find maximum gives 4' );

    # Test finding minimum with reduce
    my $min_reduce = $v->reduce(sub { $_[0] < $_[1] ? $_[0] : $_[1] }, 999);
    is( $min_reduce, 1, 'reduce to find minimum gives 1' );
};

subtest 'reduce method - with different initial values' => sub {
    my $v = Vector->new( size => 4, data => [2, 3, 4, 5] );

    # Test addition with different initial values
    my $sum_0 = $v->reduce(sub { $_[0] + $_[1] }, 0);
    is( $sum_0, 14, 'reduce with initial 0 gives sum 14' );

    my $sum_10 = $v->reduce(sub { $_[0] + $_[1] }, 10);
    is( $sum_10, 24, 'reduce with initial 10 gives sum 24' );

    # Test multiplication with different initial values
    my $prod_1 = $v->reduce(sub { $_[0] * $_[1] }, 1);
    is( $prod_1, 120, 'reduce with initial 1 gives product 120' );

    my $prod_2 = $v->reduce(sub { $_[0] * $_[1] }, 2);
    is( $prod_2, 240, 'reduce with initial 2 gives product 240' );
};

subtest 'reduce method - edge cases' => sub {
    # Test with single element
    my $single = Vector->new( size => 1, data => [42] );
    my $result = $single->reduce(sub { $_[0] + $_[1] }, 0);
    is( $result, 42, 'reduce on single element works correctly' );

    # Test with zero vector
    my $zeros = Vector->new( size => 4, data => [0, 0, 0, 0] );
    my $sum_zeros = $zeros->reduce(sub { $_[0] + $_[1] }, 0);
    is( $sum_zeros, 0, 'reduce on zero vector works correctly' );

    # Test with floating point
    my $float = Vector->new( size => 4, data => [1.5, 2.5, 3.5, 4.5] );
    my $sum_float = $float->reduce(sub { $_[0] + $_[1] }, 0);
    is( $sum_float, 12.0, 'reduce with floating point works correctly' );
};

done_testing;

__END__
