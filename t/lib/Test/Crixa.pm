package Test::Crixa;

use strict;
use warnings;

use Exporter ();
use Test::More;

our @EXPORT = qw( prefixed_name );

sub import {
    unless ( $ENV{RABBITMQ_HOST} ) {
        plan skip_all =>
            'You must set the RABBITMQ_HOST environement vairable to run these tests';
        exit;
    }

    goto &Exporter::import;
}

sub prefixed_name {
    return "crixa-test-$$-" . $_[0];
}

1;
