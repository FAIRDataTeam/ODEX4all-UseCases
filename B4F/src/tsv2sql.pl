#!/usr/bin/env perl

use strict;
use warnings;

my $table = $ARGV[0] || 'B4F.odex4all.QTL'; # catalog.owner.table in Virtuoso jargon
my $infile = $ARGV[1];

die "Usage: $0 [catalog.owner.table] [*.tsv file]\n" unless $infile;

open IN, $infile or die "Can't open $infile.\n";
my $header = <IN>; # first line must be a header
chomp($header);
my $colist = '"' . join('","', split /\t/, $header) . '"'; # ordered list of collumn names
while (<IN>) {
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
close IN;
