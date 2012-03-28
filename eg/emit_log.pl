#!/usr/bin/env perl
use 5.12.1;
use Crixa;

my $mq       = Crixa->connect( host => "localhost", );
my $chan     = $mq->channel;
my $exchange = $chan->exchange( name => 'logs', exchange_type => 'fanout' );

my $message = join( ' ', @ARGV ) || 'info: Hello World!';

$exchange->publish($message);

__END__
