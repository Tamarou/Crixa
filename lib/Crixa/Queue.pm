package Crixa::Queue;
# ABSTRACT: A Crixa Queue

use 5.10.0;
use Moose;
use namespace::autoclean;

with qw(Crixa::Engine);

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

sub check_for_message {
    my ( $self, $args ) = @_;
    $args //= {};
    $self->_mq->get( $self->channel->id, $self->name, $args );
}

sub wait_for_message {
    my ( $self, $args ) = @_;
    my $msg;
    do { $msg = $self->check_for_message($args); } until ( defined $msg );
    return $msg;
}

sub handle_message {
    my ( $self, $handler, $args ) = @_;
    my $msg = $self->wait_for_message($args);
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

The queue name.

=head2 channel

The channel this queue is configured for.

=head2 check_for_message

Checks the queue for a message. This doesn't block but instead will return
undef if the queue is empty.

=head2 wait_for_message

Checks the queue for a message and blocks until one appears.

=head2 handle_message

Takes a callback and executes the callback when the next message appears in
the queue.

=head2 publish

Send a new message to this queue.
