package Test::Crixa;

use strict;
use warnings;

use Crixa::Engine::RabbitMQ;
use Crixa;
use Exporter qw( import );
use Test::More;
use Test::Requires qw( Test::Net::RabbitMQ );

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

1;
