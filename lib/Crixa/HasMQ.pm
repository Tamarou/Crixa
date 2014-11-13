package Crixa::HasMQ;
# ABSTRACT: For internal use only

use Moose::Role;
use namespace::autoclean;

use Moose::Util::TypeConstraints qw( duck_type );
use Net::AMQP::RabbitMQ;

# XXX - Test::Net::RabbitMQ doesn't support some of the method we call
# internally so we won't require them but it sure would be nice to patch
# Test::Net::RabbitMQ to include these:
#
#        ack
#        basic_qos
#        exchange_delete
#        queue_delete
my $mq_api_type = duck_type [
    qw(
        channel_open
        connect
        disconnect
        exchange_declare
        get
        publish
        queue_bind
        queue_declare
        )
];

has _mq => (
    is       => 'ro',
    isa      => $mq_api_type,
    init_arg => 'mq',
    lazy     => 1,
    builder  => '_build_mq',
    handles  => ['is_connected'],
);

sub _build_mq { Net::AMQP::RabbitMQ->new; }

sub _connect_mq {
    my ( $self, $crixa ) = @_;

    my %args;
    for (qw( user password port )) {
        $args{$_} = $crixa->$_ if defined $crixa->$_;
    }
    $self->_mq->connect( $crixa->host, \%args );
}

sub _disconnect_mq { shift->_mq->disconnect }

1;
__END__

=head1 DESCRIPTION

This is used internally by Crixa. There are no user accessible parts here.

