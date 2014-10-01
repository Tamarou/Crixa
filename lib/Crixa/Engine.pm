package Crixa::Engine;
# ABSTRACT: For internal use only

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

=head1 DESCRIPTION

This is used internally by Crixa. There are no user accessible parts here.

