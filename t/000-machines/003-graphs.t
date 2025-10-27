
use v5.40;
use experimental qw[ class ];

class MOP::Graph::Entity {
    field $type  :reader;

    our @ENTITIES;

    ADJUST {
        $type = blessed $self;
        $type =~ s/^MOP\:\:Graph\:\://;
        push @ENTITIES => $self;
    }
}

class MOP::Graph::Vertex :isa(MOP::Graph::Entity) {
    field $label :param :reader;

    field @edges;
    method connect ($type, $vertex) {
        my $edge_class = "MOP::Graph::${type}";
        push @edges => $edge_class->new( from => $self, to => $vertex );
    }
}

class MOP::Graph::Edge :isa(MOP::Graph::Entity) {
    field $to   :param :reader;
    field $from :param :reader;
}

class MOP::Graph::Class :isa(MOP::Graph::Vertex) {}
class MOP::Graph::Role  :isa(MOP::Graph::Vertex) {}

class MOP::Graph::ISA        :isa(MOP::Graph::Edge) {}
class MOP::Graph::DOES       :isa(MOP::Graph::Edge) {}
class MOP::Graph::HAS        :isa(MOP::Graph::Edge) {}
class MOP::Graph::CAN        :isa(MOP::Graph::Edge) {}

class MOP::Graph::Field       :isa(MOP::Graph::Vertex) {}
class MOP::Graph::Method      :isa(MOP::Graph::Vertex) {}

class MOP::Graph::Subroutine  :isa(MOP::Graph::Vertex) {}

class MOP::Graph::REQUIRED   :isa(MOP::Graph::Edge) {}
class MOP::Graph::OVERRIDES  :isa(MOP::Graph::Edge) {}
class MOP::Graph::FULFILLS   :isa(MOP::Graph::Edge) {}
class MOP::Graph::CONSTRUCTS :isa(MOP::Graph::Edge) {}

## -----------------------------------------------------------------------------

my $Point = MOP::Graph::Class->new( label => 'Point' );

my $Point_x = MOP::Graph::Field->new( label => '$x' );
my $Point_y = MOP::Graph::Field->new( label => '$y' );

$Point->connect(HAS => $Point_x);
$Point->connect(CAN => MOP::Graph::Method->new( label => 'x' ));

$Point->connect(HAS => $Point_y);
$Point->connect(CAN => MOP::Graph::Method->new( label => 'y' ));

my $Point_new = MOP::Graph::Subroutine->new( label => 'new' );

$Point_new->connect(CONSTRUCTS => $Point);
$Point_new->connect(REQUIRED => $Point_x);
$Point_new->connect(REQUIRED => $Point_y);

$Point->connect(CAN => $Point_new);
$Point->connect(CAN => MOP::Graph::Subroutine->new( label => 'at' ));

$Point->connect(CAN => MOP::Graph::Method->new( label => 'add' ));

## -----------------------------------------------------------------------------

my $Point3D = MOP::Graph::Class->new( label => 'Point3D' );

$Point3D->connect(ISA => $Point);

my $Point3D_z = MOP::Graph::Field->new( label => '$z' );

$Point3D->connect(HAS => $Point3D_z);
$Point3D->connect(CAN => MOP::Graph::Method->new( label => 'z' ));

my $Point3D_new = MOP::Graph::Subroutine->new( label => 'new' );

$Point3D_new->connect(CONSTRUCTS => $Point3D);
$Point3D_new->connect(REQUIRED   => $Point3D_z);

$Point3D->connect(OVERRIDES => $Point3D_new);
$Point3D->connect(OVERRIDES => MOP::Graph::Subroutine->new( label => 'at' ));

$Point3D->connect(OVERRIDES => MOP::Graph::Method->new( label => 'add' ));

## -----------------------------------------------------------------------------

use Data::Dumper qw[ Dumper ];

warn Dumper [
    map {
        +{
            type  => $_->type,
            label => $_->can('label') ? $_->label : ' -> ',

        }
    } @MOP::Graph::Entity::ENTITIES
];

=pod

class Point {
    field $x :param :reader;
    field $y :param :reader;

    sub at ($x, $y) {
        return Point->new( x => $x, y => $y )
    }

    method add ($other) {
        return Point->new(
            x => $self->x + $other->x,
            y => $self->y + $other->y,
        );
    }
}

class Point3D extends Point {
    field $z :param :reader;

    sub at ($x, $y, $z) {
        return Point3D->new( x => $x, y => $y, z => $z )
    }

    method add ($other) {
        return Point3D->new(
            x => $self->x + $other->x,
            y => $self->y + $other->y,
            z => $self->z + $other->z,
        );
    }
}

=cut
