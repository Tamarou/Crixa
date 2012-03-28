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

sub basic_qos {
    my $self = shift;
    my $args = @_ == 1 ? $_[0] : {@_};
    $self->_mq_basic_qos( $self->id, $args );
}

sub queue {
    my $self = shift;
    my $args = @_ == 1 ? $_[0] : {@_};
    $args->{_mq}     = $self->_mq;
    $args->{channel} = $self;
    Crixa::Queue->new($args);
}

sub ack { $_[0]->_mq_ack( shift->id, @_ ) }

sub publish {
    my $self = shift;
    my $args = @_ == 1 ? $_[0] : {@_};
    if ( ref $args eq 'HASH' ) {
        my $props = delete $args->{props};
        return $self->_mq_publish(
            $self->id,
            delete $args->{routing_key} // '',
            delete $args->{body} || confess("need to supply a body"),
            $args, $props
        );
    }
    elsif ( !ref $args ) {
        return $self->_mq_publish( $self->id, '', $args, {}, );
    }
    else {
        confess "I'm not sure what to do with $args";
    }
}

1;
__END__
