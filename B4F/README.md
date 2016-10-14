# [Pig QTLdb-LD](http://www.animalgenome.org/cgi-bin/QTLdb/SS/index) (Linked Data) deployment 

**1. Build a [Docker](https://www.docker.com/) container with [Virtuoso Universal Server](http://virtuoso.openlinksw.com/) (open source edition).**

`cd src; docker build -t nlesc/virtuoso .`

**2. Start the server.**

`docker run --name vos -v $(pwd):/tmp/share -p 8890:8890 -d nlesc/virtuoso`

**3. Prepare input data (*.tsv files) for database import.**

<pre><code>gzip -rd ../data
./tsv2sql.pl B4F.odex4all.QTL ../data/QTL.tsv > QTL.sql
./tsv2sql.pl B4F.odex4all.ONTO ../data/ONTO.tsv > ONTO.sql
</code></pre>

**4. Build & deploy pig QTLdb-LD.**

`docker exec vos ./build.sh`

**5. [Login](http://localhost:8890/conductor) to your running Virtuoso instance.**

Use `dba` for both account name and password.

**6. Access pig QTLdb-LD via Virtuoso [SPARQL endpoint](http://localhost:8890/sparql) (no login required).**

Use the (default) RDF graph IRI:`http://localhost:8890/B4F`.
