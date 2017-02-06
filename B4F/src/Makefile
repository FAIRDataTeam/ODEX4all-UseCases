.PHONY: all install-pkgs get-onto import-rdf update-rdf post-install

USER = dba
PASS = dba
PORT = 1111
LOG_FILE = virtuoso.log
ISQL = isql $(PORT) $(USER) $(PASS) verbose=off errors=stdout
CURL = curl -fLH "Accept: application/rdf+xml"

all: install-pkgs get-onto import-rdf update-rdf post-install

install-pkgs:
	$(ISQL) install_pkgs.sql > $(LOG_FILE)

get-onto:
    # fetch & store ontologies in *.rdf.gz files
    # write graph URIs onto *.graph files required for importing RDF graphs
	$(CURL) -o faldo.rdf "http://biohackathon.org/resource/faldo.rdf" && \
	echo "http://biohackathon.org/resource/faldo.rdf" > faldo.rdf.graph
	$(CURL) -o so.rdf "http://purl.obolibrary.org/obo/so.owl" && \
	echo "http://purl.obolibrary.org/obo/so.owl" > so.rdf.graph
	$(CURL) -o sio.rdf "http://semanticscience.org/ontology/sio.owl" && \
	echo "http://semanticscience.org/ontology/sio.owl" > sio.rdf.graph
	$(CURL) -o ro.rdf "http://purl.obolibrary.org/obo/ro.owl" && \
	echo "http://purl.obolibrary.org/obo/ro.owl" > ro.rdf.graph
	$(CURL) -o vt.rdf "http://purl.obolibrary.org/obo/vt.owl" && \
	echo "http://purl.obolibrary.org/obo/vt.owl" > vt.rdf.graph
	$(CURL) -o cmo.rdf "http://purl.obolibrary.org/obo/cmo.owl" && \
	echo "http://purl.obolibrary.org/obo/cmo.owl" > cmo.rdf.graph
	$(CURL) -o lpt.rdf "http://data.bioontology.org/ontologies/LPT/download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb&download_format=rdf" && \
	echo "http://purl.bioontology.org/ontology/LPT" > lpt.rdf.graph
	$(CURL) -o lbo.rdf "http://data.bioontology.org/ontologies/LBO/download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb&download_format=rdf" && \
	echo "http://purl.bioontology.org/ontology/LBO" > lbo.rdf.graph
	gzip -9 *.rdf

import-rdf:
	$(ISQL) import_rdf.sql >> $(LOG_FILE)

update-rdf:
	$(ISQL) update_rdf.sql >> $(LOG_FILE)

post-install:
	$(ISQL) post_install.sql >> $(LOG_FILE)
