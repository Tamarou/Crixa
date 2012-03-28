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
    my $args = @_ > 1 ? {@_} : ref $_[0] ? $_[0] : { body => $_[0] };
    $args->{routing_key} //= $self->name;
    $self->channel->publish($args);
}

1;
__END__
