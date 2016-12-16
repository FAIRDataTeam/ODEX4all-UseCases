#!/bin/bash
#
# Batch script to "sponge" required ontologies via Virtuoso RDF Proxy Service.
#
# Author: Arnold Kuzniar
#
# Prerequisite: GRANT EXECUTE ON "DB.DBA.EXEC_AS" to "SPARQL";
#

RDF_PROXY="http://localhost:8890/describe/"
LOG_FILE=$0.log

# create a lookup for ontologies/URLs
declare -A RDF
RDF[FALDO]="http://biohackathon.org/resource/faldo.rdf"
RDF[SIO]="http://semanticscience.org/ontology/sio.owl"
RDF[SO]="http://purl.obolibrary.org/so.owl"
RDF[RO]="http://purl.obolibrary.org/ro.owl"
RDF[VT]="http://purl.obolibrary.org/obo/vt.owl"
RDF[CMO]="http://purl.obolibrary.org/obo/cmo.owl"
# Note: Must download LPT and LBO because they do not resolve properly via BioPortal's PURL.
# Then upload the files via "Linked Data" -> "Quad Store Upload" tabs in Virtuoso Conductor.
RDF[LPT]="http://data.bioontology.org/ontologies/LPT/download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb&download_format=rdf"
RDF[LBO]="http://data.bioontology.org/ontologies/LBO/download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb&download_format=rdf"

rm -f ${LOG_FILE}
for name in "${!RDF[@]}"
do
  url="${RDF_PROXY}?url=${RDF[$name]}&sponger:get=add"
  echo "[$(date +'%d/%b/%Y %T')] Sponging '$name' ontology into Virtuoso RDF Quad Store via '${url}'..." >> ${LOG_FILE}
  curl -Ss -I -H "Accept: application/rdf+xml" "$url" &>> ${LOG_FILE}
done
