package Crixa::Engine;
# ABSTRACT: Crixa::Engine

use Moose::Role;
use namespace::autoclean;

use Crixa::Engine::RabbitMQ;

has engine => (
    does    => 'Crixa::Engine::API',
    is      => 'ro',
    handles => 'Crixa::Engine::API',
    lazy    => 1,
    builder => '_build_engine',
);

sub _build_engine { Crixa::Engine::RabbitMQ->new() }

1;
__END__

