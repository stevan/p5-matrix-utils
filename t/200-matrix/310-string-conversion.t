use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Exception;
use Data::Dumper;

use Matrix;

subtest 'to_string method - basic string representation' => sub {
    my $m = Matrix->new( shape => [2, 2], data => [1, 2, 3, 4] );
    my $str = $m->to_string;

    like( $str, qr/1/, 'string contains 1' );
    like( $str, qr/2/, 'string contains 2' );
    like( $str, qr/3/, 'string contains 3' );
    like( $str, qr/4/, 'string contains 4' );

    # Test that it's formatted properly (should have newlines)
    like( $str, qr/\n/, 'string contains newlines' );

    # Test specific format (should be space-separated with newlines between rows)
    my @lines = split /\n/, $str;
    is( scalar @lines, 2, 'string has 2 lines (rows)' );

    # Check first line format
    like( $lines[0], qr/^\s*1\s+2\s*$/, 'first line format is correct' );
    like( $lines[1], qr/^\s*3\s+4\s*$/, 'second line format is correct' );
};

subtest 'to_string method - with different matrix sizes' => sub {
    # Test with 3x3 matrix
    my $m1 = Matrix->new( shape => [3, 3], data => [1, 2, 3, 4, 5, 6, 7, 8, 9] );
    my $str1 = $m1->to_string;

    my @lines1 = split /\n/, $str1;
    is( scalar @lines1, 3, '3x3 matrix string has 3 lines' );
    like( $lines1[0], qr/^\s*1\s+2\s+3\s*$/, 'first line of 3x3 is correct' );
    like( $lines1[1], qr/^\s*4\s+5\s+6\s*$/, 'second line of 3x3 is correct' );
    like( $lines1[2], qr/^\s*7\s+8\s+9\s*$/, 'third line of 3x3 is correct' );

    # Test with 2x4 matrix
    my $m2 = Matrix->new( shape => [2, 4], data => [1, 2, 3, 4, 5, 6, 7, 8] );
    my $str2 = $m2->to_string;

    my @lines2 = split /\n/, $str2;
    is( scalar @lines2, 2, '2x4 matrix string has 2 lines' );
    like( $lines2[0], qr/^\s*1\s+2\s+3\s+4\s*$/, 'first line of 2x4 is correct' );
    like( $lines2[1], qr/^\s*5\s+6\s+7\s+8\s*$/, 'second line of 2x4 is correct' );

    # Test with 4x2 matrix
    my $m3 = Matrix->new( shape => [4, 2], data => [1, 2, 3, 4, 5, 6, 7, 8] );
    my $str3 = $m3->to_string;

    my @lines3 = split /\n/, $str3;
    is( scalar @lines3, 4, '4x2 matrix string has 4 lines' );
    like( $lines3[0], qr/^\s*1\s+2\s*$/, 'first line of 4x2 is correct' );
    like( $lines3[1], qr/^\s*3\s+4\s*$/, 'second line of 4x2 is correct' );
    like( $lines3[2], qr/^\s*5\s+6\s*$/, 'third line of 4x2 is correct' );
    like( $lines3[3], qr/^\s*7\s+8\s*$/, 'fourth line of 4x2 is correct' );
};

subtest 'to_string method - with floating point numbers' => sub {
    my $m = Matrix->new( shape => [2, 2], data => [1.5, 2.5, 3.5, 4.5] );
    my $str = $m->to_string;

    like( $str, qr/1\.5/, 'string contains 1.5' );
    like( $str, qr/2\.5/, 'string contains 2.5' );
    like( $str, qr/3\.5/, 'string contains 3.5' );
    like( $str, qr/4\.5/, 'string contains 4.5' );

    my @lines = split /\n/, $str;
    is( scalar @lines, 2, 'floating point matrix string has 2 lines' );
};

subtest 'to_string method - with negative numbers' => sub {
    my $m = Matrix->new( shape => [2, 2], data => [-1, -2, -3, -4] );
    my $str = $m->to_string;

    like( $str, qr/-1/, 'string contains -1' );
    like( $str, qr/-2/, 'string contains -2' );
    like( $str, qr/-3/, 'string contains -3' );
    like( $str, qr/-4/, 'string contains -4' );

    my @lines = split /\n/, $str;
    is( scalar @lines, 2, 'negative number matrix string has 2 lines' );
};

