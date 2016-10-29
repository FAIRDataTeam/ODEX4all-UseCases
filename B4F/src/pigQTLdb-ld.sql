SPARQL CLEAR GRAPH <http://www.animalgenome.org/pigQTLdb>;
DELETE FROM DB.DBA.load_list;
ld_dir('/tmp/share', 'pigQTLdb.ttl', 'http://www.animalgenome.org/pigQTLdb');
SELECT * FROM DB.DBA.load_list;
rdf_loader_run();
