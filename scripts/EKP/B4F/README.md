## pig QTLdb Linked Data deployment
cd src

# build docker container with Virtuoso server
docker build -t nlesc/virtuoso .

# start Virtuoso server & listen to port 8890
docker run --name vos -d -p 8890:8890 nlesc/virtuoso

# install required VAD packages
docker exec -i vos isql < install_vad_pkgs.sql

# populate pig QTLdb schema
docker exec -i vos isql < create_db.sql

# transform pig QTLdb data in *.tsv files into *.sql files
./tsv2sql.pl B4F.odex4all.QTL ../data/QTL.tsv > QTL.sql
./tsv2sql.pl B4F.odex4all.ONTO ../data/ONTO.tsv > ONTO.sql

# import data into pig QTLdb
docker exec -i vos isql < QTL.sql
docker exec -i vos isql < ONTO.sql
docker exec -i vos isql < update_db.sql
