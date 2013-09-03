#!/usr/bin/perl

use strict;

# Custom Libs
# Include the sample hash/array creation lib here

print "Printing begins\n";
$b = {'key' => {'key2' => {'key3' => 'value'}}};

sub parse_hash {
    my ($hash, $fn) = @_;
    while (my ($key, $value) = each %$hash) {
        if ('HASH' eq ref $value) {
            parse_hash ($value, $fn);
        }
        else {
             $fn->($value);
        }
    }
}

# my $example = {'key' => {'key2' => {'key3' => 'value'}}};
parse_hash $b, sub {
    my ($value) = @_;
    print "Value $value\n";
};
