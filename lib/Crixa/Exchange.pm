package Crixa::Exchange;
use 5.10.0;
use Moose;
use namespace::autoclean;

# ABSTRACT: A Crixa Exchange

with qw(Crixa::Engine);

has name => ( isa => 'Str', is => 'ro', required => 1 );

has channel => (
    isa      => 'Crixa::Channel',
    is       => 'ro',
    required => 1,
    handles  => { queue => 'queue' },
);

sub BUILD {
    my ( $s, $args ) = @_;
    $s->_mq->exchange_declare( $s->channel->id, delete $args->{name}, $args );
}

around queue => sub {
    my $next = shift;
    my $self = shift;
    my $args     = @_ == 1 ? $_[0] : {@_};
    my $bindings = delete $args->{bindings} // ('');
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
