#!/usr/bin/env perl -w

use strict;

my $table = $ARGV[0] || 'B4F.odex4all.QTL'; # catalog.schema.name in Virtuoso jargon
my $header = <>; # first line must be a header
chomp($header);
my $colist = '"' . join('","', split /\t/, $header) . '"'; # ordered list of collumn names
while (<>) {
   chomp;
   my @values;
   foreach my $val(split /\t/) {
       $val =~ s/'/\Q'/g;
       push(@values, $val);
   }
   my $vals = "'" . join("','", @values) . "'";
   $vals =~ s/''/NULL/g;
   print "INSERT INTO $table ($colist) VALUES ($vals);\n";
}