subtest 'to_string method - with mixed signs' => sub {
    my $m = Matrix->new( shape => [2, 2], data => [1, -2, 3, -4] );
    my $str = $m->to_string;

    like( $str, qr/1/, 'string contains 1' );
    like( $str, qr/-2/, 'string contains -2' );
    like( $str, qr/3/, 'string contains 3' );
    like( $str, qr/-4/, 'string contains -4' );

    my @lines = split /\n/, $str;
    is( scalar @lines, 2, 'mixed sign matrix string has 2 lines' );
};

subtest 'to_string method - edge cases' => sub {
    # Test with single element matrix
    my $single = Matrix->new( shape => [1, 1], data => [42] );
    my $str_single = $single->to_string;

    like( $str_single, qr/42/, 'single element string contains 42' );
    my @lines_single = split /\n/, $str_single;
    is( scalar @lines_single, 1, 'single element matrix string has 1 line' );

    # Test with zero matrix
    my $zeros = Matrix->new( shape => [2, 2], data => [0, 0, 0, 0] );
    my $str_zeros = $zeros->to_string;

    like( $str_zeros, qr/0/, 'zero matrix string contains 0' );
    my @lines_zeros = split /\n/, $str_zeros;
    is( scalar @lines_zeros, 2, 'zero matrix string has 2 lines' );

    # Test with identity matrix
    my $eye = Matrix->eye(2);
    my $str_eye = $eye->to_string;

    like( $str_eye, qr/1/, 'identity matrix string contains 1' );
    like( $str_eye, qr/0/, 'identity matrix string contains 0' );
    my @lines_eye = split /\n/, $str_eye;
    is( scalar @lines_eye, 2, 'identity matrix string has 2 lines' );
};

subtest 'to_string method - with larger matrices' => sub {
    # Test with 5x5 matrix
    my @data = (1..25);
    my $large = Matrix->new( shape => [5, 5], data => \@data );
    my $str_large = $large->to_string;

    my @lines_large = split /\n/, $str_large;
    is( scalar @lines_large, 5, '5x5 matrix string has 5 lines' );

    # Check that all numbers 1-25 are present
    for my $i (1..25) {
        like( $str_large, qr/\b$i\b/, "large matrix string contains $i" );
    }

    # Test with rectangular matrix
    my @data2 = (1..20);
    my $rect = Matrix->new( shape => [4, 5], data => \@data2 );
    my $str_rect = $rect->to_string;

    my @lines_rect = split /\n/, $str_rect;
    is( scalar @lines_rect, 4, '4x5 matrix string has 4 lines' );

    # Check that all numbers 1-20 are present
    for my $i (1..20) {
        like( $str_rect, qr/\b$i\b/, "rectangular matrix string contains $i" );
    }
};

subtest 'to_string method - string interpolation' => sub {
    my $m = Matrix->new( shape => [2, 2], data => [1, 2, 3, 4] );

    # Test that to_string works in string interpolation
    my $interpolated = "Matrix: $m";
    like( $interpolated, qr/Matrix:/, 'interpolated string contains "Matrix:"' );
    like( $interpolated, qr/1/, 'interpolated string contains 1' );
    like( $interpolated, qr/2/, 'interpolated string contains 2' );
    like( $interpolated, qr/3/, 'interpolated string contains 3' );
    like( $interpolated, qr/4/, 'interpolated string contains 4' );

    # Test with different matrix
    my $m2 = Matrix->new( shape => [1, 3], data => [10, 20, 30] );
    my $interpolated2 = "Values: $m2";
    like( $interpolated2, qr/Values:/, 'interpolated string contains "Values:"' );
    like( $interpolated2, qr/10/, 'interpolated string contains 10' );
    like( $interpolated2, qr/20/, 'interpolated string contains 20' );
    like( $interpolated2, qr/30/, 'interpolated string contains 30' );
};

done_testing;

__END__
