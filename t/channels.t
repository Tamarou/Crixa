use strict;
use warnings;

use lib 't/lib';

use Test::Crixa;
use Test::More;

my $mq = mock_crixa();
my $channel = $mq->new_channel;
is( $channel->id, 1, 'first channel is id 1' );
is( $mq->new_channel->id, 2, '$mq->new_channel returns a new channel' );

my $exchange = $channel->exchange( name => 'foo' );
is(
   $exchange->channel->id, $channel->id,
    '$channel->exchange returns an exchange attached to the channel it is called on'
);

my $queue = $exchange->queue( name => 'foo', routing_keys => ['foo'] );
is(
    $queue->channel->id, $channel->id,
    '$channel->queue returns a queue attached to the channel it is called on'
);

$exchange->publish( routing_key => 'foo', body => 'foo body' );

my @messages = grep { defined } $queue->check_for_message;
if (
    is(
        scalar @messages, 1,
        '$channel->publish sent one message to the foo queue'
    )
    ) {
    is(
        $messages[0]{body}, 'foo body',
        'message body contains expected content'
    );
}

done_testing;
