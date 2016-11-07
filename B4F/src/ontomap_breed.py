#!/usr/bin/env python
#
# This script maps breed names to Livestock Breed Ontology (LBO) IDs.
#
# Input files:
#   ONTO.tsv with two columns: id (format: <ontology_acronym>:<term_id>) and name
#   pigQTLdb.tsv with two columns: qtl_id and breed (comma-separated field of values)
#
# Output (STDOUT):
#    three columns separated by \t: id, name, LBO breed IDs
#

sep='\t'
file1 ='../data/ONTO.tsv'
file2 ='../data/pigQTLdb.tsv'
lookup = dict()

with open(file1) as fin:
   for ln in fin:
      ln = ln.rstrip()
      id, name = ln.split(sep)
      lookup[name.lower()] = id

with open(file2) as fin:
   for ln in fin:
      ln = ln.rstrip()
      cols = ln.split(sep)
      if len(cols) == 2:
         ids = []
         for b in cols[1].lower().split(','):
            if b in lookup:
               ids.append(lookup[b])
         print(ln + sep + ','.join(ids))
      else:
         print(ln)
