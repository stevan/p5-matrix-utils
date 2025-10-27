use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Exception;
use Data::Dumper;

use Scalar;
use Vector;
use Matrix;

use constant BOLD   => 1;
use constant DIM    => 2;
use constant UNDER  => 4;
use constant INVERT => 7;
use constant STRIKE => 9;

use constant Black   => 40;
use constant Red     => 41;
use constant Green   => 42;
use constant Yellow  => 43;
use constant Blue    => 44;
use constant Magenta => 45;
use constant Cyan    => 46;
use constant White   => 47;

use constant DEFAULT_CELL => '▁▁▁';

use constant PRIMITIVE => sprintf "\e[2;%dm p \e[0m" => Blue;
use constant CLASS     => sprintf "\e[4;%dm c \e[0m" => Cyan;
use constant ROLE      => sprintf "\e[4;%dm r \e[0m" => Red;
use constant FIELD     => sprintf "\e[4;%dm f \e[0m" => Blue;
use constant METHOD    => sprintf "\e[4;%dm m \e[0m" => Green;
use constant READER    => sprintf "\e[4;%dm a \e[0m" => Yellow;
use constant REQUIRED  => sprintf "\e[4;%dm r \e[0m" => Magenta;

use constant DOES     => sprintf "\e[4;%dm ◆ \e[0m" => Red;
use constant FULFILLS => sprintf "\e[4;%dm ● \e[0m" => Magenta;

use constant ISA      => sprintf "\e[4;%dm ◇ \e[0m" => Cyan;
use constant OVERRIDE => sprintf "\e[4;%dm ○ \e[0m" => Green;

use constant CALLS    => sprintf "\e[4;7;%dm & \e[0m" => Green;
use constant RETURNS  => sprintf "\e[4;2;%dm ▲ \e[0m" => Blue;
use constant READS    => sprintf "\e[4;7;%dm R \e[0m" => Blue;
use constant WRITES   => sprintf "\e[4;7;%dm W \e[0m" => Blue;

my @mop = (
    bool    => PRIMITIVE,
    int     => PRIMITIVE,
    float   => PRIMITIVE,
    string  => PRIMITIVE,

    Eq                    => ROLE,
    equal_to              => REQUIRED,
    not_equal_to          => METHOD,

    Ord                   => ROLE,
    compare               => REQUIRED,
    greater_than          => METHOD,
    greater_than_or_equal => METHOD,
    less_than             => METHOD,
    less_than_or_equal    => METHOD,

    Point                 => CLASS,
    '$x'                  => FIELD,
    x                     => READER,
    '$y'                  => FIELD,
    y                     => READER,
    clear                 => METHOD,
    compare               => METHOD,
    equal_to              => METHOD,

    Point3D               => CLASS,
    '$z'                  => FIELD,
    z                     => READER,
    clear                 => METHOD,
    compare               => METHOD,
);

my $mop_size = (scalar @mop / 2);

my %labels;
my @data;

