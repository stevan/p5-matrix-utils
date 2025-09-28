use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Exception;
use Data::Dumper;

use Vector;

subtest 'to_string method - basic string representation' => sub {
    my $v = Vector->new( size => 4, data => [1, 2, 3, 4] );
    my $str = $v->to_string;

    like( $str, qr/1/, 'string contains 1' );
    like( $str, qr/2/, 'string contains 2' );
    like( $str, qr/3/, 'string contains 3' );
    like( $str, qr/4/, 'string contains 4' );

    # Test specific format (should be <1 2 3 4>)
    like( $str, qr/^<.*>$/, 'string is enclosed in angle brackets' );
    like( $str, qr/<1 2 3 4>/, 'string format is <1 2 3 4>' );
};

subtest 'to_string method - with different vector sizes' => sub {
    # Test with single element
    my $v1 = Vector->new( size => 1, data => [42] );
    my $str1 = $v1->to_string;
    like( $str1, qr/<42>/, 'single element vector format is <42>' );

    # Test with two elements
    my $v2 = Vector->new( size => 2, data => [10, 20] );
    my $str2 = $v2->to_string;
    like( $str2, qr/<10 20>/, 'two element vector format is <10 20>' );

    # Test with larger vector
    my $v3 = Vector->new( size => 5, data => [1, 2, 3, 4, 5] );
    my $str3 = $v3->to_string;
    like( $str3, qr/<1 2 3 4 5>/, 'five element vector format is <1 2 3 4 5>' );

    # Test with zero vector
    my $v4 = Vector->new( size => 3, data => [0, 0, 0] );
    my $str4 = $v4->to_string;
    like( $str4, qr/<0 0 0>/, 'zero vector format is <0 0 0>' );
};

subtest 'to_string method - with floating point numbers' => sub {
    my $v = Vector->new( size => 4, data => [1.5, 2.5, 3.5, 4.5] );
    my $str = $v->to_string;

    like( $str, qr/1\.5/, 'string contains 1.5' );
    like( $str, qr/2\.5/, 'string contains 2.5' );
    like( $str, qr/3\.5/, 'string contains 3.5' );
    like( $str, qr/4\.5/, 'string contains 4.5' );
    like( $str, qr/<1\.5 2\.5 3\.5 4\.5>/, 'floating point vector format is correct' );
};

subtest 'to_string method - with negative numbers' => sub {
    my $v = Vector->new( size => 4, data => [-1, -2, -3, -4] );
    my $str = $v->to_string;

    like( $str, qr/-1/, 'string contains -1' );
    like( $str, qr/-2/, 'string contains -2' );
    like( $str, qr/-3/, 'string contains -3' );
    like( $str, qr/-4/, 'string contains -4' );
    like( $str, qr/<-1 -2 -3 -4>/, 'negative number vector format is correct' );
};

subtest 'to_string method - with mixed signs' => sub {
    my $v = Vector->new( size => 4, data => [1, -2, 3, -4] );
    my $str = $v->to_string;

    like( $str, qr/1/, 'string contains 1' );
    like( $str, qr/-2/, 'string contains -2' );
    like( $str, qr/3/, 'string contains 3' );
    like( $str, qr/-4/, 'string contains -4' );
    like( $str, qr/<1 -2 3 -4>/, 'mixed sign vector format is correct' );
};

subtest 'to_string method - edge cases' => sub {
    # Test with empty vector (if supported)
    # Note: This might not be supported, but let's test the behavior
    # my $empty = Vector->new( size => 0, data => [] );
    # my $str_empty = $empty->to_string;
    # like( $str_empty, qr/<>/, 'empty vector format is <>' );

    # Test with single zero
    my $zero = Vector->new( size => 1, data => [0] );
    my $str_zero = $zero->to_string;
    like( $str_zero, qr/<0>/, 'single zero vector format is <0>' );

    # Test with large numbers
    my $large = Vector->new( size => 3, data => [1000, 2000, 3000] );
    my $str_large = $large->to_string;
    like( $str_large, qr/<1000 2000 3000>/, 'large number vector format is correct' );
};

subtest 'to_list method - basic list conversion' => sub {
    my $v = Vector->new( size => 4, data => [1, 2, 3, 4] );
    my @list = $v->to_list;

    is( scalar @list, 4, 'to_list returns correct number of elements' );
    is( $list[0], 1, 'first element is 1' );
    is( $list[1], 2, 'second element is 2' );
    is( $list[2], 3, 'third element is 3' );
    is( $list[3], 4, 'fourth element is 4' );

    # Test that it's a proper list (not array reference)
    isa_ok( \@list, 'ARRAY', 'to_list returns a proper array' );
};

