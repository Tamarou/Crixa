package Crixa::HasMQ;
# ABSTRACT: For internal use only

use Moose::Role;
use namespace::autoclean;

use Moose::Util::TypeConstraints qw( duck_type );

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
    required => 1,
);

1;
__END__

=head1 DESCRIPTION

This is used internally by Crixa. There are no user accessible parts here.

