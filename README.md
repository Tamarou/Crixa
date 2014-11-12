# NAME

Crixa - A Cleaner API for Net::AMQP::RabbitMQ

# VERSION

version 0.08

# SYNOPSIS

    use Crixa;

    my $mq       = Crixa->connect( host => 'localhost' );
    my $channel  = $mq->channel;
    my $exchange = $channel->exchange( name => 'hello' );

    sub send {
        $exchange->publish('Hello World');
    }

    my $queue = $exchange->queue( name => 'hello' );

    sub receive {
        $queue->handle_message( sub { say $_->body } );
    }

# DESCRIPTION

    All the world will be your enemy, Prince of a Thousand enemies. And when
    they catch you, they will kill you. But first they must catch you; digger,
    listener, runner, Prince with the swift warning. Be cunning, and full of
    tricks, and your people will never be destroyed. -- Richard Adams

This module provides a more natural API over [Net::AMQP::RabbitMQ](https://metacpan.org/pod/Net::AMQP::RabbitMQ), with
separate objects for channels, exchanges, and queues.

# WARNING

**Crixa is still in development and the API may change in the future!**

# METHODS

This class provides the following methods:

## Crixa->connect(...)

Creates a new connection to a RabbitMQ server. It takes a hash or hashref of
named parameters.

- host => $hostname

    The hostname to connect to. Required.

- port => $post

    An optional port.

- user => $user

    An optional username.

- password => $password

    An optional password.

## $crixa->new\_channel

Returns a new [Crixa::Channel](https://metacpan.org/pod/Crixa::Channel) object.

You can use the channel to create exchanges and queues.

## $crixa->disconnect

Disconnect from the server. This is called implicitly by `DEMOLISH` so
normally there should be no need to do this explicitly.

## $crixa->host

Returns the port passed to the constructor, if nay.

## $crixa->user

Returns the user passed to the constructor, if any.

## $crixa->password

Returns the password passed to the constructor, if any.

# SUPPORT

Please report all issues with this code using the GitHub issue tracker at
[https://github.com/Tamarou/Crixa/issues](https://github.com/Tamarou/Crixa/issues).

# SEE ALSO

This module uses [Net::AMQP::RabbitMQ](https://metacpan.org/pod/Net::AMQP::RabbitMQ) under the hood, though it does not
expose everything provided by its API.

The best documentation we've found on RabbitMQ (and AMQP) concepts is the
Bunny documentation at http://rubybunny.info/articles/guides.html. We strongly
recommend browsing this to get a better understanding of how RabbitMQ works,
what different options for exchanges, queues, and messages mean, and more.

# AUTHORS

- Chris Prather <chris@prather.org>
- Dave Rolsky <autarch@urth.org>

# CONTRIBUTOR

Torsten Raudssus <torsten@raudss.us>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012 - 2014 by Chris Prather.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
