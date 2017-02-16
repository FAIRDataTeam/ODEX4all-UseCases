# [Pig QTLdb](http://www.animalgenome.org/QTLdb/pig) Linked Data deployment

**1. Build a [Docker](https://www.docker.com/) container with [Virtuoso Universal Server](http://virtuoso.openlinksw.com/) (open source edition).**

```
cd src
docker build -t vos .
```

**2. Start the Virtuoso server.**

`docker run --name b4f -v $PWD:/tmp/share -p 8890:8890 -d vos`

**3. Prepare & ingest RDF data.**

```
tar xvzf ../data/pigQTLdb-ld.tar.gz -C ../data
mv ../data/rdf/* .
docker exec b4f make all # check virtuoso.log for potential errors
```

**4. [Login](http://localhost:8890/conductor) to running Virtuoso instance for admin tasks.**

Use `dba` for both account name and password.

**5. Run [queries](https://github.com/DTL-FAIRData/ODEX4all-UseCases/wiki/Breed4Food:-example-SPARQL-queries) via Virtuoso [SPARQL endpoint](http://localhost:8890/sparql) or browse data via [Faceted Browser](http://localhost:8890/fct/) (no login required).**

RDF graphs:IRIs (_A-Box_)
  * Pig QTLdb: `http://www.animalgenome.org/QTLdb/pig`
  * Ensembl: `http://www.ensembl.org/pig`, `http://www.ensembl.org/human`
  * UniProt: `http://www.uniprot.org/proteomes/pig`
  * OMIM: `http://bio2rdf.org/omim_resource:bio2rdf.dataset.omim.R4`

RDF graphs:IRIs (_T-Box_)
  * FALDO: `http://biohackathon.org/resource/faldo.rdf`
  * SO[FA]: `http://purl.obolibrary.org/obo/so.owl`
  * SIO: `http://semanticscience.org/ontology/sio.owl`
  * RO: `http://purl.obolibrary.org/obo/ro.owl`
  * VT: `http://purl.obolibrary.org/obo/vt.owl`
  * CMO: `http://purl.obolibrary.org/obo/cmo.owl`
  * LPT: `http://purl.bioontology.org/ontology/LPT`
  * LBO: `http://purl.bioontology.org/ontology/LBO`
  * Uniprot Core: `http://purl.uniprot.org/core/`

For further details visit the [wiki](https://github.com/DTL-FAIRData/ODEX4all-UseCases/wiki/Breed4Food) page.
