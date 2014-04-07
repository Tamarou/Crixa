package Crixa::Engine::API;
# ABSTRACT: Crixa::Engine::API

use Moose::Role;
use namespace::autoclean;

requires qw(_mq _connect_mq);

1;
__END__

