package Crixa::Exchange;
use 5.10.0;
use Moose;
use namespace::autoclean;

with qw(Crixa::Role::RabbitMQ);

has name => ( isa => 'Str', is => 'ro', required => 1 );

has channel => (
    isa      => 'Crixa::Channel',
    is       => 'ro',
    required => 1,
    handles  => {
        channel_id => 'id',
        queue      => 'queue'
    },
);

sub BUILD {
    my ( $s, $args ) = @_;
    $s->_mq->exchange_declare( $s->channel_id, delete $args->{name}, $args );
}

around queue => sub {
    my ( $next, $self ) = splice @_, 0, 2;
    my $args     = @_ == 1 ? $_[0] : {@_};
    my $q        = $self->$next(%$args);
    my @bindings = delete $args->{bindings} // ('');
    for my $binding (@bindings) {
        $self->_mq_queue_bind( $self->channel_id, $q->name, $self->name,
            $binding );
    }
    return $q;
};
use DDP;

sub publish {
    my $self = shift;
    my $args = @_ == 1 ? $_[0] : {@_};

    if ( ref $args eq 'HASH' ) {
        $args->{exchange} ||= $self->name;
        my $props = delete $args->{props};
        return $self->_mq_publish(
            $self->channel_id,
            delete $args->{routing_key} // '',
            delete $args->{body} || confess("need to supply a body"),
            $args, $props
        );
    }
    elsif ( !ref $args ) {
        return $self->_mq_publish( $self->channel_id, '', $args,
            { exchange => $self->name },
        );
    }
    else {
        confess "I'm not sure what to do with $args";
    }
}

1;
__END__
