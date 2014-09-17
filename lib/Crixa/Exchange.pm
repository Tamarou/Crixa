package Crixa::Exchange;
# ABSTRACT: A Crixa Exchange

use 5.10.0;
use Moose;
use namespace::autoclean;

with qw(Crixa::Engine);

has name => ( isa => 'Str', is => 'ro', required => 1 );

has channel => (
    isa      => 'Crixa::Channel',
    is       => 'ro',
    required => 1,
    handles  => { queue => 'queue' },
);

has exchange_type => (
    isa       => 'Str',
    is        => 'ro',
    predicate => '_has_exchange_type',
);

for my $name (qw( passive durable auto_delete )) {
    has $name => (
        is        => 'ro',
        isa       => 'Bool',
        predicate => '_has_' . $name,
    );
}

sub BUILD {
    my $s = shift;
    $s->_mq->exchange_declare( $s->channel->id, $s->name, $s->_props );
}

around queue => sub {
    my $next     = shift;
    my $self     = shift;
    my $args     = @_ == 1 ? $_[0] : {@_};
    my $bindings = delete $args->{bindings} // [];
    my $q        = $self->$next($args);

    for my $binding (@$bindings) {
        $self->_mq->queue_bind( $self->channel->id, $q->name, $self->name,
            $binding );
    }
    return $q;
};

sub publish {
    my $self = shift;
    my $args = @_ > 1 ? {@_} : ref $_[0] ? $_[0] : { body => $_[0] };
    $args->{exchange} //= $self->name;
    $self->channel->publish($args);
}

sub delete {
    my ( $self, $args ) = @_;
    $args //= {};

    $self->_mq->exchange_delete( $self->channel->id, $self->name, $args );
}

sub _props {
    my $self = shift;

    my %props = map { $_ => $self->$_() } grep {
        my $pred = '_has_' . $_;
        $self->$pred()
    } qw( exchange_type passive durable auto_delete );

    return \%props;
}

1;
__END__

=head1 NAME

Crixa::Exchange

=head1 DESCRIPTION

A class to represent Exchanges in Crixa.

=head1 ATTRIBUTES

=head2 name

=head2 channel

Required.

Required

=head2 channel

=head1 METHODS 

=head2 BUILD

=head2 name

=head2 channel

=head2 queue

=head2 publish
