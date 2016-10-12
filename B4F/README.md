# pig QTLdb-Linked Data deployment

**1. Build a [Docker](https://www.docker.com/) container with [Virtuoso Universal Server](http://virtuoso.openlinksw.com/) (open source edition).**

`cd src; docker build -t nlesc/virtuoso .`

**2. Start the server.**

`docker run --name vos -v $(pwd):/tmp/share -p 8890:8890 -d nlesc/virtuoso`

**3. Prepare input data (*.tsv files) for database import.**

<pre><code>./tsv2sql.pl B4F.odex4all.QTL ../data/QTL.tsv > QTL.sql
./tsv2sql.pl B4F.odex4all.ONTO ../data/ONTO.tsv > ONTO.sql
</code></pre>

**4. Build & deploy pig QTLdb as Linked Data.**

<code>docker exec -it vos /bin/bash
./build.sh
</code></pre>
