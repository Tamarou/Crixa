package Crixa::Engine::RabbitMQ;
use Moose;
use namespace::autoclean;

# ABSTRACT: A Class for managing the RabbitMQ instance

use Net::RabbitMQ;

has _mq => ( is => 'ro', lazy => 1, builder => '_build__mq' );

sub _build__mq { Net::RabbitMQ->new; }

sub _connect_mq {
    my ( $self, $config ) = @_;
    my @args = ( $config->host );
    if ( $config->user && $config->password ) {
        push @args => {
            user     => $config->user,
            password => $config->password
        };
    }
    else { push @args => {} }
    $self->_mq->connect(@args);
}

with qw(Crixa::Engine::API);    # at the end so we pick up _mq

1;
__END__

=head1 DESCRIPTION

This is a wholly internal Role for dealing with RabbitMQ. There are no public
facing parts here. This is not the code you're looking for. Move along now,
move along.

=head1 ATTRIBUTES

There are no publically visible attributes.

=head1 METHODS

There are no publically visible methods.
