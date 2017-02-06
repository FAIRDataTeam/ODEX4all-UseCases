# [Pig QTLdb](http://www.animalgenome.org/QTLdb/pig) Linked Data deployment

**1. Build a [Docker](https://www.docker.com/) container with [Virtuoso Universal Server](http://virtuoso.openlinksw.com/) (open source edition).**

```
cd src
docker build -t vos .
```

**2. Start the server.**

`docker run --name b4f -v $PWD:/tmp/share -p 8890:8890 -d vos`

**3. Build & deploy pig QTLdb-LD.**

```
tar xvzf ../data/pigQTLdb-ld.tar.gz -C ../data
mv ../data/rdf/* .
docker exec b4f make all
```

**4. [Login](http://localhost:8890/conductor) to running Virtuoso instance for admin tasks.**

Use `dba` for both account name and password.

**5. Query pig QTLdb-LD via Virtuoso [SPARQL endpoint](http://localhost:8890/sparql) or [Faceted Browser](http://localhost:8890/fct/) (no login required).**

RDF graphs (IRIs):
  * Pig QTLdb: `http://www.animalgenome.org/QTLdb/pig`
  * Ensembl: `http://www.ensembl.org/pig`
  * UniProt: `http://www.uniprot.org/proteomes/pig`

For further details visit the [wiki](https://github.com/DTL-FAIRData/ODEX4all-UseCases/wiki/Breed4Food) page.
