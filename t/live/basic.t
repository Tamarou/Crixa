use strict;
use warnings;

use lib 't/lib';

use Crixa;
use Test::Crixa;
use Test::More;

my $mq = Crixa->connect( host => $ENV{RABBITMQ_HOST} );

my $channel = $mq->channel;
my $exchange = $channel->exchange( name => prefixed_name('order') );
my $q = $exchange->queue( name => prefixed_name('new-orders'), bindings => ['order.new'] );
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

$q->delete;
$exchange->delete;

done_testing;
