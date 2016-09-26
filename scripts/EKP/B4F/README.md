# pig QTLdb-Linked Data deployment

**1. Build docker container with the [Virtuoso Universal Server](http://virtuoso.openlinksw.com/).**
<pre>
<code>cd src
docker build -t nlesc/virtuoso .</code>
</pre>

**2. Start the server & listen to port 8890.**

`docker run --name vos -d -p 8890:8890 nlesc/virtuoso`

**3. Install required VAD packages.**

`docker exec -i vos isql < install_vad_pkgs.sql`

**4. Populate db schema to hold pig QTLdb data.**

`docker exec -i vos isql < create_db.sql`

**5. Prepare data for import.**
<pre>
<code>./tsv2sql.pl B4F.odex4all.QTL ../data/QTL.tsv > QTL.sql
./tsv2sql.pl B4F.odex4all.ONTO ../data/ONTO.tsv > ONTO.sql</code>
</pre>

**6. Import data into Virtuoso relational store (RDB).**
<pre>
<code>ARG="VERBOSE=OFF"
docker exec -i vos isql $ARG < QTL.sql
docker exec -i vos isql $ARG < ONTO.sql
docker exec -i vos isql $ARG < update_db.sql</code>
</pre>
