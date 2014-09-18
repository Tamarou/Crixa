use strict;
use warnings;

use Test::More;
use Test::Requires qw( Test::Net::RabbitMQ );
use Crixa;

my $mq = Crixa->connect(
    host => '',
    engine =>
        Crixa::Engine::RabbitMQ->new( _mq => Test::Net::RabbitMQ->new() )
);

my $channel = $mq->channel;
my $exchange = $channel->exchange( name => 'order' );
my $q = $exchange->queue( name => 'new-orders', bindings => ['order.new'] );
$exchange->publish( { routing_key => 'order.new', body => 'hello!' } );

$q->handle_message(
    sub {
        ::cmp_ok( $_->{body}, 'eq', 'hello!', 'got the message' );
    }
);

$exchange->publish( { routing_key => 'order.new', body => 'hello!' } );

$q->handle_message(
    sub {
        ::cmp_ok( $_->{body}, 'eq', 'hello!', 'got the message' );
    }
);

done_testing;
