package Crixa;
use Moose;
use namespace::autoclean;

# ABSTRACT: A Cleaner API for Net::RabbitMQ

use Crixa::Channel;

with qw(Crixa::Engine);

sub connect {
    my $o = shift->new(@_);
    $o->_connect_mq($o);
    return $o;
}

has host => ( isa => 'Str', is => 'ro', required => 1, );

has [qw(user password)] => ( isa => 'Str', is => 'ro' );

has channel_id => (
    isa     => 'Int',
    default => 0,
    traits  => ['Counter'],
    handles => {
        _next_channel_id   => 'inc',
        release_channel_id => 'dec',
        reset_channel_id   => 'reset',
    }
);

has channels => (
    isa     => 'ArrayRef',
    traits  => ['Array'],
    lazy    => 1,
    default => sub { [] },
    handles => {
        _get_channel    => 'get',
        _add_channel    => 'push',
        _remove_channel => 'delete',
    }
);

sub channel {
    my $self = shift;
    my $args = @_ == 1 ? $_[0] : {@_};
    return $self->_get_channel($args) unless ref $args;
    $args->{id}     = $self->_next_channel_id;
    $args->{engine} = $self->engine;
    my $c = Crixa::Channel->new($args);
    $self->_add_channel($c);
    return $c;
}

sub queue      { shift->channel->queue(@_); }
sub disconnect { shift->_mq->disconnect(); }
sub DEMOLISH   { shift->disconnect; }

__PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME 

Crixa

=head1 SYNOPSIS 

    use Crixa;
    
    my $mq = Crixa->connect( host => 'localhost');
    
    sub send {
        my $q = $mq->queue( name => 'hello');
        $q->publish('Hello World');
    }
    
    sub receive {
        my $q = $mq->queue( name => 'hello');
        $q->handle_message(sub { say $_->{body} });
    }

=head1 DESCRIPTION

    All the world will be your enemy, Prince of a Thousand enemies. And when 
    they catch you, they will kill you. But first they must catch you; digger,
    listener, runner, Prince with the swift warning. Be cunning, and full of
    tricks, and your people will never be destroyed. -- Richard Adams

The RabbitMQ docs use Python's Pika library for most of their examples. When I
was translating the tutorial examples to Perl so I could get a grasp on how
different ideas would translate I found myself disliking the default
L<Net::RabbitMQ> API. That isn't to say it's I<bad>, just really bare bones.
So I went and wrote the API I wanted to use, influenced by he Pika examples.

=head1 ATTRIBUTES 

=head2 host (required)

The host with the RabbitMQ instance to connect to.

=head2 user

A user name to connect with.

=head2 password

The password for the (optional) username.

=head1 METHODS

=head2 connect 

Create a new connection to a RabbitMQ server. It takes a hash or hashref of named parameters.

=over 4

=item host => $hostname

A required hostname to connect to.

=item user => $user

An optional username.

=item password => $password

An optional password.

=back

=head2 channel ($id | \%args )

Return the channel associated with C<$id>. If C<$id> isn't defined it returns
a newly created channel.

=head2 queue(%args)

Return a newly configured queue, this will autovivify a channel.

=head2 disconnect

Disconnect from the server. This is called implicitly by C<DEMOLISH> so
normally there should be no need to do this explicitly.

=head2 DEMOLISH

=head1 SEE ALSO

=over 4

=item L<Net::RabbitMQ>

=back
