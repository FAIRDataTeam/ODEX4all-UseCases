# pig QTLdb-Linked Data deployment

**1. Build a [Docker](https://www.docker.com/) container with [Virtuoso Universal Server](http://virtuoso.openlinksw.com/) (open source edition).**

`cd src; docker build -t nlesc/virtuoso .`

**2. Start the server & listen to port 8890.**

`docker run --name vos -d -p 8890:8890 nlesc/virtuoso`

**3. Install required VAD packages.**

<pre><code>docker exec -i vos isql < install_vad_pkgs.sql
docker exec -i vos isql < post_install_fct.sql</code></pre>

**4. Populate database schema for pig QTLdb data.**

`docker exec -i vos isq < create_db.sql`

**5. Prepare input data (*.tsv files) for database import.**

<pre><code>./tsv2sql.pl B4F.odex4all.QTL ../data/QTL.tsv > QTL.sql
./tsv2sql.pl B4F.odex4all.ONTO ../data/ONTO.tsv > ONTO.sql
</code></pre>

**6. Import data into Virtuoso RDB.**

<pre><code>docker exec -i vos isql < QTL.sql
docker exec -i vos isql < ONTO.sql
docker exec -i vos isql < update_db.sql
</code></pre>

**7. Transform RDB to RDF.**

<pre><code>docker cp r2rml.ttl vos:/tmp/data
docker exec -i vos isql < semantify_db.sql
</code></pre>