my @pkgs;
foreach my ($symbol, $type) (@mop) {
    if ($type eq ROLE || $type eq CLASS) {
        push @pkgs => $symbol;
    }

    my @row = (DEFAULT_CELL) x $mop_size;
    my $idx = scalar @data;
    $row[ $idx ] = $type;

    my $label;
    if (($pkgs[-1] // '') eq $symbol) {
        $label = "${symbol}::",
    } else {
        $label = join '::' => ($pkgs[-1] // ''), $symbol;
    }

    $labels{ $label } = $idx;

    push @data => [ @row ];
}

# Eq

$data[ $labels{'Eq::equal_to'}     ][ $labels{'::bool'} ] = RETURNS;
$data[ $labels{'Eq::not_equal_to'} ][ $labels{'::bool'} ] = RETURNS;

$data[ $labels{'Eq::not_equal_to'} ][ $labels{'Eq::equal_to'} ] = CALLS;

# Ord

$data[ $labels{'Ord::compare'}               ][ $labels{'::int'}  ] = RETURNS;
$data[ $labels{'Ord::greater_than'}          ][ $labels{'::bool'} ] = RETURNS;
$data[ $labels{'Ord::greater_than_or_equal'} ][ $labels{'::bool'} ] = RETURNS;
$data[ $labels{'Ord::less_than'}             ][ $labels{'::bool'} ] = RETURNS;
$data[ $labels{'Ord::less_than_or_equal'}    ][ $labels{'::bool'} ] = RETURNS;

$data[ $labels{'Ord::greater_than'}          ][ $labels{'Ord::compare'} ] = CALLS;
$data[ $labels{'Ord::greater_than_or_equal'} ][ $labels{'Ord::compare'} ] = CALLS;
$data[ $labels{'Ord::less_than'}             ][ $labels{'Ord::compare'} ] = CALLS;
$data[ $labels{'Ord::less_than_or_equal'}    ][ $labels{'Ord::compare'} ] = CALLS;

# Point

$data[ $labels{'Point::'} ][ $labels{'Ord::'} ] = DOES;
$data[ $labels{'Point::'} ][ $labels{'Eq::'} ]  = DOES;

$data[ $labels{'Point::equal_to'} ][ $labels{'Eq::equal_to'} ] = FULFILLS;
$data[ $labels{'Point::compare'}  ][ $labels{'Ord::compare'} ] = FULFILLS;

$data[ $labels{'Point::x'} ][ $labels{'Point::$x'} ] = READS;
$data[ $labels{'Point::y'} ][ $labels{'Point::$y'} ] = READS;

$data[ $labels{'Point::x'} ][ $labels{'::int'} ] = RETURNS;
$data[ $labels{'Point::y'} ][ $labels{'::int'} ] = RETURNS;

$data[ $labels{'Point::equal_to'} ][ $labels{'::bool'}         ] = RETURNS;
$data[ $labels{'Point::equal_to'} ][ $labels{'Point::compare'} ] = CALLS;

$data[ $labels{'Point::compare'} ][ $labels{'Point::$x'} ] = READS;
$data[ $labels{'Point::compare'} ][ $labels{'Point::$y'} ] = READS;
$data[ $labels{'Point::compare'} ][ $labels{'::bool'}    ] = RETURNS;

$data[ $labels{'Point::clear'} ][ $labels{'Point::$x'} ] = WRITES;
$data[ $labels{'Point::clear'} ][ $labels{'Point::$y'} ] = WRITES;

# Point3D

$data[ $labels{'Point3D::'} ][ $labels{'Point::'} ] = ISA;

$data[ $labels{'Point3D::z'} ][ $labels{'Point3D::$z'} ] = READS;
$data[ $labels{'Point3D::z'} ][ $labels{'::int'} ]       = RETURNS;

$data[ $labels{'Point3D::compare'} ][ $labels{'Point3D::$z'}    ] = READS;
$data[ $labels{'Point3D::compare'} ][ $labels{'Point::compare'} ] = OVERRIDE;
$data[ $labels{'Point3D::compare'} ][ $labels{'::bool'}         ] = RETURNS;

$data[ $labels{'Point3D::clear'} ][ $labels{'Point3D::$z'}  ] = WRITES;
$data[ $labels{'Point3D::clear'} ][ $labels{'Point::clear'} ] = OVERRIDE;

## ...

my %rev_labels = reverse %labels;

my $m = Matrix->initialize([ $mop_size, $mop_size ], [ map $_->@*, @data ]);

sub draw ($m) {
    my @out;
    for (my $x = 0; $x < $m->rows; $x++) {
        push @out =>
            join '┃' =>
                ($m->slice_data_array( $m->row_indices( $x ) )),
                sprintf(' %s', $rev_labels{$x}),;
    }
    return join "\n" => @out;
}

say draw($m);
