package Test::Crixa;

use strict;
use warnings;

use Crixa::Engine::RabbitMQ;
use Crixa;
use Exporter qw( import );
use Test::More 0.98;
use Test::Requires 0.06 qw( Test::Net::RabbitMQ );

our @EXPORT = qw(
    live_crixa
    mock_crixa
    prefixed_name
);

sub live_crixa {
    unless ( $ENV{RABBITMQ_HOST} ) {
        plan skip_all =>
            'You must set the RABBITMQ_HOST environement vairable to run these tests';
        exit;
    }

    return Crixa->connect( host => $ENV{RABBITMQ_HOST} );
}

sub mock_crixa {
    my $mq = Crixa->connect(
        host => '',
        engine =>
            Crixa::Engine::RabbitMQ->new( _mq => Test::Net::RabbitMQ->new )
    );
}

sub prefixed_name {
    return "crixa-test-$$-" . $_[0];
}

{
    package Test::Net::RabbitMQ;

    no warnings 'redefine';

    # This is all to ensure that message props default to an empty hashref
    if ( Test::Net::RabbitMQ->VERSION <= 0.09 ) {
        *_publish = sub {
            my ( $self, $channel, $routing_key, $body, $options, $props )
                = @_;

            die "Not connected" unless $self->connected;

            die "Unknown channel: $channel"
                unless $self->_channel_exists($channel);

            my $exchange = $options->{exchange};
            unless ($exchange) {
                $exchange = 'amq.direct';
            }

            die "Unknown exchange: $exchange"
                unless $self->_exchange_exists($exchange);

            # Get the bindings for the specified exchange and test each key to see
            # if our routing key matches.  If it does, push it into the queue
            my $binds = $self->bindings->{$exchange};
            foreach my $pattern ( keys %{$binds} ) {
                if ( $routing_key =~ $pattern ) {
                    print STDERR "Publishing '$routing_key' to "
                        . $binds->{$pattern} . "\n"
                        if $self->debug;
                    my $message = {
                        body        => $body,
                        routing_key => $routing_key,
                        exchange    => $exchange,
                        props       => $props || {},
                    };
                    push(
                        @{ $self->_get_queue( $binds->{$pattern} ) },
                        $message
                    );
                }
            }
        };
    }
}

1;
