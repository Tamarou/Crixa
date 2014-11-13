package Crixa::Queue;
# ABSTRACT: A Crixa Queue

use 5.10.0;
use Moose;
use namespace::autoclean;

use Crixa::Message;

with qw(Crixa::HasEngine);

has name => (
    isa       => 'Str',
    reader    => 'name',
    writer    => '_name',
    predicate => '_has_name',
);

has channel => (
    isa      => 'Crixa::Channel',
    is       => 'ro',
    required => 1,
);

has passive => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

has durable => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

has exclusive => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

has auto_delete => (
    is      => 'ro',
    isa     => 'Bool',
    default => 1,
);

sub BUILD {
    my $self = shift;

    my $name = $self->_queue_declare;
    return if $self->_has_name;
    $self->_name($name);
}

sub _queue_declare {
    my $self    = shift;
    my $passive = shift;

    my $props = $self->_props;
    $props->{passive} = 1 if $passive;

    return $self->_mq->queue_declare(
        $self->channel->id,
        $self->name // '',
        $props,
    );
}

sub message_count {
    my $self = shift;

    my ( undef, $message_count, undef ) = $self->_queue_declare('passive');

    return $message_count;
}

sub check_for_message {
    my $self = shift;
    my $args = @_ > 1 ? {@_} : ref $_[0] ? $_[0] : {};

    return $self->_inflate_message(
        $self->_mq->get( $self->channel->id, $self->name, $args ) );
}

sub _inflate_message {
    my $self = shift;
    my $msg = shift;

    return unless defined $msg;

    return Crixa::Message->new( %$msg, channel => $self->channel );
}

sub wait_for_message {
    my $self = shift;

    my $msg;
    do { $msg = $self->check_for_message(@_); } until ( defined $msg );
    return $msg;
}

sub handle_message {
    my $self    = shift;
    my $handler = shift;
    my $args    = @_ > 1 ? {@_} : ref $_[0] ? $_[0] : {};

    my $msg = $self->wait_for_message($args);
    for ($msg) { return $handler->($msg) }
    confess 'Something unusual happened.';
}

sub bind {
    my $self = shift;
    my $args = @_ > 1 ? {@_} : ref $_[0] ? $_[0] : {};

    $self->_mq->queue_bind(
        $self->channel->id,
        $self->name,
        $args->{exchange},
        $args->{routing_key} // $self->name,
        $args->{headers} // {},
    );
}

sub delete {
    my $self = shift;
    my $args = @_ > 1 ? {@_} : ref $_[0] ? $_[0] : {};

    $self->_mq->queue_delete( $self->channel->id, $self->name, $args )
}

sub _props {
    my $self = shift;

    return { map { $_ => $self->$_() }
            qw( passive durable exclusive auto_delete ) };
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 DESCRIPTION

This class represents a single queue. With RabbitMQ, messages are published to
exchanges, which then routes the message to one or more queues. You then
consume those messages from the queue.

=head1 METHODS

This class provides the following methods:

=head2 Crixa::Queue->new(...)

This method creates a new queue object. You should not call this method
directly under normal circumstances. Instead, you should create a queue by
calling the C<queue> method on a L<Crixa::Channel> or L<Crixa::Exchange>
object. However, you need to know what parameters the constructor accepts.

=over 4

=item * name

The name of the queue. If none is provided then RabbitMQ will auto-generate a
name for you.

=item * passive => $bool

If this is true, then the constructor will throw an error B<unless the queue
already exists>.

This defaults to false.

=item * durable => $bool

If this is true, then the queue will remain active across server
restarts.

This defaults to false.

=item * auto_delete => $bool

If this is true, then the queue will be deleted when there are no more
consumers subscribed to it. The queue initially exists until at least one
consumer subscribes.

This defaults to false.

=item * exclusive => $bool

If this is true, then the queue is only accessible via the current connection
and will be deleted when that connection closes.

This defaults to false.

=back

=head2 $queue->check_for_message(...)

This checks the queue for a message. This method does not block. It returns
C<undef> if there is no message ready. It accepts either a hash or
hashref with the following keys:

=over 4

=item no_ack => $bool

If this is true, then the message is not acknowledged as it is taken from the
queue. You will need to explicitly acknowledge it using the C<ack> method on
the L<Crixa::Channel> object from which the message came.

If this is false, then the message is acknowledged immediately. Calling the
C<ack> method later with this message's delivery tag will be an error.

This defaults to true.

=back

=head2 $queue->wait_for_message(...)

This blocks until a message is ready. It always returns a single message.

This takes the same parameters as the C<check_for_message> method.

=head2 $queue->handle_message($callback, ...)

This message takes a callback and blocks until the next message. It calls the
callback with the message as its only argument and returns whatever the
callback returns.

This takes the same parameters as the C<check_for_message> method after the
callback.

=head2 $queue->message_count

Returns the number of messages waiting in the queue.

=head2 $queue->bind(...)

This binds a queue to an exchange. It accepts either a hash or hashref with
the following keys:

=over 4

=item * exchange

The name of the exchange to which the queue will be bound. This is required.

=item * routing_key

An optional routing key for the binding. If none is given the queue name is
used instead.

=item * headers

An optional hashref used when binding to a headers matching exchange.

This hashref should contain the headers against which the queue is
matching.

You can also specify an C<x-match> key of either "any" or "all". If the value
is "any" then the queue will receive a message when any of the headers in the
message match those that the queue was bound with. if it is set to "all" then
all headers in the message must match the binding.

=back

=head2 $queue->delete(...)

This deletes the queue. It accepts either a hash or hashref with the
following keys:

=over 4

=item * if_unused => $bool

If this is true, then the queue is only deleted if it has no consumers. Given
the way that Crixa handles getting messages, this is irrelevant if you are
only using Crixa to communicate with the queue.

This defaults to true.

=item * if_empty => $bool

If this is true, then the queue is only deleted if it is empty.

This defaults to true.

=back

=head2 $queue->name

Returns the queue name.

=head2 $queue->channel

Returns the L<Crixa::Channel> that this queue uses.

=head2 $queue->passive

This returns the passive flag as passed to the constructor or set by a
default.

=head2 $queue->durable

This returns the durable flag as passed to the constructor or set by a
default.

=head2 $queue->auto_delete

This returns the auto-delete flag as passed to the constructor or set by a
default.

=head2 $queue->exclusive

This returns the exclusive flag as passed to the constructor or set by a
default.

=cut
