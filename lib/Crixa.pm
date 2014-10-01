package Crixa;
# ABSTRACT: A Cleaner API for Net::AMQP::RabbitMQ

use Moose;
use namespace::autoclean;

use Crixa::Channel;

with qw(Crixa::Engine);

sub connect {
    my $o = shift->new(@_);
    $o->_connect_mq($o);
    return $o;
}

has host => ( isa => 'Str', is => 'ro', required => 1, );

has [qw(user password)] => ( isa => 'Str', is => 'ro' );
has [qw(port)] => ( isa => 'Int', is => 'ro' );

has _channel_id => (
    isa     => 'Int',
    default => 0,
    traits  => ['Counter'],
    handles => {
        _next_channel_id   => 'inc',
        release_channel_id => 'dec',
        reset_channel_id   => 'reset',
    }
);

sub new_channel {
    my $self = shift;

    return Crixa::Channel->new(
        id     => $self->_next_channel_id,
        engine => $self->engine,
    );
}

sub disconnect { shift->_mq->disconnect(); }
sub DEMOLISH   { shift->disconnect; }

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SYNOPSIS

    use Crixa;

    my $mq       = Crixa->connect( host => 'localhost' );
    my $channel  = $mq->channel;
    my $exchange = $channel->exchange( name => 'hello' );

    sub send {
        $exchange->publish('Hello World');
    }

    my $queue = $exchange->queue( name => 'hello' );

    sub receive {
        $queue->handle_message( sub { say $_->body } );
    }

=head1 DESCRIPTION

    All the world will be your enemy, Prince of a Thousand enemies. And when
    they catch you, they will kill you. But first they must catch you; digger,
    listener, runner, Prince with the swift warning. Be cunning, and full of
    tricks, and your people will never be destroyed. -- Richard Adams

This module provides a more natural API over L<Net::AMQP::RabbitMQ>, with
separate objects for channels, exchanges, and queues.

=head1 WARNING

B<Crixa is still in development and the API may change in the future!>

=head1 METHODS

This class provides the following methods:

=head2 Crixa->connect(...)

Creates a new connection to a RabbitMQ server. It takes a hash or hashref of
named parameters.

=over 4

=item host => $hostname

The hostname to connect to. Required.

=item port => $post

An optional port.

=item user => $user

An optional username.

=item password => $password

An optional password.

=back

=head2 $crixa->new_channel

Returns a new L<Crixa::Channel> object.

You can use the channel to create exchanges and queues.

=head2 $crixa->disconnect

Disconnect from the server. This is called implicitly by C<DEMOLISH> so
normally there should be no need to do this explicitly.

=head2 $crixa->host

Returns the port passed to the constructor, if nay.

=head2 $crixa->user

Returns the user passed to the constructor, if any.

=head2 $crixa->password

Returns the password passed to the constructor, if any.

=head1 SEE ALSO

This module uses L<Net::AMQP::RabbitMQ> under the hood, though it does not
expose everything provided by its API.

The best documentation we've found on RabbitMQ (and AMQP) concepts is the
Bunny documentation at http://rubybunny.info/articles/guides.html. We strongly
recommend browsing this to get a better understanding of how RabbitMQ works,
what different options for exchanges, queues, and messages mean, and more.

=cut

