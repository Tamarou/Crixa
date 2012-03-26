package Crixa::Channel;
use Moose;
use namespace::autoclean;

use Crixa::Queue;

with qw(Crixa::Role::RabbitMQ);

has id => ( isa => 'Str', is => 'ro', );

sub BUILD { $_[0]->_mq_channel_open( $_[0]->id ); }

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
