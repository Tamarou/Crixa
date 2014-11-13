use strict;
use warnings;

use lib 't/lib';

use Test::Crixa;
use Test::More;

my $crixa    = live_crixa();
my $channel  = $crixa->new_channel;
my $exchange = $channel->exchange( name => prefixed_name('order') );
my $q        = $exchange->queue(
    name         => prefixed_name('new-orders'),
    routing_keys => ['order.new']
);
$exchange->publish( { routing_key => 'order.new', body => 'hello there!' } );

_wait_for_min_messages( $q, 1 );

is( $q->message_count, 1, 'queue has one message waiting' );
$q->handle_message(
    sub {
        cmp_ok( $_->body, 'eq', 'hello there!', 'got the first message' );
    }
);

_wait_for_no_messages($q);

$exchange->publish( { routing_key => 'order.new', body => 'hello again!' } );

_wait_for_min_messages( $q, 1 );
cmp_ok(
    $q->message_count, '>=', 1,
    'queue has at least one message waiting'
);

$q->handle_message(
    sub {
        cmp_ok( $_->body, 'eq', 'hello again!', 'got the second message' );
    }
);

$q->delete;
$exchange->delete;

done_testing;

sub _wait_for_min_messages {
    my $q         = shift;
    my $min_count = shift;

    my $desc = "queue has at least $min_count message"
        . (
        $min_count == 1
        ? q{}
        : 's'
        );
    _wait_for_messages( $q, sub { $_[0] >= $min_count }, $desc );
}

sub _wait_for_no_messages {
    my $q = shift;

    _wait_for_messages( $q, sub { $_[0] == 0 }, 'queue is empty' );
}

sub _wait_for_messages {
    my $q         = shift;
    my $condition = shift;
    my $desc      = shift;

    local $@;
    eval {
        local $SIG{ALRM}
            = sub { die 'no messages in the queue after waiting 5 seconds' };
        alarm 5;
        sleep 1 until $condition->( $q->message_count );
    };
    is(
        $@, q{},
        "waited until $desc without errors"
    );
}
