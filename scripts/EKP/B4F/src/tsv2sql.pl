#!/usr/bin/env perl -w

use strict;

my $header = <>; # first line must be a header
chomp($header);
my $colist = '"' . join('","', split /\t/, $header) . '"'; # ordered list of collumn names
my $table = 'B4F.odex4all.ONTO';
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

