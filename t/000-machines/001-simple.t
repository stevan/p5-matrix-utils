use v5.40;
use experimental qw[ class ];

#use Test::More;
#use Test::Exception;
#use Data::Dumper;

use Scalar;
use Vector;
use Matrix;

use B ();

my @GVs;
sub B::GV::fullname ($self) { push @GVs => $self }

B::walksymtable(\%main::, 'fullname', sub ($pkg) {
    $pkg =~ s/^main\:\://;
    return not $pkg =~ /^B\:\:/
        || $pkg =~ /^(warnings|version|overload|overloading|re|strict|threads|utf8|builtin|feature|experimental|mro|constant)\:\:/
        || $pkg =~ /^(Dyna|XS)Loader\:\:/
        || $pkg =~ /^(DB|Internals|UNIVERSAL|Tie)\:\:/
        || $pkg =~ /^Regexp\:\:/
        || $pkg =~ /^(Perl)?IO\:\:/
        || $pkg =~ /^(List|Scalar|Sub)\:\:Util\:\:/
        || $pkg =~ /^Carp\:\:/
        || $pkg =~ /^Exporter\:\:/
    ;
}, 'main::');

my @symbols = sort {
    # lets sort them ...
    B::safename($a->STASH->NAME) cmp B::safename($b->STASH->NAME)
} grep {
    my $gv = $_;
    scalar grep { B::class($gv->$_) eq $_ } qw[ SV AV HV CV ]
} grep {
    # we can ignore some packages for now ...
    B::safename($_->STASH->NAME) ne 'Tensor::Ops'
} grep {
    B::safename($_->NAME) !~ /^(ISA|BEGIN)$/ && B::safename($_->NAME) !~ /^\(/
} grep {
    # we don't need main ...
    B::safename($_->STASH->NAME) ne 'main'
} @GVs;

my $fmt = '%03d | %16s | %-20s | %-2s | %-2s | %-2s | %-2s | %-2s |';
say sprintf $fmt => 0, qw[ package method SV AV HV CV OV ];
say '-' x 80;
foreach my ($i, $symbol) (indexed @symbols) {
    my $name = B::safename($symbol->NAME);
    say sprintf $fmt =>
        $i,
        B::safename($symbol->STASH->NAME),
        $name,
        (map { B::class($symbol->$_) eq $_ ? 'X' : '_' } qw[ SV AV HV CV ]),
        ($name =~ /^\(/ ? 'X' : '_')
    ;
}

# my $m = Matrix->initialize();
