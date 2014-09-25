package Crixa::Engine::API;
# ABSTRACT: For internal use only

use Moose::Role;
use namespace::autoclean;

requires qw(_mq _connect_mq);

1;
__END__

=head1 DESCRIPTION

A Role used internally by Crixa. There are no user accessible parts here.
