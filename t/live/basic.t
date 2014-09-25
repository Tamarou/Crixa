use strict;
use warnings;

use lib 't/lib';

use Test::Crixa;
use Test::More;

my $mq = live_crixa();
my $channel = $mq->new_channel;
my $exchange = $channel->exchange( name => prefixed_name('order') );
my $q = $exchange->queue( name => prefixed_name('new-orders'), routing_keys => ['order.new'] );
$exchange->publish( { routing_key => 'order.new', body => 'hello!' } );

$q->handle_message(
    sub {
        cmp_ok( $_->body, 'eq', 'hello!', 'got the message' );
    }
);

$exchange->publish( { routing_key => 'order.new', body => 'hello!' } );

$q->handle_message(
    sub {
        cmp_ok( $_->body, 'eq', 'hello!', 'got the message' );
    }
);

$q->delete;
$exchange->delete;

done_testing;
