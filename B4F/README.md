# [Pig QTLdb](http://www.animalgenome.org/QTLdb/pig) Linked Data deployment

**1. Build a [Docker](https://www.docker.com/) container with [Virtuoso Universal Server](http://virtuoso.openlinksw.com/) (open source edition).**

`cd src; docker build -t nlesc/virtuoso .`

**2. Start the server.**

`docker run --name b4f -v $(pwd):/tmp/share -p 8890:8890 -d nlesc/virtuoso`

**3. Build & deploy pig QTLdb-LD.**

<pre><code>tar xvzf ../data/pigQTLdb.tar.gz -C ../data
mv ../data/pigQTLdb.ttl .
docker exec b4f ./build.sh
</code></pre>

**5. [Login](http://localhost:8890/conductor) to running Virtuoso instance for admin tasks.**

Use `dba` for both account name and password.

**7. Query pig QTLdb-LD via Virtuoso [SPARQL endpoint](http://localhost:8890/sparql) or [Faceted Browser](http://localhost:8890/fct/) (no login required).**

Use the (default) RDF graph IRI: `http://www.animalgenome.org/QTLdb/pig`.
