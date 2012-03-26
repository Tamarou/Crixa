package Crixa;
use Moose;
use namespace::autoclean;

# ABSTRACT: A Cleaner API for Net::RabbitMQ

use Crixa::Channel;

with qw(Crixa::Role::RabbitMQ);

sub connect { shift->new(@_) }

has host => ( isa => 'Str', is => 'ro', required => 1, );
has [qw(user password)] => ( isa => 'Str', is => 'ro' );

sub _build__mq { $_[0]->_connect_mq( $_[0] ); }

has channel_id => (
    is      => 'ro',
    isa     => 'Int',
    trigger => sub {
        my ( $self, $next ) = @_;
        confess "Cannot exceed max channel id"
            if $self->_mq_get_channel_max()
                && $self->_mq_get_channel_max() < $next;
    },
    default => 0,
    traits  => ['Counter'],
    handles => {
        next_channel_id    => 'inc',
        release_channel_id => 'dec',
        reset_channel_id   => 'reset',
    }
);

sub channel {
    my $self = shift;
    Crixa::Channel->new(
        id => $self->next_channel_id,
        @_, _mq => $self->_mq,
    );
}

sub queue { shift->channel->queue(@_); }

sub DEMOLISH { shift->_mq_disconnect(); }

__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 SYNOPSIS 

    use Crixa;
    
    my $mq = Crixa->connect( host => 'localhost');

    sub send {
        my $q = $mq->queue( name => 'hello');
        $q->publish('Hello World');
    }
    
    sub receive {
        my $q = $mq->queue( name => 'hello');
        $q->on_message(sub { say $_->{body} });
    }
    
