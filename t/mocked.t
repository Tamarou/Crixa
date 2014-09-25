use strict;
use warnings;

use lib 't/lib';

use Test::Crixa;
use Test::More;

my $mq = mock_crixa();
my $channel = $mq->new_channel;
my $exchange = $channel->exchange( name => 'order' );
my $q = $exchange->queue( name => 'new-orders', routing_keys => ['order.new'] );
$exchange->publish( { routing_key => 'order.new', body => 'hello!' } );

$q->handle_message(
    sub {
        ::cmp_ok( $_->body, 'eq', 'hello!', 'got the message' );
    }
);

$exchange->publish( { routing_key => 'order.new', body => 'hello!' } );

$q->handle_message(
    sub {
        ::cmp_ok( $_->body, 'eq', 'hello!', 'got the message' );
    }
);

done_testing;
