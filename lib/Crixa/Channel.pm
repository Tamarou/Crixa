package Crixa::Channel;
use Moose;
use namespace::autoclean;

use Crixa::Queue;
use Crixa::Exchange;

with qw(Crixa::Role::RabbitMQ);

has id => ( isa => 'Str', is => 'ro', required => 1 );

sub BUILD { $_[0]->_mq_channel_open( $_[0]->id ); }

sub exchange {
    my $self = shift;
    Crixa::Exchange->new( @_, _mq => $self->_mq, channel => $self );
}

sub queue {
    my $self = shift;
    Crixa::Queue->new(
        @_,
        _mq     => $self->_mq,
        channel => $self,
    );
}

1;
__END__
