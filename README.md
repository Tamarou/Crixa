# Crixa - A nicer API for Net::RabbitMQ

> All the world will be your enemy, Prince of a Thousand enemies. And when 
> they catch you, they will kill you. But first they must catch you; digger,
> listener, runner, Prince with the swift warning. Be cunning, and full of
> tricks, and your people will never be destroyed. -- Richard Adams

## Synopsis

    use Crixa;

    my $mq = Crixa->connect( host => 'localhost');

    sub send {
        my $q = $mq->queue( name => 'hello');
        $q->publish('Hello World');
    }

    sub receive {
        my $q = $mq->queue( name => 'hello');
        $q->handle_message(sub { say $_->{body} });
    }

## Description

[coming soon]