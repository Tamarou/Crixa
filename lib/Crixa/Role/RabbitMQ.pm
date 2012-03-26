package Crixa::Role::RabbitMQ;
use Moose::Role;
use namespace::autoclean;

use Net::RabbitMQ;

my %map = map { ( "_mq_${_}", $_ ) } (
    qw(
        channel_open disconnect exchange_declare
        exchange_declare get get_channel_max publish
        queue_bind queue_declare queue_declare ack
        basic_qos channel_close
        )
);

has _mq => (
    isa     => 'Net::RabbitMQ',
    is      => 'ro',
    lazy    => 1,
    builder => '_build__mq',
    handles => \%map,
);

sub _build__mq {...}

sub _connect_mq {
    my ( $self, $config ) = @_;
    my $mq   = Net::RabbitMQ->new();
    my @args = ( $config->host );
    if ( $_[0]->user && $config->password ) {
        push @args => {
            user     => $config->user,
            password => $config->password
        };
    }
    else { push @args => {} }
    $mq->connect(@args);
    return $mq;
}

1;
__END__
