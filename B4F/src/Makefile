.PHONY: all install-pkgs import-rdf post-install

USER = dba
PASS = dba
PORT = 1111
LOG_FILE = virtuoso.log

all: install-pkgs import-rdf post-install

install-pkgs:
	isql $(PORT) $(USER) $(PASS) verbose=off errors=stdout install_pkgs.sql >> $(LOG_FILE)

import-rdf:
	isql $(PORT) $(USER) $(PASS) verbose=off errors=stdout import_rdf.sql >> $(LOG_FILE)

post-install:
	isql $(PORT) $(USER) $(PASS) verbose=off errors=stdout post_install.sql >> $(LOG_FILE)

