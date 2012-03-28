package Crixa::Queue;
use 5.10.0;
use Moose;
use namespace::autoclean;

# ABSTRACT: A Crixa Queue

with qw(Crixa::Role::RabbitMQ);

has name => (
    isa    => 'Str',
    reader => 'name',
    writer => '_name'
);

has channel => (
    isa      => 'Crixa::Channel',
    is       => 'ro',
    required => 1,
);

sub BUILD {
    my $name = $_[0]
        ->_mq->queue_declare( $_[0]->channel->id, $_[0]->name // '', $_[1] );
    return if $_[0]->name;
    $_[0]->_name($name);
}

sub handle_message {
    my ( $self, $handler, $args ) = @_;
    my $msg;
    $args //= {};
    do {
        $msg = $self->_mq->get( $self->channel->id, $self->name, $args );
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

=head1 NAME

Crixa::Queue

=head1 DESCRIPTION

A class to represent Queues in Crixa.

=head1 ATTRIBUTES

=head2 name

=head2 channel

Required.

=head1 METHODS

=head2 BUILD

=head2 name

=head2 channel

=head2 handle_message

=head2 publish
