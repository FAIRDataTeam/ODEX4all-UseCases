#!/bin/bash
#
# Batch script to "sponge" required ontologies via Virtuoso RDF Proxy Service.
#
# Author: Arnold Kuzniar
#

RDF_PROXY="http://localhost:8890/about/rdf/"
LOG_FILE=$0.log

# create a lookup for ontologies/URLs
declare -A RDF
RDF[FALDO]="http://biohackathon.org/resource/faldo.rdf"
RDF[SO]="http://purl.obolibrary.org/obo/so.owl"
RDF[RO]="http://localhost:8890/about/rdf/http://purl.obolibrary.org/obo/ro.owl"
RDF[VT]="http://localhost:8890/about/rdf/http://purl.obolibrary.org/obo/vt.owl"
RDF[CMO]="http://localhost:8890/about/rdf/http://purl.obolibrary.org/obo/cmo.owl"
RDF[LPT]="http://localhost:8890/about/rdf/http://data.bioontology.org/ontologies/LPT/download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb&download_format=rdf"
RDF[LBO]="http://localhost:8890/about/rdf/http://data.bioontology.org/ontologies/LBO/download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb&download_format=rdf"
# Note: LPT and LBO do not resolve via BioPortal's PURLs, so need to use these "ugly" URLs.
# To rename RDF graph IRIs use Virtuoso Conductor, follow Linked Data->Graphs in the menu.

rm -f ${LOG_FILE}
for name in "${!RDF[@]}"
do
  echo "[$(date +'%d/%b/%Y %T')] Sponging '$name' ontology into Virtuoso RDF Quad Store..." >> ${LOG_FILE}
  curl -Ss -I -H "Accept: application/rdf+xml" "$RDF_PROXY/${RDF[$name]}" &>> ${LOG_FILE}
done
