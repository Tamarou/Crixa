use Test::More;
use Test::Requires qw( Net::RabbitMQ );
use Crixa;

unless ($ENV{RABBITMQ_HOST}) { 
    plan skip_all => 'You must set the RABBITMQ_HOST environement vairable to run these tests';
    exit;
}

my $mq = Crixa->connect( host => $ENV{RABBITMQ_HOST} );

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
