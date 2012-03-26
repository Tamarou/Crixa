package Crixa::Queue;
use Moose;
use namespace::autoclean;

with qw(Crixa::Role::RabbitMQ);

has name => ( isa => 'Str', reader => 'name', writer => '_name' );

has channel => (
    isa      => 'Crixa::Channel',
    is       => 'ro',
    required => 1,
    handles  => { 'channel_id' => 'id' },
);

sub BUILD {
    my $s = shift;
    $s->_name( $s->_mq_queue_declare( $s->channel_id, $s->name, {} ) );
}

sub on_message {
    my ( $self, $handler ) = @_;
    my $msg;
    do { $msg = $self->_mq_get( 1, $self->name, {} ) } until ( defined $msg );
    for ($msg) { return $handler->($msg) }
    confess 'Something unusual happened.';
}

sub publish {
    my $self = shift;
    if ( @_ == 1 && ref $_[0] eq 'HASH' ) {
        my $props = delete $_[0]->{props};
        return $self->_mq_publish(
            $self->channel_id,
            delete $_[0]->{routing_key},
            delete $_[0]->{body},
            $_[0], $props
        );
    }
    elsif ( @_ == 1 && !ref $_[0] ) {
        return $self->_mq_publish( $self->channel_id, $self->name, $_[0], {},
        );
    }
    else {
        confess "I'm not sure what to do with @_";
    }
}

1;
__END__
