package Crixa::Channel;
use Moose;
use namespace::autoclean;

# ABSTRACT: A Crixa Channel

use Crixa::Queue;
use Crixa::Exchange;

with qw(Crixa::Role::RabbitMQ);

has id => ( isa => 'Str', is => 'ro', required => 1 );

sub BUILD { $_[0]->_mq->channel_open( $_[0]->id ); }

sub exchange {
    my $self = shift;
    Crixa::Exchange->new( @_, _mq => $self->_mq, channel => $self );
}

sub basic_qos {
    my $self = shift;
    my $args = @_ == 1 ? $_[0] : {@_};
    $self->_mq->basic_qos( $self->id, $args );
}

sub queue {
    my $self = shift;
    my $args = @_ == 1 ? shift : {@_};
    $args->{_mq}     = $self->_mq;
    $args->{channel} = $self;
    Crixa::Queue->new($args);
}

sub ack { $_[0]->_mq->ack( shift->id, @_ ) }

sub publish {
    my $self = shift;
    my $args = @_ == 1 ? $_[0] : {@_};
    if ( ref $args eq 'HASH' ) {
        my $props = delete $args->{props};
        return $self->_mq->publish(
            $self->id,
            delete $args->{routing_key} // '',
            delete $args->{body} || confess("need to supply a body"),
            $args, $props
        );
    }
    elsif ( !ref $args ) {
        return $self->_mq->publish( $self->id, '', $args, {}, );
    }
    else {
        confess "I'm not sure what to do with $args";
    }
}

1;
__END__

=head1 NAME

Crixa::Channel

=head1 DESCRIPTION

A class to represent Channels in Crixa.

=head1 ATTRIBUTES

=head2 id 

Required.

=head1 METHODS

=head2 BUILD 

=head2 id

=head2 exchange

=head2 queue

=head2 basic_qos

=head2 ack

=head2 publish