subtest 'to_list method - with different vector sizes' => sub {
    # Test with single element
    my $v1 = Vector->new( size => 1, data => [42] );
    my @list1 = $v1->to_list;
    is( scalar @list1, 1, 'single element vector returns 1 element' );
    is( $list1[0], 42, 'single element is correct' );

    # Test with two elements
    my $v2 = Vector->new( size => 2, data => [10, 20] );
    my @list2 = $v2->to_list;
    is( scalar @list2, 2, 'two element vector returns 2 elements' );
    is( $list2[0], 10, 'first element is correct' );
    is( $list2[1], 20, 'second element is correct' );

    # Test with larger vector
    my $v3 = Vector->new( size => 5, data => [1, 2, 3, 4, 5] );
    my @list3 = $v3->to_list;
    is( scalar @list3, 5, 'five element vector returns 5 elements' );
    for my $i (0..4) {
        is( $list3[$i], $i + 1, "element at $i is " . ($i + 1) );
    }
};

subtest 'to_list method - with floating point numbers' => sub {
    my $v = Vector->new( size => 4, data => [1.5, 2.5, 3.5, 4.5] );
    my @list = $v->to_list;

    is( scalar @list, 4, 'floating point vector returns 4 elements' );
    is( $list[0], 1.5, 'first element is 1.5' );
    is( $list[1], 2.5, 'second element is 2.5' );
    is( $list[2], 3.5, 'third element is 3.5' );
    is( $list[3], 4.5, 'fourth element is 4.5' );
};

subtest 'to_list method - with negative numbers' => sub {
    my $v = Vector->new( size => 4, data => [-1, -2, -3, -4] );
    my @list = $v->to_list;

    is( scalar @list, 4, 'negative number vector returns 4 elements' );
    is( $list[0], -1, 'first element is -1' );
    is( $list[1], -2, 'second element is -2' );
    is( $list[2], -3, 'third element is -3' );
    is( $list[3], -4, 'fourth element is -4' );
};

subtest 'to_list method - with mixed signs' => sub {
    my $v = Vector->new( size => 4, data => [1, -2, 3, -4] );
    my @list = $v->to_list;

    is( scalar @list, 4, 'mixed sign vector returns 4 elements' );
    is( $list[0], 1, 'first element is 1' );
    is( $list[1], -2, 'second element is -2' );
    is( $list[2], 3, 'third element is 3' );
    is( $list[3], -4, 'fourth element is -4' );
};

subtest 'to_list method - edge cases' => sub {
    # Test with zero vector
    my $zeros = Vector->new( size => 4, data => [0, 0, 0, 0] );
    my @list_zeros = $zeros->to_list;
    is( scalar @list_zeros, 4, 'zero vector returns 4 elements' );
    for my $i (0..3) {
        is( $list_zeros[$i], 0, "element at $i is 0" );
    }

    # Test with single element
    my $single = Vector->new( size => 1, data => [99] );
    my @list_single = $single->to_list;
    is( scalar @list_single, 1, 'single element vector returns 1 element' );
    is( $list_single[0], 99, 'single element is correct' );

    # Test with larger vector
    my @data = (1..100);
    my $large = Vector->new( size => 100, data => \@data );
    my @list_large = $large->to_list;
    is( scalar @list_large, 100, 'large vector returns 100 elements' );
    for my $i (0..99) {
        is( $list_large[$i], $i + 1, "element at $i is " . ($i + 1) );
    }
};

subtest 'to_list method - list context usage' => sub {
    my $v = Vector->new( size => 4, data => [1, 2, 3, 4] );

    # Test in list context
    my ($first, $second, $third, $fourth) = $v->to_list;
    is( $first, 1, 'first element in list context is 1' );
    is( $second, 2, 'second element in list context is 2' );
    is( $third, 3, 'third element in list context is 3' );
    is( $fourth, 4, 'fourth element in list context is 4' );

    # Test with array assignment
    my @array = $v->to_list;
    is( scalar @array, 4, 'array assignment works correctly' );
    is( $array[0], 1, 'array element 0 is correct' );
    is( $array[3], 4, 'array element 3 is correct' );

    # Test with array reference creation
    my $array_ref = [ $v->to_list ];
    isa_ok( $array_ref, 'ARRAY', 'array reference creation works' );
    is( scalar @$array_ref, 4, 'array reference has correct size' );
    is( $array_ref->[0], 1, 'array reference element 0 is correct' );
    is( $array_ref->[3], 4, 'array reference element 3 is correct' );
};

subtest 'to_string method - string interpolation' => sub {
    my $v = Vector->new( size => 4, data => [1, 2, 3, 4] );

    # Test that to_string works in string interpolation
    my $interpolated = "Vector: $v";
    like( $interpolated, qr/Vector:/, 'interpolated string contains "Vector:"' );
    like( $interpolated, qr/1/, 'interpolated string contains 1' );
    like( $interpolated, qr/2/, 'interpolated string contains 2' );
    like( $interpolated, qr/3/, 'interpolated string contains 3' );
    like( $interpolated, qr/4/, 'interpolated string contains 4' );

    # Test with different vector
    my $v2 = Vector->new( size => 3, data => [10, 20, 30] );
    my $interpolated2 = "Values: $v2";
    like( $interpolated2, qr/Values:/, 'interpolated string contains "Values:"' );
    like( $interpolated2, qr/10/, 'interpolated string contains 10' );
    like( $interpolated2, qr/20/, 'interpolated string contains 20' );
    like( $interpolated2, qr/30/, 'interpolated string contains 30' );
};

done_testing;

__END__
