#!/usr/bin/env perl
use 5.12.2;
use Crixa;

my $mq = Crixa->connect( host => 'localhost' );
my $q = $mq->queue( name => 'task_queue', durable => 1 );

$q->handle_message( sub { say $_->{body}; sleep( $_->{body} =~ y/.// ); } );

__END__
