#!/usr/bin/env perl
use 5.12.2;
use Crixa;

my $mq = Crixa->connect( host => 'localhost', );
my $q = $mq->queue( name => 'hello' );
$q->on_message( sub { say $_->{body} } );

__END__
