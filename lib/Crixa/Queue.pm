package Crixa::Queue;
use 5.10.0;
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
    $_[0]->_name(
        $_[0]->_mq_queue_declare(
            $_[0]->channel_id, $_[0]->name // '', $_[1]
        )
    );
}

sub handle_message {
    my ( $self, $handler, $args ) = @_;
    my $msg;
    $args //= {};
    do {
        $msg = $self->_mq_get( $self->channel_id, $self->name, $args );
    } until ( defined $msg );

    for ($msg) { return $handler->($msg) }
    confess 'Something unusual happened.';
}

sub publish {
    my $self = shift;
    use DDP;
    p @_;
    if ( @_ == 1 && ref $_[0] eq 'HASH' ) {
        my $props = delete $_[0]->{props};
        return $self->_mq_publish(
            $self->channel_id,
            delete $_[0]->{routing_key} // $self->name,
            delete $_[0]->{body} || confess "need to supply a body",
            $_[0],
            $props
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
