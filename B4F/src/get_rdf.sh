#!/bin/bash
#
# Batch script to download (compressed) data in RDF and to write graph URIs into *.graph files
# required for loading RDF into Virtuoso RDF Quad Store.

ENSEMBL_VERSION=86

# download ontologies
curl --stderr - -LH "Accept: application/rdf+xml" -o faldo.rdf "http://biohackathon.org/resource/faldo.rdf" \
	&& echo "http://biohackathon.org/resource/faldo.rdf" > faldo.rdf.graph

curl --stderr - -LH "Accept: application/rdf+xml" -o so.rdf "http://purl.obolibrary.org/obo/so.owl" \
	&& echo "http://purl.obolibrary.org/obo/so.owl" > so.rdf.graph

curl --stderr - -LH "Accept: application/rdf+xml" -o sio.rdf "http://semanticscience.org/ontology/sio.owl" \
	&& echo "http://semanticscience.org/ontology/sio.owl" > sio.rdf.graph

curl --stderr - -LH "Accept: application/rdf+xml" -o ro.rdf "http://purl.obolibrary.org/obo/ro.owl" \
	&& echo "http://purl.obolibrary.org/obo/ro.owl" > ro.rdf.graph

curl --stderr - -LH "Accept: application/rdf+xml" -o vt.rdf "http://purl.obolibrary.org/obo/vt.owl" \
	&& echo "http://purl.obolibrary.org/obo/vt.owl" > vt.rdf.graph

curl --stderr - -LH "Accept: application/rdf+xml" -o cmo.rdf "http://purl.obolibrary.org/obo/cmo.owl" \
	&& echo "http://purl.obolibrary.org/obo/cmo.owl" > cmo.rdf.graph

curl --stderr - -LH "Accept: application/rdf+xml" -o lpt.rdf "http://data.bioontology.org/ontologies/LPT/download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb&download_format=rdf" \
	&& echo "http://purl.bioontology.org/ontology/LPT" > lpt.rdf.graph

curl --stderr - -LH "Accept: application/rdf+xml" -o lbo.rdf "http://data.bioontology.org/ontologies/LBO/download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb&download_format=rdf" \
	&& echo "http://purl.bioontology.org/ontology/LBO" > lbo.rdf.graph

curl --stderr - -LH "Accept: application/rdf+xml" -o uniprot_core.rdf "http://purl.uniprot.org/core/" \
	&& echo "http://purl.uniprot.org/core/" > uniprot_core.rdf.graph

gzip -9 *.rdf

# download pig genome and proteome data from Ensembl and UniProt Reference Proteomes, respectively
curl --stderr - -LO "ftp://ftp.ensembl.org/pub/release-${ENSEMBL_VERSION}/rdf/sus_scrofa/sus_scrofa.ttl.gz" \
	&& echo "http://www.ensembl.org/pig" > sus_scrofa.ttl.graph

curl --stderr - -LO "ftp://ftp.ensembl.org/pub/release-${ENSEMBL_VERSION}/rdf/sus_scrofa/sus_scrofa_xrefs.ttl.gz" \
	&& echo "http://www.ensembl.org/pig" > sus_scrofa_xrefs.ttl.graph

curl --stderr - -L -o uniprot_pig.rdf.gz "http://www.uniprot.org/uniprot/?format=rdf&compress=yes&query=proteome:UP000008227" \
	&& echo "http://www.uniprot.org/proteomes/pig" > uniprot_pig.rdf.graph

# download human genome data from Ensembl
curl --stderr - -LO "ftp://ftp.ensembl.org/pub/release-${ENSEMBL_VERSION}/rdf/homo_sapiens/homo_sapiens.ttl.gz" \
        && echo "http://www.ensembl.org/human" > homo_sapiens.ttl.graph

curl --stderr - -LO "ftp://ftp.ensembl.org/pub/release-${ENSEMBL_VERSION}/rdf/homo_sapiens/homo_sapiens_xrefs.ttl.gz" \
        && echo "http://www.ensembl.org/human" > homo_sapiens_xrefs.ttl.graph
